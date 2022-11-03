//
//  EditProfileVC.swift
//  Kudu
//
//  Created by Admin on 10/08/22.
//

import UIKit

class EditProfileVC: BaseVC {
    @IBOutlet private var baseView: EditProfileView!
    var viewModel: EditProfileVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleActions()
        if let viewModel = viewModel {
            baseView.setupView(name: viewModel.getName, phoneNum: viewModel.getPhoneNum, email: viewModel.getEmail)
            if viewModel.toHandleEmailConflict == true {
                baseView.handleEmailConflict()
            }
        }
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] (action) in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            switch action {
            case .editPhoneNumberFlow:
                let vc = ChangePhoneNumberVC.instantiate(fromAppStoryboard: .Setting)
                self?.push(vc: vc)
            case .backButtonPressed:
                strongSelf.pop()
            case .nameUpdated(let updatedText):
                strongSelf.viewModel?.update(name: updatedText, email: nil)
            case .emailUpdated(let updatedText):
                strongSelf.viewModel?.update(name: nil, email: updatedText)
            case .updateProfile:
                let validation = viewModel.validateData()
                if validation.validData == false {
                    strongSelf.baseView.showError(msg: validation.errorMsg ?? "")
                    return
                }
                strongSelf.baseView.handleAPIRequest()
                strongSelf.viewModel?.hitUpdateAPI()
            }
        }
    }
}

extension EditProfileVC: EditProfileVMDelegate {
    func editProfileAPIResponse(responseType: Result<Bool, Error>) {
        switch responseType {
        case .success(let triggerEmailFlow):
            NotificationCenter.postNotificationForObservers(.updateProfilePage)
            self.baseView.handleAPIResponse(errorMsg: nil, errorCode: nil)
            if triggerEmailFlow, let email = viewModel?.getEmail, email.isEmpty == false {
                debugPrint("Need to trigger verify email flow")
                NotificationCenter.postNotificationForObservers(.updateProfilePage)
                let vc = PhoneVerificationVC.instantiate(fromAppStoryboard: .Onboarding)
                vc.viewModel = PhoneVerificationVM(_delegate: vc, flowType: .comingFromEditProfile, emailForVerification: email)
                vc.differentEmailPressed = { [weak self] in
                    self?.baseView.handleEmailConflict()
                }
                self.push(vc: vc)
                return
            }
            self.pop()
        case .failure(let error):
            self.baseView.handleAPIResponse(errorMsg: error.localizedDescription, errorCode: (error as NSError).code)
        }
    }
}
