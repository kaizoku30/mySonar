//
//  LoginVM.swift
//  Kudu
//
//  Created by Admin on 27/06/22.
//

import Foundation
import FBSDKLoginKit

protocol LoginVMDelegate: AnyObject {
    func loginAPIResponse(responseType: Result<String, Error>)
    func socialAPIResponse(isSuccess: Bool, socialSignUpRequest: SocialSignUpRequest?, errorMsg: String?)
}

class LoginVM {
    
    private let webService = WebServices.OnboardingEndPoints.self
    private weak var delegate: LoginVMDelegate?
    private var socialSignUpRequest: SocialSignUpRequest?
    private var expiryError: String?
    private var backButtonVisible = false
    private var flow: Flow = .comingFromGuestUser
    var getExpiryError: String? { expiryError }
    var getCurrentFlow: Flow { flow }
    
    enum Flow {
        case comingFromGuestUser
        case comingFromLoggedInUser
    }
    
    init(delegate: LoginVMDelegate, flow: Flow, _expiryError: String? = nil) {
        self.delegate = delegate
        self.expiryError = _expiryError
        self.flow = flow
    }
    
    func getOtp(_ mobileNumber: String) {
        webService.login(mobileNo: mobileNumber, success: {
            debugPrint($0)
            self.delegate?.loginAPIResponse(responseType: .success($0.message ?? ""))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.loginAPIResponse(responseType: .failure(error))
        })
    }
    
    func socialLogin(_ loginType: SocialLoginType, socialId: String, signUpRequestObject: SocialSignUpRequest, fbToken: FBSDKCoreKit.AccessToken? = nil) {
        webService.socialLogin(socialLoginType: loginType, socialId: socialId, success: { [weak self] (response) in
            debugPrint(response.message ?? "")
            DataManager.shared.loginResponse = response.data
            self?.delegate?.socialAPIResponse(isSuccess: true, socialSignUpRequest: nil, errorMsg: nil)
        }, failure: { [weak self] (error) in
            debugPrint(error.msg)
            self?.socialSignUpRequest = signUpRequestObject
            if loginType == .facebook && fbToken.isNotNil {
                self?.requestFacebookUserDetails(fbToken!)
                return
            }
            self?.delegate?.socialAPIResponse(isSuccess: false, socialSignUpRequest: self?.socialSignUpRequest, errorMsg: error.msg)
        })
    }
    
    private func requestFacebookUserDetails(_ fbToken: FBSDKCoreKit.AccessToken) {
        debugPrint("Requesting Data From Facebook")
        FacebookEmailRequestManager.requestEmailAndNameFromFB(accessToken: fbToken, success: { [weak self] (response) in
            debugPrint("Received Data From Facebook")
            self?.delegate?.socialAPIResponse(isSuccess: false, socialSignUpRequest: response, errorMsg: "")
        }, failure: { [weak self] (error) in
            debugPrint("Did not receive data from Facebook")
            self?.delegate?.socialAPIResponse(isSuccess: false, socialSignUpRequest: self?.socialSignUpRequest, errorMsg: error)
        })
    }
}
