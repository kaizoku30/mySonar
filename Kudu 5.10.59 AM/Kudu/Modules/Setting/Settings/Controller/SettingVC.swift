//
//  SettingVC.swift
//  Kudu
//
//  Created by Admin on 19/07/22.

//
//  ViewController.swift
//  SettingsScreen
//
//  Created by Admin on 12/07/22.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class SettingVC: BaseVC {
    
    // MARK: - Outlets
    @IBOutlet private weak var baseView: SettingView!
    private var viewModel: SettingVM?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    private func initialSetup() {
        viewModel = SettingVM(delegate: self)
        baseView.handleViewActions = { [weak self] in
            switch $0 {
            case .goToLogin:
                self?.goToLoginScreen()
            case .backButtonPressed:
                self?.pop()
            }
        }
    }
    
}

extension SettingVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = SettingView.SectionHeaderName.allCases.count
        let isGuestUser = viewModel?.isGuestUser ?? false
        return isGuestUser ? sections - 1 : sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0  :
            let isGuestUser = viewModel?.isGuestUser ?? false
            let rowsInHelpSection = SettingView.Help.allCases.count+1
            return isGuestUser ? rowsInHelpSection - 1 : rowsInHelpSection
        case 1  :  return SettingView.Content.allCases.count+1
        default :  return SettingView.AccountControl.allCases.count+1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            return getHeaderCell(tableView, cellForRowAt: indexPath)
        } else {
            return getSettingTableViewCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    private func getHeaderCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: HeaderCell.self)
        cell.headerName.text = SettingView.SectionHeaderName.allCases[indexPath.section].title
        return cell
    }
    
    private func getSettingTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: SettingTableViewCell.self)
        switch indexPath.section {
        case 0:
            setHelpSectionCell(cell: cell, indexPath: indexPath)
        case 1:
            setContentSectionCell(cell: cell, indexPath: indexPath)
        default:
            setAccountControlCell(cell: cell, indexPath: indexPath)
        }
        return cell
    }
    
    private func setHelpSectionCell(cell: SettingTableViewCell, indexPath: IndexPath) {
        cell.settingName.text = SettingView.Help.allCases[indexPath.row-1].title
        if indexPath.row == SettingView.Help.allCases.count {
            cell.viewLine.isHidden   = true
        }
        if indexPath.row == 2 && (viewModel?.isGuestUser ?? false) {
            cell.viewLine.isHidden = true
        }
    }
    
    private func setContentSectionCell(cell: SettingTableViewCell, indexPath: IndexPath) {
        cell.settingName.text = SettingView.Content.allCases[indexPath.row-1].title
        if indexPath.row == SettingView.Content.allCases.count {
            cell.viewLine.isHidden   = true
        }
    }
    
    private func setAccountControlCell(cell: SettingTableViewCell, indexPath: IndexPath) {
        cell.settingName.text = SettingView.AccountControl.allCases[indexPath.row-1].title
        if indexPath.row == SettingView.AccountControl.allCases.count {
            cell.viewLine.isHidden = true
            cell.imageArrow.isHidden   = true
            cell.settingName.textColor = .red
        }
        if indexPath.row == 1 {
            cell.toggleLoading(loading: self.baseView.isDeleteApiHitting)
        }
        
        if indexPath.row == 2 {
            cell.toggleLoading(loading: self.baseView.isLogoutApiHitting)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
}
extension SettingVC {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0 :
            handleHelpSectionSelection(indexPath: indexPath)
        case 1 :
            handleContentSectionSelection(indexPath: indexPath)
        case 2 :
            handleAccountControlSectionSelection(indexPath: indexPath)
        default:
            break
        }
    }
    
    private func handleHelpSectionSelection(indexPath: IndexPath) {
        switch indexPath.row {
        case 1 :
            goToWebViewVC(pageType: .faq)
        case 2 :
            let controller = SupportDetailsVC.instantiate(fromAppStoryboard: .Setting)
            self.navigationController?.pushViewController(controller, animated: true)
        case 3 :
            self.push(vc: SendFeedbackVC.instantiate(fromAppStoryboard: .Setting))
        default:
            break
        }
    }
    
    private func handleContentSectionSelection(indexPath: IndexPath) {
        switch indexPath.row {
        case 1 :
            goToWebViewVC(pageType: .privacyPolicy)
        case 2 :
            goToWebViewVC(pageType: .terms)
        case 3 :
            goToWebViewVC(pageType: .vision)
        case 4 :
            goToWebViewVC(pageType: .aboutUs)
        default:
            break
        }
    }
    
    private func handleAccountControlSectionSelection(indexPath: IndexPath) {
        if indexPath.row == 1 {
            handleDeletePopUp()
        } else {
            handleLogoutPopUp()
        }
    }
    
    private func goToWebViewVC(pageType: Constants.StaticContentType) {
        let controller = WebViewVC.instantiate(fromAppStoryboard: .Setting)
        controller.pageType = pageType
        self.push(vc: controller)
    }
    
    private func handleDeletePopUp() {
        let popUp = AppPopUpView(frame: CGRect(x: 0, y: 0, width: self.baseView.width - AppPopUpView.HorizontalPadding, height: 0))
        popUp.rightButtonBgColor = AppColors.SendFeedbackScreen.deleteBtnColor
        popUp.configure(title: LocalizedStrings.Setting.deleteAccount, message: LocalizedStrings.Setting.yourInformationWillBeErasedAsAResult, leftButtonTitle: LocalizedStrings.Setting.confirm, rightButtonTitle: LocalizedStrings.Setting.cancel, container: self.baseView)
        popUp.setButtonConfiguration(for: .left, config: .blueOutline)
        popUp.setButtonConfiguration(for: .right, config: .yellow)
        popUp.handleAction = { [weak self] in
            if $0 == .left {
                self?.baseView.handleAPIRequest(.delete)
                self?.viewModel?.hitDeleteAPI()
            }
        }
    }
    
    private func handleLogoutPopUp() {
        let popUp = AppPopUpView(frame: CGRect(x: 0, y: 0, width: self.baseView.width - AppPopUpView.HorizontalPadding, height: 0))
        popUp.configure(title: LocalizedStrings.Setting.logoutButton, message: LocalizedStrings.Setting.areYouSureYouWantToLogout, leftButtonTitle: LocalizedStrings.Setting.confirm, rightButtonTitle: LocalizedStrings.Setting.cancel, container: self.baseView)
        popUp.setButtonConfiguration(for: .left, config: .blueOutline)
        popUp.setButtonConfiguration(for: .right, config: .yellow)
        popUp.handleAction = { [weak self] in
            if $0 == .left {
                self?.baseView.handleAPIRequest(.logout)
                self?.viewModel?.hitLogoutAPI()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
}

extension SettingVC: SettingsVMDelegate {
    
    func logoutAPIResponse(responseType: Result<String, Error>) {
        switch responseType {
        case .success(let string):
            debugPrint(string)
            self.baseView.handleAPIResponse(.logout, isSuccess: true, errorMsg: nil)
        case .failure(let error):
            self.baseView.handleAPIResponse(.logout, isSuccess: false, errorMsg: error.localizedDescription)
        }
    }
    
    func deleteAPIResponse(responseType: Result<String, Error>) {
        switch responseType {
        case .success(let string):
            debugPrint(string)
            self.baseView.handleAPIResponse(.delete, isSuccess: true, errorMsg: nil)
        case .failure(let error):
            self.baseView.handleAPIResponse(.delete, isSuccess: false, errorMsg: error.localizedDescription)
        }
    }
}

extension SettingVC {
    
    private func goToLoginScreen() {
        
        debugPrint("Settings Screen function called")
        
        let fbLoginManager = LoginManager()
        fbLoginManager.logOut()
        GIDSignIn.sharedInstance.signOut()
        AppUserDefaults.removeValue(forKey: .recentSearchExploreMenu)
        AppUserDefaults.removeValue(forKey: .currentDeliveryAddress)
        AppUserDefaults.removeValue(forKey: .currentCurbsideRestaurant)
        AppUserDefaults.removeValue(forKey: .currentPickupRestaurant)
        AppUserDefaults.removeValue(forKey: .loginResponse)
        if let navigationController = self.navigationController {
            if navigationController.viewControllers.contains(where: {
                $0.isKind(of: LoginVC.self)
            }) {
                debugPrint("Login VC was already in stack")
                NotificationCenter.postNotificationForObservers(.resetLoginState)
                self.popToSpecificViewController(kindOf: LoginVC.self)
                return
            }
        }

        let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
        loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromLoggedInUser)
        self.push(vc: loginVC)
    }
}
