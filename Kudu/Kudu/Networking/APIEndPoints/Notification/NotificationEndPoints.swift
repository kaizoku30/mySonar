//
//  NotificationEndPoints.swift
//  Kudu
//
//  Created by Admin on 15/09/22.
//

import Foundation

extension APIEndPoints {
	final class NotificationEndPoints {
		static func setNotificationPref(req: NotificationPrefRequest, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .notificationPref(req: req), successHandler: success, failureHandler: failure)
		}
        
        static func getNotifications(page: Int, limit: Int, success: @escaping SuccessCompletionBlock<NotificationResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .notificationList(pageNo: page, limit: limit), successHandler: success, failureHandler: failure)
        }
        
        static func deleteNotification(id: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .deleteNotification(id: id), successHandler: success, failureHandler: failure)
        }
        
        static func deleteAllNotifications(success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .deleteAllNotification, successHandler: success, failureHandler: failure)
        }
        
	}
}
