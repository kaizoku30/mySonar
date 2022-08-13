//
//  SocialLoginResponse.swift
//  Kudu
//
//  Created by Admin on 30/06/22.
//

import Foundation

struct SocialLoginResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: LoginUserData?
}
