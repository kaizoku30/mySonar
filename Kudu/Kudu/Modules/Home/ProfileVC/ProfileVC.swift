//
//  ProfileVC.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit

class ProfileVC: AccountProfileVC {
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: AppButton!
    @IBOutlet weak var verifyNow: AppButton!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var emailVerifiedMarker: UIImageView!
    @IBOutlet weak var verificationActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var notificationBell: UIButton!
    @IBAction func backButtonPressed(_ sender: Any) {
        dismissSideMenu(pushViewController: nil)
    }
    
    @IBAction func notificationBellPressed(_ sender: Any) {
        self.push(vc: NotificationVC.instantiate(fromAppStoryboard: .Notification))
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        dismissSideMenu(pushViewController: SettingVC.instantiate(fromAppStoryboard: .Setting))
    }
    
    @IBAction func verifyPressed(_ sender: Any) {
        verifyNow.isHidden = true
        verificationActivityIndicator.color = .black
        verificationActivityIndicator.isHidden = false
        verificationActivityIndicator.startAnimating()
        APIEndPoints.HomeEndPoints.sendOtpOnMail(email: DataManager.shared.loginResponse?.email ?? "", success: { [weak self] _ in
            let vc = PhoneVerificationVC.instantiate(fromAppStoryboard: .Onboarding)
            vc.viewModel = PhoneVerificationVM(_delegate: vc, flowType: .comingFromProfilePage, emailForVerification: DataManager.shared.loginResponse?.email ?? "")
            self?.verifyNow.isHidden = false
            self?.verificationActivityIndicator.isHidden = true
            self?.verificationActivityIndicator.stopAnimating()
            self?.dismissSideMenu(pushViewController: vc)
        }, failure: { [weak self] (error) in
            guard let strongSelf = self else { return }
            self?.verifyNow.isHidden = false
            self?.verificationActivityIndicator.isHidden = true
            self?.verificationActivityIndicator.stopAnimating()
            if error.code == 400 {
                mainThread {
                    strongSelf.dismissSideMenu(pushViewController: nil)
                    strongSelf.showEmailConflictAlert?()
                    return
                }
            }
            strongSelf.dismissSideMenu(pushViewController: nil)
        })
    }
    
    @IBAction func editPressed(_ sender: Any) {
        let editProfileVC = EditProfileVC.instantiate(fromAppStoryboard: .Home)
        editProfileVC.viewModel = EditProfileVM(delegate: editProfileVC)
        dismissSideMenu(pushViewController: editProfileVC)
    }
    
    var showEmailConflictAlert: (() -> Void)?
    private var shadowSetup = false
    private var detailSetup = false
    
    enum Rows: Int, CaseIterable {
        case MyAccount = 0
        case Orders
        case Payments
        case Favourites
        case Address
        case MyOffers
        case OurStore
        case ControlCenter
        case Menu
        case NotificationsPref
        case Language
        
        var title: String {
            switch self {
            case .MyAccount:
                return LocalizedStrings.Profile.myAccount
            case .Orders:
                return LocalizedStrings.Profile.orders
            case .Payments:
                return LocalizedStrings.Profile.payments
            case .Favourites:
                return LocalizedStrings.Profile.favouritesProfile
            case .Address:
                return LocalizedStrings.Profile.address
            case .MyOffers:
                return "My offers"
            case .OurStore:
                return LocalizedStrings.Profile.ourStore
            case .ControlCenter:
                return LocalizedStrings.Profile.controlCentre
            case .Menu:
                return LocalizedStrings.Profile.menu
            case .NotificationsPref:
                return LocalizedStrings.Profile.notificationPref
            case .Language:
                return LocalizedStrings.Profile.language
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeFor(.updateProfilePage, selector: #selector(setupDetails))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shadowSetup { return }
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        shadowView.layer.shadowRadius = 4
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowSetup = true
        verificationActivityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationBell.setImage(DataManager.shared.fetchNotificationStatus ? AppImages.MainImages.notificationBell : AppImages.MainImages.noNotificationBell, for: .normal)
        self.checkNotificationStatus(statusUpdated: { [weak self] _ in
            self?.notificationBell.setImage(DataManager.shared.fetchNotificationStatus ? AppImages.MainImages.notificationBell : AppImages.MainImages.noNotificationBell, for: .normal)
        })
        if detailSetup { return }
        detailSetup = true
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let buildNo = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        versionLabel.text = "App version " + appVersion + " (\(buildNo))"
        setupDetails()
    }
    
    func checkNotificationStatus(statusUpdated: @escaping (Result<Bool, Error>) -> Void) {
        APIEndPoints.CartEndPoints.getCartConfig(storeId: nil, success: { (response) in
            DataManager.shared.setNotificationBellStatus(response.data?.newNotification ?? false)
            statusUpdated(.success(true))
        }, failure: { _ in
            statusUpdated(.success(true))
        })
    }
    
    @objc private func setupDetails() {
        verifyNow.setTitle(LocalizedStrings.Profile.verifyNow, for: .normal)
        editButton.setTitle(LocalizedStrings.Profile.edit, for: .normal)
        let userData = DataManager.shared.loginResponse
        let mobileNum = "+" + (userData?.countryCode ?? "") + "-" + (userData?.mobileNo ?? "")
        numberLabel.text = mobileNum
        if let email = userData?.email, email.isEmpty == false {
            emailLabel.text = email
            emailView.isHidden = false
        }
        nameLabel.text = userData?.fullName ?? ""
        let emailVerified = userData?.isEmailVerified ?? false
        verifyNow.isHidden = emailVerified
        emailVerifiedMarker.isHidden = !emailVerified
        verificationActivityIndicator.stopAnimating()
        verificationActivityIndicator.isHidden = true
    }
}

extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Rows.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = Rows(rawValue: indexPath.row)
        guard let type = type else { return UITableViewCell() }
        switch type {
        case .MyAccount, .ControlCenter:
            let cell = tableView.dequeueCell(with: ProfileTitleCell.self)
            cell.titleLabelCell.text = type.title
            return cell
        case .Orders, .Payments, .Favourites, .Address, .Menu, .NotificationsPref:
            let cell = tableView.dequeueCell(with: ProfileActionTableViewCell.self)
            cell.titleLabelCell.text = type.title
            cell.topLine.isHidden = false
            cell.bottomLine.isHidden = false
            cell.topLine.isHidden = type == .Orders || type == .Menu
            cell.bottomLine.isHidden = type == .Address
            return cell
        case .OurStore, .MyOffers:
            let cell = tableView.dequeueCell(with: OurStoreTableViewCell.self)
            if type == .MyOffers {
                cell.titleLabel.text = "My offers"
            }
            return cell
        case .Language:
            let cell = tableView.dequeueCell(with: LanguagePickerCell.self)
            cell.configure()
            cell.changeLanguageToArabic = { [weak self] (isArabic) in
                self?.changeLanguage(toArabic: isArabic)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = Rows(rawValue: indexPath.row)
        guard let type = type else { return }
        if type == .Address {
            let vc = MyAddressVC.instantiate(fromAppStoryboard: .Address)
            self.dismissSideMenu(pushViewController: vc)
            return
        }
        
        if type == .Menu {
            triggerMenuFlow()
            return
        }
        
        if type == .NotificationsPref {
            goToNotificationPreferences()
            return
        }
        
        if type == .OurStore {
            self.tabBarController?.selectedIndex = HomeTabBarVC.TabOptions.ourStore.rawValue
            return
        }
        
        if type == .MyOffers {
            goToMyOffers()
            return
        }
        
        if type == .Favourites {
            let vc = MyFavouritesVC.instantiate(fromAppStoryboard: .Home)
            vc.viewModel = MyFavouritesVM(delegate: vc, serviceTypeHome: .delivery)
            dismissSideMenu(pushViewController: vc)
            return
        }
        
        if type == .Orders {
            let vc = MyOrderListVC.instantiate(fromAppStoryboard: .CartPayment)
            vc.hidesBottomBarWhenPushed = true
            dismissSideMenu(pushViewController: vc)
        }
        
        if type == .Payments {
            dismissSideMenu(pushViewController: MyPaymentVC.instantiate(fromAppStoryboard: .Payment))
        }
    }

}

extension ProfileVC {
    
    private func goToNotificationPreferences() {
        let vc = NotificationPrefVC.instantiate(fromAppStoryboard: .Notification)
        vc.viewModel = NotificationPrefVM(delegate: vc)
        dismissSideMenu(pushViewController: vc)
    }
    
    private func goToMyOffers() {
        let vc = MyOffersVC.instantiate(fromAppStoryboard: .Coupon)
        dismissSideMenu(pushViewController: vc)
    }
}
