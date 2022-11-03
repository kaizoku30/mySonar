//
//  LaunchVC.swift
//  Kudu
//
//  Created by Admin on 05/05/22.
//

import UIKit
import LanguageManager_iOS

class LaunchVC: BaseVC {
    
    // MARK: ViewLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delayAndGoToNextVC()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Delay Function
    private func delayAndGoToNextVC() {
        if AppUserDefaults.value(forKey: .selectedLanguage).isNotNil {
            if AppUserDefaults.selectedLanguage() == .en {
                LanguageManager.shared.setLanguage(language: .en, for: nil, viewControllerFactory: nil, animation: nil)
            } else if AppUserDefaults.selectedLanguage() == .ar {
                LanguageManager.shared.setLanguage(language: .ar, for: nil, viewControllerFactory: nil, animation: nil)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [weak self] in
            self?.handleFlow()
        })
    }
    
    // MARK: Flow Function
    private func handleFlow() {
        weak var weakSelf = self
        if DataManager.shared.isUserLoggedIn, let userId = DataManager.shared.loginResponse?.userId, !userId.isEmpty {
            //User Logged In
           Router.shared.configureTabBar()
        } else if AppUserDefaults.value(forKey: .selectedLanguage).isNotNil {
            //Language Selected
            AppUserDefaults.removeUserData()
            Router.shared.configureTabBar()
        } else {
            //Language Selection View
            Router.shared.goToLanguagePrefSelectionVC(fromVC: weakSelf)
        }
    }
}
