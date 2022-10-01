//
//  SettingsVM.swift
//  Kudu
//
//  Created by Admin on 07/08/22.
//

import Foundation

protocol SettingsVMDelegate: AnyObject {
    func logoutAPIResponse(responseType: Result<String, Error>)
    func deleteAPIResponse(responseType: Result<String, Error>)
}

class SettingVM {
    
    private weak var delegate: SettingsVMDelegate?
    var isGuestUser: Bool { AppUserDefaults.value(forKey: .loginResponse) == nil }
    
    init(delegate: SettingsVMDelegate) {
        self.delegate = delegate
    }
    
    func hitLogoutAPI() {
        APIEndPoints.SettingsEndPoints.logout(success: { [weak self] _ in
            self?.delegate?.logoutAPIResponse(responseType: .success("Logout success"))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.logoutAPIResponse(responseType: .failure(error))
        })
    }
    
    func hitDeleteAPI() {
        APIEndPoints.SettingsEndPoints.deleteAccount(success: { [weak self] _ in
            self?.delegate?.deleteAPIResponse(responseType: .success("Delete success"))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.deleteAPIResponse(responseType: .failure(error))
        })
    }
}
