//
//  Router.swift
//  Kudu
//
//  Created by Admin on 02/05/22.
//

import UIKit

class Router: NSObject {
    
    static let shared = Router()
    private var mainNavigation: BaseNavVC?
    private var mainTabBar: HomeTabBarVC?
    var homeNav: BaseNavVC?
    var menuNav: BaseNavVC?
    var ourStoreNav: BaseNavVC?
    var accountNav: BaseNavVC?
    
    weak var appWindow: UIWindow? {
        var window: UIWindow?
        window = SceneDelegate.shared?.window
        #if DEBUG
        if window.isNil {
            fatalError("UIWindow is not found!")
        }
        #endif
        return window
    }
    
    private override init() {
        //Private Init for Singleton Pattern
    }
    
    // MARK: Onboarding Routing
    
    // MARK: Splash Screen
    func initialiseLaunchVC() {
        mainNavigation = BaseNavVC(rootViewController: LaunchVC.instantiate(fromAppStoryboard: .Onboarding))
        SceneDelegate.shared?.window?.rootViewController = mainNavigation
        appWindow?.makeKeyAndVisible()
    }
    
    // MARK: Language Pref
    func goToLanguagePrefSelectionVC() {
        mainNavigation?.push(vc: LanguageSelectionVC.instantiate(fromAppStoryboard: .Onboarding), animated: true)
    }
    
    // MARK: Tutorial VC
    func goToTutorialVC(selectedLanguage: LanguageSelectionView.LanguageButtons) {
        let tutorialVC = TutorialContainerController.instantiate(fromAppStoryboard: .Onboarding)
        tutorialVC.selectedLanguage = selectedLanguage
        mainNavigation?.pushViewController(tutorialVC, animated: true)
    }
    
    func configureTabBar() {
        mainNavigation?.viewControllers.removeAll(where: {
            $0.isKind(of: HomeTabBarVC.self) == false
        })
        mainNavigation?.pushViewController(HomeTabBarVC(), animated: true)
    }
    
    func goToLoginVC(fromVC: BaseVC?, sessionExpiryText: String? = nil) {
        mainThread {
            guard let strongVC = fromVC else {
                self.handleLoginFlowFromMainNavigation(sessionExpiryText: sessionExpiryText)
                return
            }
            if strongVC.navigationController.isNotNil {
                strongVC.navigationController!.pushViewController(LoginVC.instantiate(fromAppStoryboard: .Onboarding), animated: true)
            }
        }
    }
    
    private func handleLoginFlowFromMainNavigation(sessionExpiryText: String? = nil) {
        if let mainNavigation = self.mainNavigation {
             let vcs = mainNavigation.viewControllers 
                if let tabBarIndex = vcs.firstIndex(where: { $0.isKind(of: HomeTabBarVC.self)}) {
                    let vc = vcs[tabBarIndex] as! HomeTabBarVC
                    vc.viewControllers?.forEach({
                        let navVC = $0 as? BaseNavVC
                        navVC?.viewControllers.forEach({ (vcInTabNav) in
                            if vcInTabNav.isKind(of: LoginVC.self) {
                                NotificationCenter.postNotificationForObservers(.sessionExpired, object: ["msg": sessionExpiryText ?? ""])
                                return
                            }
                        })
                    })
                }
        }
        NotificationCenter.postNotificationForObservers(.pushLoginVC, object: ["msg": sessionExpiryText ?? ""])
    }
    
    func goToPhoneVerificationVC(fromVC: BaseVC?) {
        guard let strongVC = fromVC else { return }
        if strongVC.navigationController.isNotNil {
            strongVC.navigationController!.pushViewController(PhoneVerificationVC.instantiate(fromAppStoryboard: .Onboarding), animated: true)
        }
    }
    
    func goToSignUpVC(fromVC: BaseVC?) {
        guard let strongVC = fromVC else { return }
        if strongVC.navigationController.isNotNil {
            strongVC.navigationController!.pushViewController(SignUpVC.instantiate(fromAppStoryboard: .Onboarding), animated: true)
        }
    }
}
