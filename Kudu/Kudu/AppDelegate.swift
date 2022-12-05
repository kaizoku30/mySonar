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
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initialSetup(application, didFinishLaunchingWithOptions: launchOptions)
        setupForNotifications(application, launchOptions: launchOptions)
        locationSetup()
        return true
    }
    
    private func initialSetup(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        GMSServices.provideAPIKey(Constants.GooglePaidAPIKey.apiKey)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarTintColor = .black
        AWSUploadController.setupAmazonS3(withPoolID: Constants.S3BucketCredentials.s3PoolApiKey)
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        CartUtility.logStart()
        DropDown.startListeningToKeyboard()
    }
    
    private func setupForNotifications(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        NotificationScheduler.requestAuthorization(completion: {
            if $0 {
                self.configureUserNotifications()
            }
        })
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        if launchOptions.isNotNil {
            let notification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] ?? [:]
            debugPrint("Launched from notification")
            debugPrint(notification)
        }
    }
    
}

extension AppDelegate {
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
}

extension AppDelegate {
    // MARK: Google Handling
    
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

extension AppDelegate {
    // MARK: Location Handling
    private func locationSetup() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationFound = locations.first {
            debugPrint("LOCATION FOUND IN APP DELEGATE")
            CommonLocationManager.updateLocation(locationFound.coordinate)
            locationManager.stopUpdatingLocation()
        }
    }
    
    private func scheduleCartNotification() {
        if CartUtility.fetchCartLocally().count > 0 {
            let timeForNotif = DataManager.shared.currentCartConfig?.notificationWaitTime ?? 0
            NotificationScheduler.scheduleNotification(type: .idleCartReminder, timeInterval: Double(timeForNotif*60))
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    // MARK: Notification Handling
    private func configureUserNotifications() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
      print(userInfo)
      return UIBackgroundFetchResult.newData
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                DataManager.shared.setfcmToken(token: token)
            }
        }
    }
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        
        debugPrint("NOTIFICATION RECEIVED")
        
        if notification.request.identifier == "CART_REMINDER" && CartUtility.fetchCartLocally().isEmpty == false {
            let timeForNotif = DataManager.shared.currentCartConfig?.notificationWaitTime ?? 0
            NotificationScheduler.scheduleNotification(type: .idleCartReminder, timeInterval: Double(timeForNotif*60))
        }
        
        if notification.request.identifier == "CART_REMINDER" && CartUtility.fetchCartLocally().isEmpty == true {
            return [[]]
        }
        
        let userInfo = notification.request.content.userInfo
        let orderId = userInfo["orderId"] as? String
        if orderId.isNotNil {
            NotificationCenter.postNotificationForObservers(.orderNotificationReceived)
        }
        print(userInfo)
        return [[.banner, .list, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.identifier != "CART_REMINDER" {
            NotificationCenter.postNotificationForObservers(.goToNotifications)
        }
        print(userInfo)
    }
    
}
