//
//  PhoneVerificationVC.swift
//  Kudu
//
//  Created by Admin on 17/05/22.
//

import UIKit
import WebKit
import OTPFieldView

class PhoneVerificationVC: BaseVC {
    @IBOutlet private weak var baseView: PhoneVerificationView!
    var viewModel: PhoneVerificationVM?
    var differentEmailPressed: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.setupView(mobileNum: viewModel?.getMobileNumber ?? "", email: viewModel?.getEmailForVerification)
        if viewModel?.getCurrentFlow == .comingFromChangeNumberFlow {
            baseView.setupView(mobileNum: viewModel?.getChangeRequest?.mobileNo ?? "", email: nil)
        }
        handleActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.baseView.focusOTP()
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            switch $0 {
            case .verifyButtonPressed(let otpString):
                debugPrint(otpString)
                strongSelf.baseView.handleAPIRequest(.verifyMobileOtpAPI)
                if viewModel.getCurrentFlow == .comingFromEditProfile || viewModel.getCurrentFlow == .comingFromProfilePage {
                    strongSelf.viewModel?.verifyEmailOTP(otpString: otpString)
                } else {
                    strongSelf.viewModel?.verifyMobileOTP(otpString)
                }
            case  .resendOtpPressed:
                strongSelf.baseView.handleAPIRequest(.resendOtp)
                strongSelf.viewModel?.resendOTP()
            case .dismissVC:
                NotificationCenter.postNotificationForObservers(.clearSignUpFormPhoneField)
                NotificationCenter.postNotificationForObservers(.resetLoginState)
                strongSelf.pop()
            case .differentLabelPressed:
                strongSelf.pop()
                strongSelf.differentEmailPressed?()
            }
        }
    }
}

extension PhoneVerificationVC: PhoneVerificationVMDelegate {
    
    func verifyEmailAPIResponse(responseType: Result<String, Error>, flowType: PhoneVerificationVM.PhoneVerificationFlow) {
        switch responseType {
        case .success(let result):
            debugPrint(result)
            self.baseView.handleAPIResponse(.verifyMobileOtpAPI, isSuccess: true, errorMsg: nil)
            DataManager.shared.loginResponse?.isEmailVerified = true
            NotificationCenter.postNotificationForObservers(.updateProfilePage)
            if viewModel?.isAddCardFlow ?? false {
                self.pop()
                return
            }
            self.popToSpecificViewController(kindOf: ProfileVC.self)
            if self.navigationController?.viewControllers.contains(where: { $0.isKind(of: ProfileVC.self)}) == false {
                self.pop()
            }
        case .failure(let error):
            self.baseView.handleAPIResponse(.verifyMobileOtpAPI, isSuccess: false, errorMsg: error.localizedDescription)
        }
    }
    
    func verifyMobileAPIResponse(responseType: Result<LoginUserData?, Error>) {
        switch responseType {
        case .success(let result):
            debugPrint(result ?? "")
            self.baseView.handleAPIResponse(.verifyMobileOtpAPI, isSuccess: true, errorMsg: nil)
            DataManager.shared.loginResponse = result
            DataManager.encodeAndSaveObject(result!, key: .loginResponse)
            AppUserDefaults.removeGuestUserData()
            Router.shared.configureTabBar()
        case .failure(let error):
            self.baseView.handleAPIResponse(.verifyMobileOtpAPI, isSuccess: false, errorMsg: error.localizedDescription)
            debugPrint(error)
        }
    }
    
    func changeNumberAPIResponse(responseType: Result<Bool, Error>) {
        switch responseType {
        case .success:
            self.baseView.handleAPIResponse(.verifyMobileOtpAPI, isSuccess: true, errorMsg: nil)
            DataManager.shared.loginResponse = nil
            AppUserDefaults.removeUserData()
            mainThread {
                Router.shared.goToLoginVC(fromVC: nil)
            }
        case .failure(let error):
            self.baseView.handleAPIResponse(.verifyMobileOtpAPI, isSuccess: false, errorMsg: error.localizedDescription)
            debugPrint(error)
        }
    }
}
