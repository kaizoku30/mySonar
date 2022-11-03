//
//  ChangePhoneNumberRequest.swift
//  Kudu
//
//  Created by Admin on 28/10/22.
//

import Foundation

struct ChangePhoneNumberRequest {
    let mobileNo: String
    let countryCode: String = "966"
    var isSendOtp: Bool
    var mobileOTP: String = ""
    
    func getRequest() -> [String: Any] {
        var params: [String: Any] = [Constants.APIKeys.mobileNo.rawValue: mobileNo,
                                     Constants.APIKeys.countryCode.rawValue: countryCode,
                                     Constants.APIKeys.isSendOtp.rawValue: isSendOtp]
        if !isSendOtp {
            params[Constants.APIKeys.mobileOtp.rawValue] = mobileOTP
        }
        return params
    }
}
