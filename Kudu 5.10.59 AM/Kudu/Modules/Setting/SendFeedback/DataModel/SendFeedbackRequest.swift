//
//  SendFeedbackRequest.swift
//  Kudu
//
//  Created by Admin on 22/07/22.
//

import Foundation

struct SendFeedbackRequest {
    let name: String
    let phoneNumber: String
    let countryCode: String = "966"
    let email: String?
    let feedback: String
    let image: String?
    
    func getRequestJson() -> [String: Any] {
        let key = Constants.APIKeys.self
        var json: [String: Any] = [key.name.rawValue: name,
                                   key.phoneNumber.rawValue: phoneNumber,
                                   key.countryCode.rawValue: countryCode,
                                   key.feedback.rawValue: feedback]
        
        if let email = email, email.isEmpty == false {
            json[key.email.rawValue] = email
        }
        if let image = image, image.isEmpty == false {
            json[key.image.rawValue] = image
        }
        return json
    }
}
