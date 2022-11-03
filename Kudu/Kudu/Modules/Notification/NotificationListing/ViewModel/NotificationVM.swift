//
//  NotificationVM.swift
//  Kudu
//
//  Created by Admin on 01/08/22.
//

import Foundation
struct NotificationData {
    var notificationTitle: String?
    var notificationDate: String?
}

protocol NotificationVMDlegate: AnyObject {
    func updateList(list: [NotificationList])
    func deleteNotification(message: String, indexPath: IndexPath)
    func error(message: String)
}

class NotificationVM {
    
    var allNotifications: [NotificationList] = []
    var notificationData: NotificationModel?
    var total: Int = 0
    weak var delegate: NotificationVMDlegate?
    
    func fetchNotifications(page: Int, limit: Int) {
        APIEndPoints.NotificationEndPoints.getNotifications(page: page, limit: limit) { response in
            self.notificationData = response.data
            if let data = response.data?.data {
                if page == 1 {
                self.allNotifications = data
                } else {
                    self.allNotifications += data
                }
                self.total = response.data?.total ?? 0
                self.delegate?.updateList(list: self.allNotifications)
            }
        } failure: { status in
            self.delegate?.error(message: status.msg)
        }
    }
    
    func deleteNotification(id: String, indexPath: IndexPath, success: @escaping SuccessCompletionBlock<EmptyDataResponse>) {
        APIEndPoints.NotificationEndPoints.deleteNotification(id: id) { response in
            success(response)
        } failure: { status in
            self.delegate?.error(message: status.msg)
        }

    }
    
    func deleteAllNotifications(success: @escaping SuccessCompletionBlock<EmptyDataResponse>) {
        APIEndPoints.NotificationEndPoints.deleteAllNotifications { response in
            success(response)
        } failure: { status in
            self.delegate?.error(message: status.msg)
        }

    }
}
