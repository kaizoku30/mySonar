//
//  MyAddressVC.swift
//  Kudu
//
//  Created by Admin on 13/07/22.
//

import UIKit
import SwiftLocation
import CoreLocation
import MapKit

class MyAddressVC: BaseVC {
    @IBOutlet private weak var baseView: MyAddressView!
    
    private var viewModel: MyAddressVM?
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MyAddressVM(_delegate: self)
        handleActions()
        baseView.handleAPIRequest(.fetchMyAddressList)
        viewModel?.getAddressList()
        self.observeFor(.updateMyAddressList, selector: #selector(pullToRefreshCalled))
    }

    private func handleActions() {
        baseView.handleViewActions = { [weak self] (action) in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            switch action {
            case .addNewAddress:
                let addAddressVC = AddNewAddressVC.instantiate(fromAppStoryboard: .Address)
                addAddressVC.viewModel = AddNewAddressVM(_delegate: addAddressVC, forcedDefault: (viewModel.getList.count == 0 && viewModel.getDefaultAddress.isNil))
                strongSelf.push(vc: addAddressVC)
            case .backButtonPressed:
                self?.pop()
            case .deleteAddress(let addressId):
                strongSelf.baseView.handleAPIRequest(.deleteAddress)
                viewModel.deleteAddress(id: addressId)
            case .addNewDefaultAddress(let idToReplace):
                let addAddressVC = AddNewAddressVC.instantiate(fromAppStoryboard: .Address)
                addAddressVC.viewModel = AddNewAddressVM(_delegate: addAddressVC, forcedDefault: true, defaultIdToReplace: idToReplace)
                strongSelf.push(vc: addAddressVC)
            default:
                break
            }
        }
    }
    
    @objc private func pullToRefreshCalled() {
        mainThread { [weak self] in
            self?.baseView.handleAPIRequest(.fetchMyAddressList)
            self?.viewModel?.getAddressList()
        }
        
    }
}

extension MyAddressVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MyAddressView.Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = MyAddressView.Sections(rawValue: indexPath.section)
        if type == .DEFAULT {
            return 141 - 16
        }
        return 141
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let type = MyAddressView.Sections(rawValue: section)
        guard let type = type, let viewModel = viewModel else { return nil }
        let view = MyAddressHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: tableView.height))
        view.setTitle(type.title)
        if type == .DEFAULT && viewModel.getDefaultAddress.isNil {
            return nil
        }
        return type == .DEFAULT ? view : (viewModel.getList.count == 0 ? nil : view)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = MyAddressView.Sections(rawValue: section)
        guard let type = type, let viewModel = viewModel else { return 0 }
        return type == .DEFAULT ? (viewModel.getDefaultAddress == nil ? 0 : 1) : viewModel.getList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = MyAddressView.Sections(rawValue: indexPath.section)
        guard let type = type, let viewModel = viewModel else { return UITableViewCell() }
        if type == .OTHER && indexPath.row >= viewModel.getList.count {
            return UITableViewCell()
        } else {
            if viewModel.getDefaultAddress.isNil {
            return UITableViewCell()
            }
        }
        return getMyAddressCell(tableView, cellForRowAt: indexPath, viewModel: viewModel, sectionType: type)
    }
    
    private func getMyAddressCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, viewModel: MyAddressVM, sectionType: MyAddressView.Sections) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: MyAddressTableViewCell.self)
        let item = sectionType == .DEFAULT ? viewModel.getDefaultAddress! : viewModel.getList[indexPath.row]
        cell.configure(item: item)
        cell.editAddress = { [weak self] (item) in
            guard let `self` = self, let viewModel = self.viewModel else { return }
            let addAddressVC = AddNewAddressVC.instantiate(fromAppStoryboard: .Address)
            addAddressVC.viewModel = AddNewAddressVM(_delegate: addAddressVC, editObject: item, forcedDefault: (viewModel.getList.count == 0))
            `self`.push(vc: addAddressVC)
        }
        cell.deleteAddress = { [weak self] (item) in
            guard let `self` = self, let viewModel = self.viewModel else { return }
            let isDefault = item.isDefault ?? false
            var otherAddresses: [MyAddressListItem]?
            if isDefault {
                otherAddresses = viewModel.getList.filter({ ($0.isDefault ?? false) == false })
            }
            let addressId = item.id ?? ""
            self.baseView.showDeletePopUp(id: addressId, isDefault: isDefault, otherAddresses: otherAddresses)
        }
        return cell
    }
}

extension MyAddressVC: MyAddressVMDelegate {
    
    func addressAPIResponse(responseType: Result<String, Error>) {
        mainThread {
            switch responseType {
            case .success(let responseString):
                debugPrint(responseString)
                self.baseView.handleAPIResponse(.fetchMyAddressList, isSuccess: true, noAddressFound: (self.viewModel?.getList.count ?? 0  == 0) && ((self.viewModel?.getDefaultAddress ?? nil) == nil), errorMsg: nil)
            case .failure(let error):
                self.baseView.handleAPIResponse(.fetchMyAddressList, isSuccess: false, noAddressFound: false, errorMsg: error.localizedDescription)
            }
        }
    }
    
    func deleteAddressAPIResponse(responseType: Result<String, Error>) {
        mainThread {
            switch responseType {
            case .success(let responseString):
                debugPrint(responseString)
                self.viewModel?.getAddressList()
            case .failure(let error):
                self.baseView.handleAPIResponse(.fetchMyAddressList, isSuccess: false, noAddressFound: false, errorMsg: error.localizedDescription)
            }
        }
    }
}
