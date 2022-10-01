//
//  SignUpVM.swift
//  Kudu
//
//  Created by Admin on 27/06/22.
//

import Foundation

protocol SignUpVMDelegate: AnyObject {
    func signUpAPIResponse(responseType: Result<String, Error>)
    func socialSignUpAPIResponse(responseType: Result<String, Error>)
    func showMergingAlert()
}

class SignUpVM {
    private let webService = APIEndPoints.OnboardingEndPoints.self
    private weak var delegate: SignUpVMDelegate?
    private var socialSignUpRequest: SocialSignUpRequest?
    
    var getSocialData: SocialSignUpRequest? { socialSignUpRequest }
    
    init(_delegate: SignUpVMDelegate, _socialSignUpReq: SocialSignUpRequest? = nil) {
        self.delegate = _delegate
        if _socialSignUpReq.isNotNil {
            self.socialSignUpRequest = _socialSignUpReq
        }
    }
    
    func signUp(name: String, phoneNum: String, email: String?) {
        webService.signUp(name: name, mobileNo: phoneNum, email: email, success: { [weak self] in
            let response = $0
            self?.delegate?.signUpAPIResponse(responseType: .success(response.message ?? ""))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.signUpAPIResponse(responseType: .failure(error))
        })
    }
    
    func socialSignUp(name: String, phoneNum: String, email: String?) {
        let dataPresent = self.socialSignUpRequest
        if let socialID = dataPresent?.socialId, let socialType = dataPresent?.socialLoginType {
            self.socialSignUpRequest = SocialSignUpRequest(socialId: socialID, email: email, name: name, mobileNum: phoneNum, socialLoginType: socialType)
            webService.socialSignUp(signUpReq: self.socialSignUpRequest!, success: { [weak self] in
                let response = $0
                self?.delegate?.socialSignUpAPIResponse(responseType: .success(response.message ?? ""))
            }, failure: { [weak self] in
                let error = NSError(code: $0.code, localizedDescription: $0.msg)
                if error.code == 409 {
                    self?.delegate?.showMergingAlert()
                    return
                }
                self?.delegate?.socialSignUpAPIResponse(responseType: .failure(error))
                
            })
        }
       
    }
    
    func resendOTP(phoneNumber: String, email: String?) {
        webService.sendOtp(mobileNo: phoneNumber, email: email, success: { [weak self] in
            self?.delegate?.socialSignUpAPIResponse(responseType: .success($0.message ?? ""))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.socialSignUpAPIResponse(responseType: .failure(error))
        })
    }
    
    func validateData(name: String, phoneNum: String, email: String?) -> ValidationResult {
        let errors = LocalizedStrings.SignUp.self
        if name.isEmpty {
            return (false, errors.pleaseEnterFullName)
        }
        if !CommonValidation.isValidName(name) {
            return (false, errors.pleaseEnterValidFullName)
        }
        if phoneNum.isEmpty {
            return (false, errors.pleaseEnterPhoneNumber)
        }
        if !CommonValidation.isValidPhoneNumber(phoneNum) {
            return (false, errors.pleaseEnterValidPhoneNumber)
        }
        if let emailEntered = email, !CommonValidation.isValidEmail(emailEntered) {
            return (false, errors.pleaseEnterValidEmail)
        }
        return (true, "")
    }
}
