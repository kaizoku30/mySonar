//
//  FacebookEmailRequestManager.swift
//  Kudu
//
//  Created by Admin on 30/06/22.
//

import Foundation
import FBSDKCoreKit

class FacebookEmailRequestManager {
    static func requestEmailAndNameFromFB(accessToken: FBSDKCoreKit.AccessToken, success: @escaping (SocialSignUpRequest) -> Void, failure: @escaping (String) -> Void ) {
        let req = GraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name"], tokenString: accessToken.tokenString, version: nil, httpMethod: .get)
        req.start { (_, result, error) in
            if error.isNil {
                print("result \(String(describing: result))")
                if let dic = result as? [String: Any] {
                    let email = dic["email"] as? String ?? ""
                    let firstName = dic["first_name"] as? String ?? ""
                    let lastName = dic["last_name"] as? String ?? ""
                    let socialId = dic["id"] as? String ?? ""
                    let signUpRequest = SocialSignUpRequest(socialId: socialId, email: email, name: firstName + " " + lastName, mobileNum: nil, socialLoginType: .facebook)
                    success(signUpRequest)
                    } else {
                    failure("No data found")
                    }
                } else {
                    failure(error?.localizedDescription ?? "")
            }
        }
    }
}
