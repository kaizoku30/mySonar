//
//  SettingView.swift
//  Kudu
//
//  Created by Admin on 19/07/22.
//

import UIKit

class SettingView: UIView {

    // MARK: - Outlets
    @IBOutlet private weak var settingTableView: UITableView!
    @IBOutlet private weak var settingsLabel: UILabel!
    @IBAction private func backButtonPressed(_ sender: Any) {
        self.handleViewActions?(.backButtonPressed)
    }
    
    var isLogoutApiHitting: Bool { logoutApiHitting }
    var isDeleteApiHitting: Bool { deleteApiHitting }
    var getSectionWiseData: [SectionHeaderName] { sectionWiseData }
    private var logoutApiHitting = false
    private var deleteApiHitting = false
    private var sectionWiseData: [SectionHeaderName] = [.help, .content, .accountControl]
    var handleViewActions: ((ViewActions) -> Void)?
    
    enum ViewActions {
        case backButtonPressed
        case goToLogin
    }
    
    // MARK: - Enum
    enum APICalled {
        case delete
        case logout
    }
    
    enum SectionHeaderName: CaseIterable {
        case help
        case content
        case accountControl
        
        var title: String {
            switch self {
            case .help:
                return LocalizedStrings.Setting.help
            case .content:
                return LocalizedStrings.Setting.content
            case .accountControl:
                return LocalizedStrings.Setting.accountControl
            }
        }
    }
    
    enum Help: CaseIterable {
        case faq
        case support
        case sendFeedback
        
        var title: String {
            switch self {
            case .faq:
                return LocalizedStrings.Setting.faq
            case .support:
                return LocalizedStrings.Setting.support
            case .sendFeedback:
                return LocalizedStrings.Setting.sendFeedback
            }
        }
    }
    
    enum Content: CaseIterable {
        case privacyAndPolicy
        case termsAndConditions
        case ourVision
        case aboutUs
        
        var title: String {
            switch self {
            case .privacyAndPolicy:
                return LocalizedStrings.Setting.privacyAndPolicy
            case .termsAndConditions:
                return LocalizedStrings.Setting.termsAndConditions
            case .ourVision:
                return LocalizedStrings.Setting.ourVision
            case .aboutUs:
                return LocalizedStrings.Setting.aboutUs
            }
        }
    }
    
    enum AccountControl: CaseIterable {
        case deleteAccount
        case logOut
        
        var title: String {
            switch self {
            case .deleteAccount:
                return LocalizedStrings.Setting.deleteAccount
            case .logOut:
                return LocalizedStrings.Setting.logOut
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
        settingTableView.separatorStyle = .none
        settingsLabel.text = LocalizedStrings.Setting.settings
    }
    
    private func setupTableView() {
        settingTableView.registerCell(with: SettingTableViewCell.self)
        settingTableView.registerCell(with: HeaderCell.self)
    }
    
}

extension SettingView {
    func handleAPIRequest(_ api: APICalled) {
        switch api {
        case .logout:
            self.logoutApiHitting = true
        case .delete:
            self.deleteApiHitting = true
        }
        self.settingTableView.reloadData()
        self.settingTableView.isUserInteractionEnabled = false
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, errorMsg: String?) {
        
        if !isSuccess {
            self.logoutApiHitting = api == .logout ? false : self.logoutApiHitting
            self.deleteApiHitting = api == .delete ? false : self.deleteApiHitting
            self.settingTableView.isUserInteractionEnabled = true
            self.settingTableView.reloadData()
            mainThread {
                let error = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
                error.show(message: errorMsg ?? "", view: self)
            }
        } else {
            mainThread {
                self.handleViewActions?(.goToLogin)
            }
        }
    }
}
