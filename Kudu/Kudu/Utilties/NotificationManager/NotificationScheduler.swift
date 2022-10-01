//
//  NotificationManager.swift
//  Kudu
//
//  Created by Admin on 12/09/22.
//

import Foundation
import UserNotifications

struct NotificationTask {
	let id: String
	let title: String
    let body: String
	let timeInterval: Double
}

enum NotificationTaskType {
    case idleCartReminder
    var id: String {
        switch self {
        case .idleCartReminder:
            return "CART_REMINDER"
        }
    }
    var title: String {
        switch self {
        case .idleCartReminder:
            return "Your Cart is waiting for you."
        }
    }
    var body: String {
        switch self {
        case .idleCartReminder:
            return "Seems like there are few items in your cart. Order them now, before it vanishes from your cart."
        }
    }
}

final class NotificationScheduler {
	static func requestAuthorization(completion: @escaping  (Bool) -> Void) {
		UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, _  in
				completion(granted)
			}
	}
	
    static func scheduleNotification(type: NotificationTaskType, timeInterval: Double) {
        debugPrint("Notification Scheduled from \(Date().toString(dateFormat: "HH:mm")), will hit after : \(timeInterval/60) minutes")
        removeScheduledNotification(type: type)
		let content = UNMutableNotificationContent()
		content.title = type.title
        content.body = type.body
		
		// 3
		var trigger: UNNotificationTrigger?
        if timeInterval == 0 { return }
		trigger = UNTimeIntervalNotificationTrigger(
			timeInterval: timeInterval,
			repeats: false)
		// 4
		if let trigger = trigger {
			let request = UNNotificationRequest(
				identifier: type.id,
				content: content,
				trigger: trigger)
			// 5
			UNUserNotificationCenter.current().add(request) { error in
				if let error = error {
					print(error)
				}
			}
		}
	}
	
    static func removeScheduledNotification(type: NotificationTaskType) {
		UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [type.id])
	}
}
