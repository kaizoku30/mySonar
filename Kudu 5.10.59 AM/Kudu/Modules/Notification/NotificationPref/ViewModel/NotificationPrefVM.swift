//
//  NotificationPrefVM.swift
//  Kudu
//
//  Created by Admin on 09/08/22.
//

import Foundation

protocol NotificationPrefVMDelegate: AnyObject {
    func prefAPIResponse(responseType: Result<String, Error>)
}

class NotificationPrefVM {
    private let webService = WebServices.NotificationEndPoints.self
    private weak var delegate: NotificationPrefVMDelegate?
    private var prefRequest: NotificationPrefRequest = NotificationPrefRequest()
    
    init(delegate: NotificationPrefVMDelegate) {
        self.delegate = delegate
    }
    
    func updatePref(type: NotificationPrefView.NotificationPrefType, value: Bool) {
        switch type {
        case .promosOffers:
            prefRequest.isPromoOffers = value
        case .orderPurchase:
            prefRequest.isOrderPurchase = value
        case .loyaltyProgram:
            prefRequest.isLoyaltyProgram = value
        case .pushNotifications:
            prefRequest.isPushNotify = value
        case .muteNotification:
            prefRequest.isMuteNotify = value
        }
    }
    
    func getPref(type: NotificationPrefView.NotificationPrefType) -> Bool {
        switch type {
        case .promosOffers:
            return prefRequest.isPromoOffers
        case .orderPurchase:
            return prefRequest.isOrderPurchase
        case .loyaltyProgram:
            return prefRequest.isLoyaltyProgram
        case .pushNotifications:
            return prefRequest.isPushNotify
        case .muteNotification:
            return prefRequest.isMuteNotify
        }
    }
    
    func updateSettingsOnServer() {
        webService.setNotificationPref(req: prefRequest, success: { [weak self] (response) in
            self?.prefRequest.saveToLoginResponse()
            self?.delegate?.prefAPIResponse(responseType: .success(response.message ?? ""))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.prefAPIResponse(responseType: .failure(error))
        })
    }
}
