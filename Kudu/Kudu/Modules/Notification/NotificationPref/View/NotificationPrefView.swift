//
//  NotificationPrefView.swift
//  Kudu
//
//  Created by Admin on 09/08/22.
//

import UIKit

class NotificationPrefView: UIView {
    
    @IBOutlet private weak var saveChangesButton: AppButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var notificationTitleLabel: UILabel!

    @IBAction private func backButtonPressed(_ sender: Any) {
        self.handleViewActions?(.backButtonPressed)
    }
    @IBAction private func saveChangesPressed(_ sender: Any) {
        self.handleViewActions?(.updateSettings)
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    
    enum NotificationPrefType: Int, CaseIterable {
        case pushNotifications = 0
        case muteNotification
//        case loyaltyProgram
        case orderPurchase
        case promosOffers
        
        var title: String {
            switch self {
            case .pushNotifications:
                return LSCollection.NotificationPref.pushNotifications
            case .muteNotification:
                return LSCollection.NotificationPref.muteNotification
//            case .loyaltyProgram:
//                return LocalizedStrings.NotificationPref.loyaltyProgram
            case .orderPurchase:
                return LSCollection.NotificationPref.orderPurchase
            case .promosOffers:
                return LSCollection.NotificationPref.promosOffers
            }
        }
        
        var subtitle: String {
            switch self {
            case .pushNotifications:
                return LSCollection.NotificationPref.pushNotificationsSubtitle
            case .muteNotification:
                return LSCollection.NotificationPref.muteNotificationSubtitle
//            case .loyaltyProgram:
//                return LocalizedStrings.NotificationPref.loyaltyProgramSubtitle
            case .orderPurchase:
                return LSCollection.NotificationPref.orderPurchaseSubtitle
            case .promosOffers:
                return LSCollection.NotificationPref.promosOffersSubtitle
            }
        }
    }
    
    enum ViewActions {
        case updateSettings
        case backButtonPressed
    }
    
    enum APICalled {
        case notificationPrefAPI
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notificationTitleLabel.text = LSCollection.Profile.notificationPref
    }
}

extension NotificationPrefView {
    func handleAPIRequest(_ api: APICalled) {
        mainThread({
            self.tableView.isUserInteractionEnabled = false
            self.saveChangesButton.startBtnLoader(color: .white)
        })
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, errorMsg: String?) {
        mainThread {
            self.tableView.isUserInteractionEnabled = true
            if let errorMsg = errorMsg {
                self.saveChangesButton.stopBtnLoader(titleColor: .white)
                let error = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
                error.show(message: errorMsg, view: self)
                return
            }
            self.handleViewActions?(.backButtonPressed)
        }
    }
}
