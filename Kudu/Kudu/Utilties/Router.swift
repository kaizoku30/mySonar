//
//  Router.swift
//  Kudu
//
//  Created by Admin on 02/05/22.
//

import UIKit

class Router: NSObject {
    
    static let shared = Router()
    var mainNavigation: BaseNavVC?
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
    
    func initialiseLaunchVC() {
        mainNavigation = BaseNavVC(rootViewController: LaunchVC.instantiate(fromAppStoryboard: .Onboarding))
        SceneDelegate.shared?.window?.rootViewController = mainNavigation
        appWindow?.makeKeyAndVisible()
    }
    
    func goToLanguagePrefSelectionVC(fromVC: BaseVC?) {
        guard let strongVC = fromVC else { return }
        if strongVC.navigationController.isNotNil {
            strongVC.navigationController!.pushViewController(LanguageSelectionVC.instantiate(fromAppStoryboard: .Onboarding), animated: true)
        }
    }
    
    func configureTabBar() {
        mainNavigation?.pushViewController(HomeTabBarVC(), animated: true)
        var tabIndex: [Int] = []
        for (index, viewController) in (mainNavigation?.viewControllers ?? []).enumerated() {
            if viewController.isKind(of: HomeTabBarVC.self) {
                tabIndex.append(index)
            }
        }
        if tabIndex.count > 1 {
            mainNavigation?.viewControllers.removeFirst()
        } else {
            mainNavigation?.viewControllers.removeAll(where: {
                $0.isKind(of: HomeTabBarVC.self) == false
            })
        }
    }
    
    func goToTutorialVC(fromVC: BaseVC?, selectedLanguage: LanguageSelectionView.LanguageButtons) {
        guard let strongVC = fromVC else { return }
        if strongVC.navigationController.isNotNil {
            let tutorialVC = TutorialContainerController.instantiate(fromAppStoryboard: .Onboarding)
            tutorialVC.selectedLanguage = selectedLanguage
            strongVC.navigationController!.pushViewController(tutorialVC, animated: true)
        }
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
