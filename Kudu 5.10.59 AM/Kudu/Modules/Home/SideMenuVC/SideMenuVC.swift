//
//  SideMenuVC.swift
//  Kudu
//
//  Created by Admin on 15/08/22.
//

import UIKit
import LanguageManager_iOS

class SideMenuVC: BaseVC {
    var removeContainerOverlay: (() -> Void)?
    var pushVC: ((BaseVC?) -> Void)?
    
    func dismissSideMenu(pushViewController vc: BaseVC?) {
        self.removeContainerOverlay?()
        self.willMove(toParent: nil)
        self.removeFromParent()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            if AppUserDefaults.selectedLanguage() == .en {
                self.view.transform = CGAffineTransform(translationX: -self.view.width, y: 0)
            } else {
                self.view.transform = CGAffineTransform(translationX: self.view.width, y: 0)
            }
            
        }, completion: {
            if $0 {
                self.pushVC?(vc)
                self.view.removeFromSuperview()
            }
        })
    }
    
    func changeLanguage(toArabic isArabic: Bool) {
        self.view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            let language: AppUserDefaults.Language = isArabic ? .ar : .en
            AppUserDefaults.save(value: language.rawValue, forKey: .selectedLanguage)
            LanguageManager.shared.setLanguage(language: isArabic ? .ar : .en) { _ -> UIViewController in
                let homeVC = HomeVC.instantiate(fromAppStoryboard: .Home)
                homeVC.viewModel = HomeVM(delegate: homeVC)
                let navVC = BaseNavVC(rootViewController: homeVC)
                return navVC
            } animation: { view in
                view.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
            }
        })
    }
    
    func triggerMenuFlow() {
        let currentDeliveryLocation = DataManager.shared.currentDeliveryLocation
        WebServices.HomeEndPoints.getMenuList(request: MenuListRequest(servicesType: .delivery, lat: currentDeliveryLocation?.latitude, long: currentDeliveryLocation?.longitude, storeId: nil), success: { [weak self] (response) in
            guard let strongSelf = self else { return }
            var categories = response.data ?? []
            if categories.isEmpty { return }
            categories[0].isSelectedInApp = true
            let vc = ExploreMenuVC.instantiate(fromAppStoryboard: .Home)
            vc.viewModel = ExploreMenuVM(menuCategories: categories, delegate: vc)
            mainThread {
                strongSelf.dismissSideMenu(pushViewController: vc)
            }
        }, failure: { [weak self] (error) in
            guard let strongSelf = self else { return }
            mainThread {
                let errorToast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: strongSelf.view.width - 32, height: 48))
                errorToast.show(message: error.msg, view: strongSelf.view)
            }
        })
    }
}
