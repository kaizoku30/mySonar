//
//  AppDelegate.swift
//  Kudu
//
//  Created by Admin on 26/04/22.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleSignIn
import FBSDKCoreKit
import GoogleMaps
import SwiftLocation
import DropDown

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(Constants.GooglePaidAPIKey.apiKey)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarTintColor = .black
        AWSUploadController.setupAmazonS3(withPoolID: Constants.S3BucketCredentials.s3PoolApiKey)
        ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions
                )
		configureUserNotifications()
        CartUtility.logStart()
        NotificationScheduler.requestAuthorization(completion: {
            if $0 {
                self.configureUserNotifications()
            }
        })
        DropDown.startListeningToKeyboard()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleCartNotification()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        scheduleCartNotification()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        scheduleCartNotification()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationScheduler.removeScheduledNotification(type: .idleCartReminder)
    }
    
    private func scheduleCartNotification() {
        if CartUtility.fetchCart().count > 0 {
            let timeForNotif = DataManager.shared.currentCartConfig?.notificationWaitTime ?? 0
            NotificationScheduler.scheduleNotification(type: .idleCartReminder, timeInterval: Double(timeForNotif*60))
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
          let googleHandled: Bool = GIDSignIn.sharedInstance.handle(url)
          if googleHandled {
            return true
          }
        return  ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
	
	private func configureUserNotifications() {
		UNUserNotificationCenter.current().delegate = self
	}
	
	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		willPresent notification: UNNotification,
		withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void
	) {
        if notification.request.identifier == "CART_REMINDER" && CartUtility.fetchCart().isEmpty == false {
            let timeForNotif = DataManager.shared.currentCartConfig?.notificationWaitTime ?? 0
            NotificationScheduler.scheduleNotification(type: .idleCartReminder, timeInterval: Double(timeForNotif*60))
        }
	}
}
