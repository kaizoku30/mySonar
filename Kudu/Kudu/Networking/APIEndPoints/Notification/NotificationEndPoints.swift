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
	}
}
