//
//  LoginVC.swift
//  Kudu
//
//  Created by Admin on 12/05/22.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices
import LanguageManager_iOS

class LoginVC: BaseVC {
    
    // MARK: IBOutlets
    @IBOutlet private weak var baseView: LoginView!
    
    // MARK: Properties
    private var authorizationController: ASAuthorizationController?
    private var viewSetupDone = false
    var viewModel: LoginVM?
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        addObservers()
        if let viewModel = viewModel {
            if let expiryError = viewModel.getExpiryError {
                self.baseView.resetLoginField(msg: expiryError)
            }
        }
    }
    
    // MARK: Initial Setup
    private func initialSetup() {
        if viewModel.isNil {
            initialiseVM()
        }
        if let flow = viewModel?.getCurrentFlow, flow == .comingFromLoggedInUser {
            weak var weakSelf = self.navigationController as? BaseNavVC
            weakSelf?.disableSwipeBackGesture = true
        }
        baseView.setupView(delegate: self)
        handleActions()
    }
    
    private func initialiseVM() {
        viewModel = LoginVM(delegate: self, flow: .comingFromGuestUser)
    }
    
    private func addObservers() {
        self.observeFor(.resetLoginState, selector: #selector(resetLoginState(notification:)))
        self.observeFor(.sessionExpired, selector: #selector(resetLoginState(notification:)))
    }
    
    // MARK: Observers
    @objc private func resetLoginState(notification: NSNotification) {
        mainThread {
            let msg = notification.userInfo?["msg"] as? String ?? ""
            self.baseView.resetLoginField(msg: msg)
        }
    }
    
    // MARK: Functions
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .loginButtonPressed :
                strongSelf.baseView.handleAPIRequest(.loginAPI)
                strongSelf.viewModel?.getOtp(strongSelf.baseView.getMobileNumberEntered)
                //Router.shared.goToPhoneVerificationVC(fromVC: self)
               
            case .googleLogin :
                strongSelf.handleGoogleIn()
            case .twitterLogin :
                strongSelf.handleTwitterLogIn()
            case .facebookLogin:
                strongSelf.handleFacebookLogin()
            case .appleLogin:
                strongSelf.handleAppleLogin()
            case .backButtonPressed:
                if let flow = strongSelf.viewModel?.getCurrentFlow, flow == .comingFromGuestUser {
                    strongSelf.pop()
                } else {
                    //Redirection to Home Screen Guest User Flow
                    AppUserDefaults.removeValue(forKey: .loginResponse)
                    Router.shared.configureTabBar()
                }
                
            }
        }
    }
}

extension LoginVC {
    
    // MARK: Social Login Handling
    private func handleGoogleIn() {
        GIDSignIn.sharedInstance.signIn(with: Constants.GoogleSingInCredentials.signInConfig, presenting: self, callback: { [weak self] (user, error) in
            mainThread {
                if user.isNotNil {
                    let socialId = user?.userID ?? ""
                    let email: String? = user?.profile?.email
                    let name: String = user?.profile?.name ?? ""
                    var validatedScreenName: String? = CommonValidation.returnValidatedName(name)
                    validatedScreenName = (validatedScreenName ?? "") == "" ? nil : validatedScreenName
                    let signUpRequest = SocialSignUpRequest(socialId: socialId, email: email, name: validatedScreenName, mobileNum: nil, socialLoginType: .google)
                    self?.baseView.handleAPIRequest(.socialAPI)
                    self?.viewModel?.socialLogin(.google, socialId: socialId, signUpRequestObject: signUpRequest)
                    debugPrint("User : \(user!)")
                }
                if error.isNotNil {
                    self?.baseView.handleAPIResponse(.socialAPI, isSuccess: false, errorMsg: error?.localizedDescription ?? "")
                    debugPrint("Error : \(error?.localizedDescription ?? "")")
                }
            }
        })
    }
    
    private func handleAppleLogin() {
          let appleIDProvider = ASAuthorizationAppleIDProvider()
          let request = appleIDProvider.createRequest()
          request.requestedScopes = [.fullName, .email]
          
          authorizationController = ASAuthorizationController(authorizationRequests: [request])
          authorizationController?.delegate = self
          authorizationController?.presentationContextProvider = self
          authorizationController?.performRequests()
    }
    
    private func handleFacebookLogin() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self, handler: { [weak self] (result, error) in
            mainThread {
                if let error = error {
                    self?.baseView.handleAPIResponse(.socialAPI, isSuccess: false, errorMsg: error.localizedDescription)
                    print("Encountered Erorr: \(error)")
                } else if let result = result, result.isCancelled {
                    print("Cancelled")
                } else {
                    let socialId = result?.token?.userID ?? ""
                    let signUpReq = SocialSignUpRequest(socialId: socialId, email: nil, name: nil, mobileNum: nil, socialLoginType: .facebook)
                    self?.baseView.handleAPIRequest(.socialAPI)
                    self?.viewModel?.socialLogin(.facebook, socialId: socialId, signUpRequestObject: signUpReq, fbToken: result?.token)
                    print("Logged In")
                }
            }
            
        })
    }
    
    private func handleTwitterLogIn() {
        let twitterService = TwitterService()
        twitterService.delegate = self
        twitterService.authorize()
    }
}

extension LoginVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // MARK: Apple Login
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.baseView.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        debugPrint("Apple Login Success")
        let credential = authorization.credential
        var userId: String = ""
        var name: String?
        var email: String?
        let appleCredential = credential as? ASAuthorizationAppleIDCredential
        if appleCredential.isNotNil {
            userId = appleCredential?.user ?? ""
            if appleCredential?.fullName?.givenName ?? "" != "" && appleCredential?.fullName?.familyName ?? "" != "" {
                name = (appleCredential?.fullName?.givenName ?? "") + " " + (appleCredential?.fullName?.familyName ?? "")
            }
            email = appleCredential?.email
        } else {
            //iCloud Keychain credential
            userId = (credential as? ASPasswordCredential)?.user ?? ""
        }
        let signUpReq = SocialSignUpRequest(socialId: userId, email: email, name: name, mobileNum: nil, socialLoginType: .apple)
        debugPrint("Credentials : \(userId) \(name ?? "") \(email ?? "")")
        mainThread {
            self.baseView.handleAPIRequest(.socialAPI)
            self.viewModel?.socialLogin(.apple, socialId: userId, signUpRequestObject: signUpReq)
        }
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        debugPrint("Apple Login Failed")
    }
}

extension LoginVC: TwitterServiceDelegate {
    
    // MARK: Twitter Login
    func loadAuthURL(url: URL) {
        let customVC = TwitterWebVC.instantiate(fromAppStoryboard: .Onboarding)
        customVC.url = url
        self.present(customVC, animated: true, completion: nil)
    }
    
    func credentialsReceived(userId: String, screenName: String) {
        mainThread {
            self.baseView.handleAPIRequest(.socialAPI)
            let validatedScreenName = CommonValidation.returnValidatedName(screenName)
            let signUpReq = SocialSignUpRequest(socialId: userId, email: nil, name: validatedScreenName, mobileNum: nil, socialLoginType: .twitter)
            self.viewModel?.socialLogin(.twitter, socialId: userId, signUpRequestObject: signUpReq)
        }
    }
}

extension LoginVC: UITextViewDelegate {
    
    // MARK: TextView Delegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if URL.absoluteString == "SignUp" {
            Router.shared.goToSignUpVC(fromVC: self)
            return false
        }
        
        return true
    }
    
}

extension LoginVC: LoginVMDelegate {
    
    // MARK: API Handling
    func loginAPIResponse(responseType: Result<String, Error>) {
        switch responseType {
        case .success(let responseString):
            debugPrint(responseString)
            self.baseView.handleAPIResponse(.loginAPI, isSuccess: true, errorMsg: nil)
            let verificationVC = PhoneVerificationVC.instantiate(fromAppStoryboard: .Onboarding)
            verificationVC.viewModel = PhoneVerificationVM(_signUpReq: nil, loginMobileNo: self.baseView.getMobileNumberEntered, _delegate: verificationVC, flowType: .comingFromLogin)
            //baseView.resetLoginField()
            self.push(vc: verificationVC)
        case .failure(let error):
            self.baseView.handleAPIResponse(.loginAPI, isSuccess: false, errorMsg: error.localizedDescription)
        }
    }
    
    func socialAPIResponse(isSuccess: Bool, socialSignUpRequest: SocialSignUpRequest?, errorMsg: String?) {
        mainThread {
            if isSuccess {
                AppUserDefaults.removeGuestUserData()
                Router.shared.configureTabBar()
                self.baseView.handleAPIResponse(.socialAPI, isSuccess: isSuccess, errorMsg: nil)
                return
            }
            
            if socialSignUpRequest.isNotNil {
                self.baseView.handleAPIResponse(.socialAPI, isSuccess: isSuccess, errorMsg: nil)
                let signupVC = SignUpVC.instantiate(fromAppStoryboard: .Onboarding)
                signupVC.viewModel = SignUpVM(_delegate: signupVC, _socialSignUpReq: socialSignUpRequest!)
                self.push(vc: signupVC)
                return
            }
            self.baseView.handleAPIResponse(.socialAPI, isSuccess: isSuccess, errorMsg: errorMsg)
        }
    }
}
