//
//  GuestSideNavVC.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit
import LanguageManager_iOS

class GuestProfileVC: BaseVC {
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismissSideMenu(pushViewController: nil)
    }
    @IBAction func settingsButtonPressed(_ sender: Any) {
        dismissSideMenu(pushViewController: SettingVC.instantiate(fromAppStoryboard: .Setting))
    }
    
    @IBAction func goToLoginPressed(_ sender: Any) {
        let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
        loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
        dismissSideMenu(pushViewController: loginVC)
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var loginOrSignUpToCompleteLabel: UILabel!
    
    private var shadowSetup = false
    var removeContainerOverlay: (() -> Void)?
    var pushVC: ((BaseVC?) -> Void)?
    
    enum Rows: Int, CaseIterable {
        case ourStore = 0
        case menu
        case language
        
        var title: String {
            switch self {
            case .ourStore:
                return LocalizedStrings.Profile.ourStore
            case .menu:
                return LocalizedStrings.Profile.menu
            case .language:
                return LocalizedStrings.Profile.language
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addShadow()
    }
    
    private func addShadow() {
        if shadowSetup { return }
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowRadius = 4
        containerView.layer.shouldRasterize = true
        containerView.layer.rasterizationScale = UIScreen.main.scale
        shadowSetup = true
    }
    
    private func dismissSideMenu(pushViewController vc: BaseVC?) {
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
}

extension GuestProfileVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Rows.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Rows(rawValue: indexPath.row) else { return UITableViewCell() }
        switch row {
        case .language:
            let cell = tableView.dequeueCell(with: GuestProfileLanguageCell.self)
            cell.configure()
            cell.changeLanguageToArabic = { [weak self] (isArabic) in
                self?.changeLanguage(toArabic: isArabic)
            }
            return cell
        case .ourStore, .menu:
            let cell = tableView.dequeueCell(with: GuestProfileActionCell.self)
            cell.configure(title: row.title)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = Rows(rawValue: indexPath.row) else { return }
        if row == .menu {
            let currentDeliveryLocation = DataManager.shared.currentDeliveryLocation
            WebServices.HomeEndPoints.getMenuList(request: MenuListRequest(servicesType: .delivery, lat: currentDeliveryLocation?.latitude, long: currentDeliveryLocation?.longitude, storeId: nil), success: { [weak self] (response) in
                guard let `self` = self else { return }
                var categories = response.data ?? []
                if categories.isEmpty { return }
                categories[0].isSelectedInApp = true
                let vc = ExploreMenuVC.instantiate(fromAppStoryboard: .Home)
                vc.viewModel = ExploreMenuVM(menuCategories: categories, delegate: vc)
                mainThread {
                    self.dismissSideMenu(pushViewController: vc)
                }
            }, failure: { [weak self] (error) in
                guard let `self` = self else { return }
                mainThread {
                    let errorToast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.view.width - 32, height: 48))
                    errorToast.show(message: error.msg, view: self.view)
                }
            })
        }
    }
}

extension GuestProfileVC {
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
}
