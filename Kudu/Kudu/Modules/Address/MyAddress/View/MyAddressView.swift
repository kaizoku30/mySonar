//
//  MyAddressView.swift
//  Kudu
//
//  Created by Admin on 13/07/22.
//

import UIKit
import NVActivityIndicatorView

class MyAddressView: UIView {
    // MARK: Outlets
    @IBOutlet private weak var errorHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var errorTopAnchor: NSLayoutConstraint!
    @IBOutlet private weak var errorToastView: AppErrorToastView!
    @IBOutlet private weak var noResult: NoResultFoundView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loader: NVActivityIndicatorView!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var myAddressLabel: UILabel!
    @IBOutlet private weak var addNewAddressBtn: AppButton!
    // MARK: Actions
    @IBAction private func addNewAddressPressed(_ sender: Any) {
        addNewAddressBtn.becomeFirstResponder()
        handleViewActions?(.addNewAddress)
    }
    
    @IBAction private func backButtonPressed(_ sender: Any) {
        handleViewActions?(.backButtonPressed)
    }
    
    // MARK: Variables
    
    enum Sections: Int, CaseIterable {
        case DEFAULT = 0
        case OTHER
        
        var title: String {
            switch self {
            case .DEFAULT:
                return LSCollection.MyAddress.defaultAddressTitle
            case .OTHER:
                return LSCollection.MyAddress.otherAddressTitle
            }
        }
    }
    
    enum ViewActions {
        case pullToRefersh
        case backButtonPressed
        case addNewAddress
        case deleteAddress(id: String)
        case addNewDefaultAddress(idToReplace: String)
    }
    
    enum APICalled {
        case fetchMyAddressList
        case deleteAddress
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
        tableView.showsVerticalScrollIndicator = false
        noResult.backgroundColor = backgroundView.backgroundColor
        tableView.backgroundColor = backgroundView.backgroundColor
        noResult.contentType = .none
        toggleLoader(start: false)
        toggleNoResult(show: true)
        myAddressLabel.text = LSCollection.MyAddress.myAddressLabel
        addNewAddressBtn.setTitle(LSCollection.MyAddress.addNewAddressBtn, for: .normal)
    }
    private func initialSetup() {
        tableView.separatorStyle = .none
        tableView.registerCell(with: MyAddressTableViewCell.self)
    }
    
    private func toggleLoader(start: Bool) {
        mainThread {
            self.loader.isHidden = !start
            if start {
                self.loader.startAnimating()
            } else {
                self.loader.stopAnimating()
            }
        }
    }
    
    private func toggleNoResult(show: Bool) {
            self.tableView.isHidden = show
            self.noResult.show = show
    }
    
    func showError(message: String, extraDelay: TimeInterval? = nil) {
        mainThread {
            let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            toast.show(message: message, view: self)
        }
    }
    
    func showDeletePopUp(id: String, isDefault: Bool = false, otherAddresses: [MyAddressListItem]? = nil) {
        
        if isDefault && (otherAddresses == nil || otherAddresses?.isEmpty ?? false) {
            showAddDefaultAddressPopUp(idToReplace: id)
            return
        }
        
        let popUpAlert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 0))
        //popUpAlert.rightButtonBgColor = AppColors.MyAddressScreen.deleteBtnColor
        popUpAlert.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: .left)
        popUpAlert.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: nil)
		popUpAlert.configure(message: LSCollection.MyAddress.showDeletePopUpMessage, leftButtonTitle: LSCollection.MyAddress.delete, rightButtonTitle: LSCollection.MyAddress.cancel, container: self, setMessageAsTitle: true)
        popUpAlert.handleAction = { [weak self] in
            if $0 == .right { return }
            if let list = otherAddresses, isDefault, list.isEmpty == false {
                self?.showRemoveDefaultAddressView(list: list, idToDelete: id)
                return
            }
            self?.handleViewActions?(.deleteAddress(id: id))
        }
    }
    
    func showAddDefaultAddressPopUp(idToReplace: String) {
        let popUpAlert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: self.width - AppPopUpView.HorizontalPadding, height: 0))
        popUpAlert.rightButtonBgColor = AppColors.kuduThemeYellow
        popUpAlert.configure(message: LSCollection.MyAddress.showAddDefaultAddressPopUpMessage, leftButtonTitle: LSCollection.MyAddress.cancel, rightButtonTitle: LSCollection.MyAddress.add, container: self)
        popUpAlert.handleAction = { [weak self] in
            if $0 == .left { return }
            self?.handleViewActions?(.addNewDefaultAddress(idToReplace: idToReplace))
        }
    }
    
    func showRemoveDefaultAddressView(list: [MyAddressListItem], idToDelete: String) {
        mainThread {
            let bottomSheet = ChangeDefaultAddressView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
            bottomSheet.configure(container: self, list: list, idToDelete: idToDelete)
            bottomSheet.operationComplete = { [weak self] (idToDelete) in
                self?.handleViewActions?(.deleteAddress(id: idToDelete))
            }
        }
        
    }

}

extension MyAddressView {
    func handleAPIRequest(_ api: APICalled) {
        mainThread {
            switch api {
            case .fetchMyAddressList, .deleteAddress:
                self.toggleNoResult(show: false)
                self.tableView.isHidden = true
                self.toggleLoader(start: true)
            }
        }
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, noAddressFound: Bool, errorMsg: String?) {
        switch api {
        case .fetchMyAddressList:
            self.toggleLoader(start: false)
            switch isSuccess {
            case true:
                if noAddressFound {
                    self.toggleNoResult(show: true)
                } else {
                    self.toggleNoResult(show: false)
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                }
            case false:
                self.showError(message: errorMsg ?? LSCollection.MyAddress.somethingWentWrong, extraDelay: nil)
            }
        case .deleteAddress:
            break
        }
    }
    
    func refreshTableView() {
        self.tableView.reloadData()
    }
}
