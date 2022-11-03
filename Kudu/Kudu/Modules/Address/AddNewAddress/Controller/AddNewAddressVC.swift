//
//  AddNewAddressVC.swift
//  Kudu
//
//  Created by Admin on 13/07/22.
//

import UIKit
import SwiftLocation
import CoreLocation
class AddNewAddressVC: BaseVC {
    @IBOutlet var baseView: AddNewAddressView!
    typealias CellType = AddNewAddressView.CellType
    var viewModel: AddNewAddressVM?
    var cartFormFlow: ((MyAddressListItem, StoreDetail) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleActions()
        if (viewModel?.getEditObject).isNotNil {
            baseView.updateTitleForEditFlow()
        }
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            switch $0 {
            case .saveAddress:
                let validationResult = viewModel.validateForm()
                if validationResult.validForm {
                    strongSelf.baseView.handleAPIRequest(.saveAddress)
                    viewModel.saveAddress()
                } else {
                    strongSelf.baseView.showError(message: validationResult.errorMsg ?? "")
                }
            case .backButtonPressed:
                strongSelf.pop()
            case .openSettings:
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            case .triggerCartFlow(let address):
                strongSelf.cartFormFlow?(address, viewModel.getStoreForCart!)
                strongSelf.pop()
            default:
                break
            }
        }
    }
}

extension AddNewAddressVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = CellType(rawValue: indexPath.row) else { return UITableViewCell() }
        switch type {
        case .name, .phoneNum, .landmark, .zipCode:
            return getAddressEntryCell(tableView, cellForRowAt: indexPath, type: type)
        case .searchLocation:
            return getSearchLocationCell(tableView, cellForRowAt: indexPath, type: type)
        case .label:
            return getLabelCell(tableView, cellForRowAt: indexPath, type: type)
        case .defaultAddress:
            return getDefaultAddressCell(tableView, cellForRowAt: indexPath, type: type)
        }
    }
    
    private func getAddressEntryCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, type: CellType) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: AddressEntryFieldCell.self)
        let latitude = viewModel?.formData.latitude
        cell.configure(type: type, entry: fetchTextEntry(type: type), prefillAttempted: latitude.isNotNil)
        cell.textEntered = { [weak self] (entryType, text) in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            switch entryType {
            case .name:
                viewModel.updateForm(.name(text))
            case .phoneNum:
                viewModel.updateForm(.phoneNumber(text))
//            case .state:
//                viewModel.updateForm(.stateName(text))
//            case .city:
//                viewModel.updateForm(.cityName(text))
            case .zipCode:
                viewModel.updateForm(.zipCode(text))
//            case .buildingName:
//                viewModel.updateForm(.buildingName(text))
            case .landmark:
                viewModel.updateForm(.landmark(text))
            default:
                break
            }
            
        }
        return cell
    }
    
    private func fetchTextEntry(type: CellType) -> String? {
        guard let viewModel = viewModel else { return nil }
        let form = viewModel.formData
        switch type {
        case .name:
            return form.name
        case .phoneNum:
            return form.phoneNumber
//        case .city:
//            return form.cityName
//        case .state:
//            return form.stateName
        case .zipCode:
            return form.zipCode
//        case .buildingName:
//            return form.buildingName
        case .landmark:
            return form.landmark
        default:
            return nil
        }
    }
    
    private func getSearchLocationCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, type: CellType) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: SearchAddressCell.self)
        cell.configure(address: viewModel?.formData.buildingName ?? "")
        cell.openMap = { [weak self] in
            
            if !CLLocationManager.locationServicesEnabled() {
                self?.baseView.showLocationServicesAlert(type: .locationServicesNotWorking)
                return
            }
            
            if !CommonLocationManager.isAuthorized() {
                self?.baseView.showLocationServicesAlert(type: .locationPermissionDenied)
                return
            }
            
            CommonLocationManager.getLocationOfDevice(foundCoordinates: {
                if let coordinates = $0 {
                    self?.openMapVC(coordinates: coordinates)
                } else {
                    self?.baseView.showError(message: "Could not fetch location of device")
                }
            })
        }
        
        cell.openAutocomplete = { [weak self] in
            let vc = GoogleAutoCompleteVC.instantiate(fromAppStoryboard: .Address)
            vc.viewModel = GoogleAutoCompleteVM(delegate: vc)
            vc.prefillCallback = {
                self?.handlePrefillData($0)
            }
            self?.push(vc: vc)
        }
        return cell
    }
    
    private func openMapVC(coordinates: CLLocationCoordinate2D) {
        let vc = MapPinVC.instantiate(fromAppStoryboard: .Address)
        vc.viewModel = MapPinVM(delegate: vc, coordinates: coordinates)
        vc.prefillCallback = { [weak self] in
            self?.handlePrefillData($0)
        }
        self.push(vc: vc)
    }
    
    private func handlePrefillData(_ data: LocationInfoModel) {
        viewModel?.checkIfAnyStoreNearby(lat: data.latitude, long: data.longitude, validAddress: { [weak self] _ in
            guard let strongSelf = self else { return }
            debugPrint("\(data.latitude) \(data.longitude)")
            strongSelf.viewModel?.updateForm(.cityName(data.city))
            strongSelf.viewModel?.updateForm(.stateName(data.state))
            strongSelf.viewModel?.updateForm(.buildingName(data.trimmedAddress))
            strongSelf.viewModel?.updateForm(.zipCode(data.postalCode))
            strongSelf.viewModel?.updateForm(.latitude(data.latitude))
            strongSelf.viewModel?.updateForm(.longitude(data.longitude))
            strongSelf.baseView.refresh()
        })
        
    }
    
    private func getLabelCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, type: CellType) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: AddressLabelCell.self)
        let selectionType = viewModel?.formData.addressLabel ?? .HOME
        cell.configure(selectionType: selectionType, otherLabel: viewModel?.formData.otherAddressLabel)
        cell.selectionUpdated = { [weak self] (selectionType, otherLabel) in
        guard let strongSelf = self, let vm = strongSelf.viewModel else { return }
            switch selectionType {
            case .WORK, .HOME:
                vm.updateForm(.addressLabel(selectionType))
                vm.updateForm(.otherAddressLabel(nil))
            case .OTHER:
                vm.updateForm(.addressLabel(selectionType))
                vm.updateForm(.otherAddressLabel(otherLabel))
            }
        }
        return cell
    }
    
    private func getDefaultAddressCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, type: CellType) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: DefaultAddressCell.self)
        let isForcedDefault = (viewModel?.isForcedDefault ?? false) || ((viewModel?.getEditObject.isNotNil ?? false) && (viewModel?.getEditObject?.isDefault ?? false)) || (viewModel?.getPrefillObject.isNotNil ?? false) && (viewModel?.getPrefillObject?.isDefault ?? false)
        let defaultStatus = viewModel?.formData.isDefault ?? false
        let isDefault = (isForcedDefault || defaultStatus)
        cell.configure(isDefault: isDefault, forcedDefault: isForcedDefault)
        cell.defaultChoiceUpdated = { [weak self] in
            guard let strongSelf = self, let vm = strongSelf.viewModel else { return }
            debugPrint("ADDRESS IS NOW DEFAULT :")
            debugPrint($0)
            vm.updateForm(.isDefault($0))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension AddNewAddressVC: AddNewAddressVMDelegate {
    func updateAddressInCart(address: MyAddressListItem) {
        mainThread {
            self.baseView.handleAPIResponse(.saveAddress, isSuccess: true, errorMsg: nil)
            NotificationCenter.postNotificationForObservers(.updateMyAddressList)
            let type: SuccessAlertView.AlertType = .addressAdded
            self.baseView.showSuccessPopUp(type, cartFlowObject: address)
        }
    }
    
    func saveAddressAPIResponse(responseType: Result<String, Error>) {
        mainThread {
            switch responseType {
            case .success(let responseString):
                debugPrint(responseString)
                if self.viewModel?.getDefaultAddressIdToReplace.isNotNil ?? false {
                        self.viewModel?.deleteAddress(id: self.viewModel!.getDefaultAddressIdToReplace!)
                        return
                }
                NotificationCenter.postNotificationForObservers(.updateMyAddressList)
                self.baseView.handleAPIResponse(.saveAddress, isSuccess: true, errorMsg: nil)
                var type: SuccessAlertView.AlertType = .addressAdded
                if self.viewModel?.getEditObject.isNotNil ?? false {
                    type = .addressUpdated
                } else {
                    type = .addressAdded
                }
                self.baseView.showSuccessPopUp(type)
            case .failure(let error):
                debugPrint(error.localizedDescription)
                self.baseView.handleAPIResponse(.saveAddress, isSuccess: false, errorMsg: error.localizedDescription)
            }
        }
    }
    
    func doesNotDeliverToThisLocation() {
        mainThread {
            let alert = OutOfReachView(frame: CGRect(x: 0, y: 0, width: self.baseView.width - OutOfReachView.HorizontalPadding, height: 0))
            alert.configure(container: self.baseView)
        }
    }
    
    func noUpdateNeeded() {
        mainThread {
            self.pop()
        }
    }
}
