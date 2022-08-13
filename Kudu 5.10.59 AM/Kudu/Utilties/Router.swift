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
    
    func goToHomeVC(fromVC: BaseVC?) {
        guard let strongVC = fromVC else { return }
        if strongVC.navigationController.isNotNil {
            let homeVC = HomeVC.instantiate(fromAppStoryboard: .Home)
            homeVC.viewModel = HomeVM(delegate: homeVC)
            strongVC.navigationController!.pushViewController(homeVC, animated: true)
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
    
    func goToLoginVC(fromVC: BaseVC?, sessionExpiryText: String? = nil, showBackButton: Bool = false) {
        debugPrint("Router function called")
        mainThread {
            guard let strongVC = fromVC else {
                if let mainNavigation = self.mainNavigation {
                    if let topVC = mainNavigation.topViewController {
                        if topVC.isKind(of: LoginVC.self) {
                            NotificationCenter.postNotificationForObservers(.sessionExpired, object: ["msg": sessionExpiryText ?? ""])
                            return
                        }
                    }
                }
                NotificationCenter.postNotificationForObservers(.pushLoginVC, object: ["msg": sessionExpiryText ?? ""])
                return
            }
            
            if strongVC.navigationController.isNotNil {
                strongVC.navigationController!.pushViewController(LoginVC.instantiate(fromAppStoryboard: .Onboarding), animated: true)
            }
        }
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
