//
//  SceneDelegate.swift
//  Kudu
//
//  Created by Admin on 26/04/22.
//

import UIKit
import FBSDKCoreKit
import LanguageManager_iOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow? {
        didSet {
            self.window?.overrideUserInterfaceStyle = .light
        }
    }
    
    private(set) static var shared: SceneDelegate?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        Self.shared = self
        SceneDelegate.shared?.window = UIWindow(windowScene: windowScene)
        
        // MARK: Language Setup
        languageRelatedSetup()
        
        // MARK: Initialisation of UI
        Router.shared.initialiseLaunchVC()
        
        //MARK: Handle Notification Launch
        handleLaunchFromNotifications(connectionOptions)
    }
    
    private func languageRelatedSetup() {
        var language: Languages = .en
        if AppUserDefaults.value(forKey: .selectedLanguage) as? String ?? "" == AppUserDefaults.Language.ar.rawValue {
            language = .ar
        }
        LanguageManager.shared.setLanguage(language: language, for: nil, viewControllerFactory: nil, animation: nil)
    }
    
    private func handleLaunchFromNotifications(_ connectionOptions: UIScene.ConnectionOptions) {
        if connectionOptions.notificationResponse.isNotNil {
            if connectionOptions.notificationResponse?.notification.request.identifier ?? "" != "CART REMINDER" {
                DataManager.shared.setLaunchedFromNotification(true)
            }
        }
    }
}

extension SceneDelegate {

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
               return
           }
           ApplicationDelegate.shared.application(
               UIApplication.shared,
               open: url,
               sourceApplication: nil,
               annotation: [UIApplication.OpenURLOptionsKey.annotation]
           )
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}
