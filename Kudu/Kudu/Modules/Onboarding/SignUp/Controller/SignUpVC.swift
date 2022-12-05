//
//  SignUpVC.swift
//  Kudu
//
//  Created by Admin on 28/05/22.
//

import UIKit

class SignUpVC: BaseVC {
    // MARK: Outlets
    @IBOutlet private weak var baseView: SignUpView!
    // MARK: Variables
    var viewModel: SignUpVM?
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel.isNil {
            viewModel = SignUpVM(_delegate: self)
        }
        baseView.setupView(delegate: self, socialData: viewModel?.getSocialData)
        handleViewActions()
        addObservers()
    }
    
    private func addObservers() {
        self.observeFor(.clearSignUpFormPhoneField, selector: #selector(clearPhoneField))
    }
    
    @objc private func clearPhoneField() {
        mainThread {
            self.baseView.clearPhoneField()
        }
    }
    
    private func handleViewActions() {
        baseView.handleViewActions = { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .signUpButtonPressed:
                strongSelf.handleSignUpButtonPressed()
            case .dismissVC:
                strongSelf.pop()
            case .mergeData:
                strongSelf.baseView.handleAPIRequest()
                strongSelf.viewModel?.resendOTP(phoneNumber: self?.baseView.getPhoneNum ?? "", email: nil)
            }
        }
    }
    
    private func handleSignUpButtonPressed() {
        guard let viewModel = self.viewModel else { return }
        let validation = viewModel.validateData(name: self.baseView.getName, phoneNum: self.baseView.getPhoneNum, email: self.baseView.getEmail)
        if validation.result == false {
            self.baseView.showError(message: validation.error)
        } else {
            self.baseView.handleAPIRequest()
            if viewModel.getSocialData.isNotNil {
                viewModel.socialSignUp(name: self.baseView.getName, phoneNum: self.baseView.getPhoneNum, email: self.baseView.getEmail)
            } else {
                viewModel.signUp(name: self.baseView.getName, phoneNum: self.baseView.getPhoneNum, email: self.baseView.getEmail)
            }
        }
    }
    
}

extension SignUpVC: UITextViewDelegate {
    // MARK: Handle Link Redirection
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        switch URL.absoluteString {
        case "goToSignIn":
            self.pop()
            return false
        case "goToTermsOfUse":
            let webVC = WebViewVC.instantiate(fromAppStoryboard: .Setting)
            webVC.pageType = .terms
            self.push(vc: webVC)
            return false
        case "goToPrivacyPolicy":
            let webVC = WebViewVC.instantiate(fromAppStoryboard: .Setting)
            webVC.pageType = .privacyPolicy
            self.push(vc: webVC)
            return false
        default:
            break
        }
        return true
    }
}

extension SignUpVC: SignUpVMDelegate {
    // MARK: Handle API
    
    func signUpAPIResponse(responseType: Result<String, Error>) {
        switch responseType {
        case .success:
            self.baseView.handleAPIResponse(isSuccess: true, errorMsg: nil)
            let phoneVerificationVC = PhoneVerificationVC.instantiate(fromAppStoryboard: .Onboarding)
            let signUpRequest = SignUpRequest(email: self.baseView.getEmail, name: self.baseView.getName, mobileNum: self.baseView.getPhoneNum)
            phoneVerificationVC.viewModel = PhoneVerificationVM(_signUpReq: signUpRequest, loginMobileNo: nil, _delegate: phoneVerificationVC, flowType: .comingFromSignUp)
            self.navigationController?.pushViewController(phoneVerificationVC, animated: true)
        case .failure(let error) :
            self.baseView.handleAPIResponse(isSuccess: false, errorMsg: error.localizedDescription)
        }
    }
    
    func socialSignUpAPIResponse(responseType: Result<String, Error>) {
        switch responseType {
        case .success:
            self.baseView.handleAPIResponse(isSuccess: true, errorMsg: nil)
            let phoneVerificationVC = PhoneVerificationVC.instantiate(fromAppStoryboard: .Onboarding)
            let socialSignUpReq = self.viewModel?.getSocialData
            phoneVerificationVC.viewModel = PhoneVerificationVM(_socialSignUpReq: socialSignUpReq, loginMobileNo: nil, _delegate: phoneVerificationVC, flowType: .comingFromSignUp)
            self.navigationController?.pushViewController(phoneVerificationVC, animated: true)
        case .failure(let error) :
            self.baseView.handleAPIResponse(isSuccess: false, errorMsg: error.localizedDescription)
        }
    }
    
    func showMergingAlert() {
        self.baseView.handleAPIResponse(isSuccess: false, errorMsg: nil, showMergeConflict: true)
    }
    
}
