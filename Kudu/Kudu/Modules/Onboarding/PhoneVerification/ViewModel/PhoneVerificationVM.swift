//
//  PhoneVerificationVM.swift
//  Kudu
//
//  Created by Admin on 27/06/22.
//

import Foundation

protocol PhoneVerificationVMDelegate: AnyObject {
    func verifyMobileAPIResponse(responseType: Result<LoginUserData?, Error>)
    func verifyEmailAPIResponse(responseType: Result<String, Error>, flowType: PhoneVerificationVM.PhoneVerificationFlow)
}

class PhoneVerificationVM {
    
    enum PhoneVerificationFlow {
        case comingFromSignUp
        case comingFromLogin
        case comingFromEditProfile
        case comingFromProfilePage
    }
    
    private var signUpRequest: SignUpRequest?
    private var socialSignUpRequest: SocialSignUpRequest?
    private weak var delegate: PhoneVerificationVMDelegate?
    private var flow: PhoneVerificationFlow = .comingFromLogin
    private let webService = APIEndPoints.OnboardingEndPoints.self
    private var loginMobileNumber: String?
    private var emailForVerification: String?
    var getEmailForVerification: String? { emailForVerification }
    var getCurrentFlow: PhoneVerificationFlow { self.flow }
    var getMobileNumber: String {
        if flow == .comingFromSignUp {
            if self.socialSignUpRequest.isNotNil {
                return self.socialSignUpRequest?.mobileNum ?? ""
            }
            return self.signUpRequest?.mobileNum ?? ""
        } else {
            return self.loginMobileNumber ?? ""
        } }
    
    init(_signUpReq: SignUpRequest? = nil, _socialSignUpReq: SocialSignUpRequest? = nil, loginMobileNo: String? = nil, _delegate: PhoneVerificationVMDelegate, flowType: PhoneVerificationFlow, emailForVerification: String? = nil) {
        self.signUpRequest = _signUpReq
        self.delegate = _delegate
        self.flow = flowType
        self.loginMobileNumber = loginMobileNo
        self.socialSignUpRequest = _socialSignUpReq
        self.emailForVerification = emailForVerification
    }
    
    func verifyMobileOTP(_ otp: String) {
        if flow == .comingFromSignUp {
            
            if self.socialSignUpRequest.isNotNil {
                verifySocialOTP(otp)
                return
            }
            guard let signUpRequest = signUpRequest else {
                return
            }
            webService.verifyMobileOtp(signUpRequest: signUpRequest, mobileOtp: otp, success: { [weak self] in
                debugPrint($0)
                self?.delegate?.verifyMobileAPIResponse(responseType: .success($0.data))
            }, failure: { [weak self] in
                let error = NSError(code: $0.code, localizedDescription: $0.msg)
                self?.delegate?.verifyMobileAPIResponse(responseType: .failure(error))
            })
        } else {
            webService.verifyMobileOtpLogin(mobileNum: self.getMobileNumber, mobileOtp: otp, success: { [weak self] in
                debugPrint($0)
                self?.delegate?.verifyMobileAPIResponse(responseType: .success($0.data))
            }, failure: { [weak self] in
                let error = NSError(code: $0.code, localizedDescription: $0.msg)
                self?.delegate?.verifyMobileAPIResponse(responseType: .failure(error))
            })
        }
    }
    
    private func verifySocialOTP(_ otp: String) {
        guard let signUpRequest = socialSignUpRequest else {
            return
        }
        webService.socialVerification(signUpReq: signUpRequest, otp: otp, success: { [weak self] in
            debugPrint($0)
            self?.delegate?.verifyMobileAPIResponse(responseType: .success($0.data))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.verifyMobileAPIResponse(responseType: .failure(error))
        })
    }
    
    func resendOTP() {
        if let emailForVerification = emailForVerification {
            APIEndPoints.HomeEndPoints.sendOtpOnMail(email: emailForVerification, success: { _ in
                //No implementation needed
            }, failure: { _ in
                //No implementation needed
            })
            return
        }
        let mobileNo = self.getMobileNumber
        let email = self.signUpRequest?.email
        webService.sendOtp(mobileNo: mobileNo, email: email, success: { _ in
            //No implementation needed
        }, failure: { _ in
            //No implementation needed
        })
    }
    
    func verifyEmailOTP(otpString: String) {
        guard let emailForVerification = emailForVerification else {
            return
        }
        APIEndPoints.HomeEndPoints.verifyEmailOtp(otp: otpString, email: emailForVerification, success: { [weak self] in
            self?.delegate?.verifyEmailAPIResponse(responseType: .success($0.message ?? ""), flowType: self?.flow ?? .comingFromEditProfile)
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.verifyEmailAPIResponse(responseType: .failure(error), flowType: self?.flow ?? .comingFromEditProfile)
        })
    }
}
