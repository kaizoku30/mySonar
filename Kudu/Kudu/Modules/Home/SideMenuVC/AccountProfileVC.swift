//
//  SideMenuVC.swift
//  Kudu
//
//  Created by Admin on 15/08/22.
//

import UIKit
import LanguageManager_iOS

class AccountProfileVC: BaseVC {
    var removeContainerOverlay: (() -> Void)?
    var pushVC: ((BaseVC?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeFor(.dismissSideMenu, selector: #selector(dismissNotificationReceived))
    }
    
    @objc private func dismissNotificationReceived() {
        mainThread {
            self.dismissSideMenu(pushViewController: nil)
        }
    }
    
    func dismissSideMenu(pushViewController vc: BaseVC?) {
        if let vc = vc {
            vc.hidesBottomBarWhenPushed = true
            self.push(vc: vc)
        }
    }
    
    func changeLanguage(toArabic isArabic: Bool) {
        self.view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            let language: AppUserDefaults.Language = isArabic ? .ar : .en
            AppUserDefaults.save(value: language.rawValue, forKey: .selectedLanguage)
            LanguageManager.shared.setLanguage(language: isArabic ? .ar : .en) { _ -> UIViewController in
                let tabBar = HomeTabBarVC()
                let navVC = BaseNavVC(rootViewController: tabBar)
                return navVC
            } animation: { view in
                view.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
            }
        })
    }
    
    func triggerMenuFlow() {
        mainThread {
            self.tabBarController?.selectedIndex = HomeTabBarVC.TabOptions.menu.rawValue
        }
    }
}
