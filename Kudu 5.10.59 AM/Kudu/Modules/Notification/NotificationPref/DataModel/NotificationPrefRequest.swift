//
//  NotificationPrefRequest.swift
//  Kudu
//
//  Created by Admin on 09/08/22.
//

import Foundation

struct NotificationPrefRequest {
    var isPushNotify: Bool
    var isLoyaltyProgram: Bool
    var isMuteNotify: Bool
    var isOrderPurchase: Bool
    var isPromoOffers: Bool
    
    init() {
        let notificationSetting = DataManager.shared.loginResponse?.notificationSetting
        isPushNotify = notificationSetting?.isPushNotify ?? true
        isLoyaltyProgram = notificationSetting?.isLoyaltyProgram ?? true
        isMuteNotify = notificationSetting?.isMuteNotify ?? true
        isOrderPurchase = notificationSetting?.isOrderPurchase ?? true
        isPromoOffers = notificationSetting?.isPromoOffers ?? true
    }
    
    func getRequestObject() -> [String: Any] {
        var json: [String: Any] = [:]
        json[Constants.APIKeys.isPushNotify.rawValue] = isPushNotify
        json[Constants.APIKeys.isLoyaltyProgram.rawValue] = isLoyaltyProgram
        json[Constants.APIKeys.isMuteNotify.rawValue] = isMuteNotify
        json[Constants.APIKeys.isOrderPurchase.rawValue] = isOrderPurchase
        json[Constants.APIKeys.isPromoOffers.rawValue] = isPromoOffers
        return json
    }
    
    func saveToLoginResponse() {
        let updatedSetting = NotificationSettingData(isPromoOffers: self.isPromoOffers, isMuteNotify: self.isMuteNotify, isOrderPurchase: self.isOrderPurchase, isLoyaltyProgram: self.isLoyaltyProgram, isPushNotify: self.isPushNotify)
        DataManager.shared.loginResponse?.notificationSetting = updatedSetting
    }
}
