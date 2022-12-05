//
//  EditProfileVM.swift
//  Kudu
//
//  Created by Admin on 10/08/22.
//

import Foundation

protocol EditProfileVMDelegate: AnyObject {
    func editProfileAPIResponse(responseType: Result<Bool, Error>)
}

class EditProfileVM {
    private let webService = APIEndPoints.HomeEndPoints.self
    private weak var delegate: EditProfileVMDelegate?

    private var name: String = DataManager.shared.loginResponse?.fullName ?? ""
    private let phoneNum: String = DataManager.shared.loginResponse?.mobileNo ?? ""
    private var email: String = DataManager.shared.loginResponse?.email ?? ""
    private var handleEmailConflict: Bool = false
    
    var getName: String { name }
    var getPhoneNum: String { phoneNum }
    var getEmail: String { email }
    var toHandleEmailConflict: Bool { handleEmailConflict }
    
    init(delegate: EditProfileVMDelegate, handleEmailConflict: Bool = false) {
        self.delegate = delegate
        self.handleEmailConflict = handleEmailConflict
    }
    
    func update(name: String?, email: String?) {
        if let name = name {
            self.name = name
        }
        
        if let email = email {
            self.email = email
        }
    }
    
    func validateData() -> (validData: Bool, errorMsg: String?) {
        if getEmail.isEmpty == false, CommonValidation.isValidEmail(getEmail) == false {
            return (false, LSCollection.SignUp.pleaseEnterValidEmail)
        }
        if getName.isEmpty {
            return (false, LSCollection.SignUp.pleaseEnterFullName)
        }
        if CommonValidation.isValidName(getName) == false {
            return (false, LSCollection.SignUp.pleaseEnterValidFullName)
        }
        return (true, nil)
    }
    
    func hitUpdateAPI() {
        let triggerVerificationFlow = getEmail != DataManager.shared.loginResponse?.email ?? "" || (DataManager.shared.loginResponse?.isEmailVerified ?? false) == false
        webService.updateProfile(name: getName, email: triggerVerificationFlow ? getEmail : nil, success: { [weak self] _ in
            DataManager.shared.loginResponse?.email = self?.getEmail ?? ""
            DataManager.shared.loginResponse?.fullName = self?.getName ?? ""
            if triggerVerificationFlow {
                DataManager.shared.loginResponse?.isEmailVerified = false
            }
            self?.delegate?.editProfileAPIResponse(responseType: .success(triggerVerificationFlow))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.editProfileAPIResponse(responseType: .failure(error))
        })
    }
    
}
