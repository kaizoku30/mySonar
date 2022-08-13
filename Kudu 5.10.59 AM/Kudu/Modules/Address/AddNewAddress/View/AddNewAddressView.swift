//
//  AddNewAddressView.swift
//  Kudu
//
//  Created by Admin on 13/07/22.
//

import UIKit

class AddNewAddressView: UIView {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var errorHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var errorTopAnchor: NSLayoutConstraint!
    @IBOutlet private weak var addAddressButton: AppButton!
    @IBOutlet private weak var errorToastView: AppErrorToastView!
    @IBAction private func addAddressButtonPressed(_ sender: Any) {
        handleViewActions?(.saveAddress)
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        handleViewActions?(.backButtonPressed)
    }
    @IBOutlet weak var myAddressLabel: UILabel!
    
    enum ViewActions {
        case saveAddress
        case backButtonPressed
        case openSettings
        case defaultAddressPicked(updatedArray: [MyAddressListItem])
    }
    
    enum APICalled {
        case saveAddress
    }
    
    enum CellType: Int, CaseIterable {
        case name = 0
        case phoneNum
        case searchLocation
        //case city
        //case state
        case zipCode
       // case buildingName
        case landmark
        case label
        case defaultAddress
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
        myAddressLabel.text = LocalizedStrings.MyAddress.myAddressLabel
        addAddressButton.setTitle(LocalizedStrings.AddNewAddress.saveButton, for: .normal)
    }
    
    private func initialSetup() {
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.registerCell(with: AddressEntryFieldCell.self)
        tableView.registerCell(with: SearchAddressCell.self)
        tableView.registerCell(with: AddressLabelCell.self)
        tableView.registerCell(with: DefaultAddressCell.self)
    }
    
    func updateTitleForEditFlow() {
        myAddressLabel.text = LocalizedStrings.MyAddress.editAddress
    }
    
    func showError(message: String, extraDelay: TimeInterval? = nil) {
        mainThread {
            let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            toast.show(message: message, view: self, extraDelay: extraDelay)
        }
    }
    
    func showSuccessPopUp(_ type: SuccessAlertView.AlertType) {
        let successPopUp = SuccessAlertView(frame: CGRect(x: 0, y: 0, width: self.width - SuccessAlertView.HorizontalPadding, height: SuccessAlertView.Height))
        successPopUp.configure(type: type, container: self, displayTime: 2)
        successPopUp.handleDismissal = { [weak self] in
            self?.handleViewActions?(.backButtonPressed)
        }
    }
    
    func showLocationServicesAlert(type: LocationServicesDeniedView.AlertType) {
        let alert = LocationServicesDeniedView(frame: CGRect(x: 0, y: 0, width: LocationServicesDeniedView.Width, height: LocationServicesDeniedView.Height))
        alert.configure(type: type, leftButtonTitle: "Cancel", rightButtonTitle: "Setting", container: self)
        alert.handleAction = { [weak self] in
            if $0 == .right {
                self?.handleViewActions?(.openSettings)
            }
        }
    }
    
    func showDefaultAddressPicker(otherList: [MyAddressListItem]) {
        let addressPicker = ChangeDefaultAddressView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        addressPicker.configureForEditFlow(container: self, list: otherList)
        addressPicker.editFlowCompletion = { _ in
            
        }
    }
    
    func refresh() {
        mainThread {
            self.tableView.reloadData()
        }
    }

}

extension AddNewAddressView {
    
    func handleAPIRequest(_ api: APICalled) {
        mainThread {
            switch api {
            case .saveAddress:
                self.addAddressButton.startBtnLoader(color: .white)
            }
        }
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, errorMsg: String?) {
        switch api {
        case .saveAddress:
            switch isSuccess {
            case true:
                self.addAddressButton.stopBtnLoader()
            case false:
                self.addAddressButton.stopBtnLoader()
                self.showError(message: errorMsg ?? "Something Went Wrong", extraDelay: nil)
            }
        }
    }
}
