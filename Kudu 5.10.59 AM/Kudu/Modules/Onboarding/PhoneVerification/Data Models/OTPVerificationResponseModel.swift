//
//  OTPVerificationResponseModel.swift
//  Kudu
//
//  Created by Admin on 28/06/22.
//

import Foundation

struct OTPVerificationResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: LoginUserData?
}

struct LoginUserData: Codable {
    let mobileNo: String?
    let countryCode: String?
    let accessToken: String?
    var isEmailVerified: Bool?
    let userId: String?
    var email: String?
    var fullName: String?
    var notificationSetting: NotificationSettingData?
}

struct NotificationSettingData: Codable {
    let isPromoOffers: Bool?
    let isMuteNotify: Bool?
    let isOrderPurchase: Bool?
    let isLoyaltyProgram: Bool?
    let isPushNotify: Bool?
}
