//
//  GuestSideNavVC.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit

class GuestProfileVC: AccountProfileVC {
    
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
    @IBOutlet weak var versionLabel: UILabel!
    
    private var shadowSetup = false
    
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
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let buildNo = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        versionLabel.text = "App version " + appVersion + " (\(buildNo))"
        
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
            self.triggerMenuFlow()
        }
        if row == .ourStore {
            self.tabBarController?.selectedIndex = HomeTabBarVC.TabOptions.ourStore.rawValue
            //goToOurStore()
        }
    }
    
    private func goToOurStore() {
        let vc = OurStoreVC.instantiate(fromAppStoryboard: .Home)
        vc.viewModel = OurStoreVM(delegate: vc)
        dismissSideMenu(pushViewController: vc)
    }
}
