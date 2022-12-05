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
        manageLanguage()
        checkVersion()
    }
    
    // MARK: Language Management
    private func manageLanguage() {
        if AppUserDefaults.value(forKey: .selectedLanguage).isNotNil {
            if AppUserDefaults.selectedLanguage() == .en {
                LanguageManager.shared.setLanguage(language: .en, for: nil, viewControllerFactory: nil, animation: nil)
            } else if AppUserDefaults.selectedLanguage() == .ar {
                LanguageManager.shared.setLanguage(language: .ar, for: nil, viewControllerFactory: nil, animation: nil)
            }
        }
    }
    
    // MARK: Version Management
    private func checkVersion() {
        APIEndPoints.OnboardingEndPoints.checkVersion(success: { [weak self] (response) in
            let currentVersion = Double((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")) ?? 0.0
            let adminVer = Double(response.data?.currentVersion ?? "") ?? 0.0
            let updateType = response.data?.getUpdateType() ?? .NORMAL
            if currentVersion < adminVer {
                mainThread {
                    self?.showAlert(forceUpdate: updateType == .FORCEFULLY, updateVersion: "\(adminVer)")
                }
            } else {
                self?.handleFlow()
            }
         }, failure: { [weak self] _ in
             mainThread {
                 self?.handleFlow()
             }
         })
    }
    
    private func showAlert(forceUpdate: Bool, updateVersion: String) {
        let updateVer = Double(updateVersion) ?? 0.0
        let recenlyRejectVer = AppUserDefaults.value(forKey: .recentlySkippedVersion) as? String
        if !forceUpdate, let recenlyRejectVer = recenlyRejectVer, Double(recenlyRejectVer) ?? 0.0 >= updateVer {
            self.handleFlow()
            return
        }
        
        let popUp = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 0))
        popUp.configure(title: "Update Available", message: "A new version of Kudu is available. Please update to version \(updateVersion) now.", leftButtonTitle: LSCollection.CartScren.skip, rightButtonTitle: LSCollection.EditProfile.updateButton, container: self.view)
        popUp.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: .left)
        popUp.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: nil)
        if forceUpdate {
            popUp.showCenterButton()
        }
        popUp.handleAction = { [weak self] in
            if $0 == .left {
                AppUserDefaults.save(value: updateVersion, forKey: .recentlySkippedVersion)
                self?.handleFlow()
            } else {
                //Go To App Store
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id1338917203") {
                    UIApplication.shared.open(url)
                } else {
                    self?.handleFlow()
                }

            }
        }
    }
    
    // MARK: Flow Function
    private func handleFlow() {
        if DataManager.shared.isUserLoggedIn, let userId = DataManager.shared.loginResponse?.userId, !userId.isEmpty {
            //User Logged In
           Router.shared.configureTabBar()
        } else if AppUserDefaults.value(forKey: .selectedLanguage).isNotNil {
            //Language Selected
            AppUserDefaults.removeUserData()
            Router.shared.configureTabBar()
        } else {
            //Language Selection View
            Router.shared.goToLanguagePrefSelectionVC()
        }
    }
}
