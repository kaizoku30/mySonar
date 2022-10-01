//
//  SocialSignUpRequest.swift
//  Kudu
//
//  Created by Admin on 30/06/22.
//

import Foundation

struct SocialSignUpRequest {
    let socialId: String
    let email: String?
    let name: String?
    let mobileNum: String?
    let socialLoginType: SocialLoginType
}
