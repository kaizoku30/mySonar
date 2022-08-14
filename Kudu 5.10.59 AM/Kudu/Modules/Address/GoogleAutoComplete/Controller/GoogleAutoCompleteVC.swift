//
//  GoogleAutoCompleteVC.swift
//  Kudu
//
//  Created by Admin on 15/07/22.
//

import UIKit
import CoreLocation

class GoogleAutoCompleteVC: BaseVC {
    @IBOutlet private weak var baseView: GoogleAutoCompleteView!
    var viewModel: GoogleAutoCompleteVM?
    private var debouncer = Debouncer(delay: 1)
    private var textQuery: String = ""
    private var isSearching = false
    var prefillCallback: ((LocationInfoModel) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleActions()
        baseView.setupView(flow: viewModel?.getFlow ?? .myAddress)
        handleDebouncer()
        
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            switch $0 {
            case .clearButtonPressed:
                strongSelf.clearButtonPressed()
            case .backButtonPressed:
                strongSelf.pop()
            case .searchTextChanged(let updatedText):
                strongSelf.textQuery = updatedText
                strongSelf.debouncer.call()
            case .openMap:
                strongSelf.openMap()
            case .fetchAddressList:
                viewModel.getAddressList()
                strongSelf.baseView.handleAPIRequest(.addressListFetched)
            case .openSettings:
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        }
    }
    
    private func clearButtonPressed() {
        self.textQuery = ""
        viewModel?.clearData()
        if viewModel?.getFlow ?? .setDeliveryLocation == .setDeliveryLocation {
            self.baseView.clearAllPressed()
            return
        }
        self.baseView.handleAPIResponse(.autoComplete, isSuccess: true, noResultFound: false, errorMsg: nil)
    }
    
    private func openMap() {
        if !CommonLocationManager.checkIfLocationServicesEnabled() || !CommonLocationManager.isAuthorized() {
            self.showLocationPermissionAlert()
        } else {
            
            CommonLocationManager.getLocationOfDevice(foundCoordinates: {
                if let coordinate = $0 {
                    self.launchMapPinVC(lat: coordinate.latitude, long: coordinate.longitude)
                } else {
                    self.showLocationPermissionAlert()
                }
            })
        }
    }
    
    private func launchMapPinVC(lat: Double, long: Double) {
        let vc = MapPinVC.instantiate(fromAppStoryboard: .Address)
        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        vc.viewModel = MapPinVM(delegate: vc, coordinates: coordinates)
        vc.prefillCallback = { [weak self] (newLoc) in
            guard let viewModel = self?.viewModel else { return }
            if viewModel.getFlow == .setDeliveryLocation {
                DataManager.shared.currentDeliveryLocation = newLoc
                let currentLocationSaved = DataManager.shared.fetchRecentSearchesForDeliveryLocation()
                let contains = currentLocationSaved.contains(where: { $0.latitude == newLoc.latitude && $0.longitude == newLoc.longitude && $0.trimmedAddress == newLoc.trimmedAddress && $0.googleTitle == newLoc.googleTitle })
                if contains == false { DataManager.shared.saveToRecentlySearchDeliveryLocation(newLoc) }
            }
            self?.prefillCallback?(newLoc)
            self?.pop()
        }
        self.push(vc: vc)
    }
    
    private func showLocationPermissionAlert() {
        mainThread {
            let type: LocationServicesDeniedView.AlertType = CommonLocationManager.checkIfLocationServicesEnabled() == false ? .locationServicesNotWorking : .locationPermissionDenied
            self.baseView.showLocationServicesAlert(type: type)
        }
    }
    
    private func handleDebouncer() {
        debouncer.callback = { [weak self] in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            if strongSelf.textQuery.isEmpty {
                viewModel.clearData()
                if viewModel.getFlow == .setDeliveryLocation {
                    strongSelf.baseView.clearAllPressed()
                    return
                }
                strongSelf.baseView.handleAPIResponse(.autoComplete, isSuccess: true, noResultFound: false, errorMsg: nil)
                return
            }
            strongSelf.isSearching = true
            strongSelf.baseView.handleAPIRequest(.autoComplete)
            viewModel.hitGoogleAutocomplete(strongSelf.textQuery)
        }
    }
    
}

extension GoogleAutoCompleteVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if baseView.showRecentSearches(tableView) {
//            guard let viewModel = self.viewModel else { return 0 }
//            if viewModel.isFetchingAddressList {
//                return 1
//            }
//            let showRecentSearch: Int = viewModel.getRecentlySearchAddress.count > 0 ? 1 : 0
//            let showAddress = viewModel.getMyAddressList.count > 0 ? 1 : 0
//            return showRecentSearch + showAddress
            guard let viewModel = self.viewModel else { return 0 }
            if viewModel.isFetchingAddressList {
                return 1
            }
            return GoogleAutoCompleteView.SetDeliveryLocationSection.allCases.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if baseView.showRecentSearches(tableView) {
            guard let viewModel = self.viewModel else { return 0 }
            if viewModel.isFetchingAddressList {
                return 1
            }
            let sectionType = GoogleAutoCompleteView.SetDeliveryLocationSection(rawValue: section)
            if sectionType == nil { return 0 }
            let rows = sectionType! == .recentlySearched ? viewModel.getRecentlySearchAddress.count : viewModel.getMyAddressList.count
            return rows == 0 ? 0 : rows + 1
        }
        
        if isSearching {
            return 1
        } else {
            return (viewModel?.getList.count ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if baseView.showRecentSearches(tableView) {
            guard let viewModel = self.viewModel, let sectionType = GoogleAutoCompleteView.SetDeliveryLocationSection(rawValue: indexPath.section) else { return UITableViewCell() }
            
            if viewModel.isFetchingAddressList {
                return getLoaderCell(tableView, cellForRowAt: indexPath)
            }
            let row = indexPath.row
            if row == 0 {
                return getSectionTitleCell(tableView, cellForRowAt: indexPath, sectionType: sectionType)
            } else {
                return getSectionResultCell(tableView, cellForRowAt: indexPath, sectionType: sectionType)
            }
        }
        
        if indexPath.row == 0 && isSearching {
            return getLoaderCell(tableView, cellForRowAt: indexPath)
        } else {
            return getResultCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    private func getLoaderCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: AutoCompleteLoaderCell.self)
        return cell
    }
    
    private func getSectionTitleCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, sectionType: GoogleAutoCompleteView.SetDeliveryLocationSection) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: RecentSearchSectionTitleCell.self)
        cell.configure(type: sectionType)
        cell.clearBtnPressed = { [weak self] in
            AppUserDefaults.removeValue(forKey: .recentSearchDeliveryLocation)
            self?.baseView.refreshRecentSearches()
        }
        return cell
    }
    
    private func getSectionResultCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, sectionType: GoogleAutoCompleteView.SetDeliveryLocationSection) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: AutoCompleteResultCell.self)
        let row = indexPath.row
        guard let viewModel = self.viewModel else { return UITableViewCell() }
        if sectionType == .recentlySearched {
            let item = viewModel.getRecentlySearchAddress[row - 1]
            cell.configure(title: item.googleTitle ?? "", subtitle: item.googleSubtitle ?? "", index: row - 1)
            cell.cellTapped = { [weak self] in
                self?.prefillCallback?(viewModel.getRecentlySearchAddress[$0])
                self?.pop()
            }
            
        } else {
            let item = viewModel.getMyAddressList[row - 1]
            let addressType = WebServices.AddressLabelType(rawValue: item.addressLabel ?? "")
            let title = addressType == .OTHER ? item.otherAddressLabel ?? "" : item.addressLabel ?? ""
            cell.configure(title: title, subtitle: item.buildingName ?? "", index: row - 1, addressType: addressType)
            cell.cellTapped = { [weak self] in
                let myAddress = viewModel.getMyAddressList[$0]
                let object = LocationInfoModel(trimmedAddress: myAddress.buildingName ?? "", city: myAddress.cityName ?? "", state: myAddress.stateName ?? "", postalCode: myAddress.zipCode ?? "", latitude: (myAddress.location?.latitude) ?? 0.0, longitude: (myAddress.location?.longitude) ?? 0.0, googleTitle: myAddress.buildingName ?? "", googleSubtitle: "\(myAddress.cityName ?? ""), \(myAddress.stateName ?? "")")
                self?.prefillCallback?(object)
                self?.pop()
            }
        }
        return cell
    }
    
    private func getResultCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: AutoCompleteResultCell.self)
        guard let viewModel = self.viewModel else { return cell }
        if indexPath.row < viewModel.getList.count {
            let item = viewModel.getList[indexPath.row]
            let title = item.partialAddress?.title ?? ""
            let subtitle = item.partialAddress?.subtitle ?? ""
            cell.configure(title: title.trimTrailingWhitespace(), subtitle: subtitle.trimTrailingWhitespace(), index: indexPath.row)
            cell.cellTapped = { [weak self] in
                self?.getDetails(index: $0)
            }
        }
        return cell
    }
    
    private func getRecentlySearchedCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: AutoCompleteResultCell.self)
        if let viewModel = self.viewModel, indexPath.row < viewModel.getRecentlySearchAddress.count {
            let item = viewModel.getRecentlySearchAddress[indexPath.row]
            cell.configure(title: item.googleTitle ?? "", subtitle: item.googleSubtitle ?? "", index: indexPath.row)
        }
        return cell
    }
    
    private func getSavedAddressCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: AutoCompleteResultCell.self)
        if let viewModel = self.viewModel, indexPath.row < viewModel.getMyAddressList.count {
            let item = viewModel.getMyAddressList[indexPath.row]
            cell.configure(title: item.addressLabel ?? "", subtitle: item.buildingName ?? "", index: indexPath.row, addressType: WebServices.AddressLabelType(rawValue: item.addressLabel ?? "") ?? .HOME)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if baseView.showRecentSearches(tableView) {
//            let section = GoogleAutoCompleteView.SetDeliveryLocationSection(rawValue: indexPath.section)
//            guard let section = section, let viewModel = self.viewModel else { return }
//            if section == .recentlySearched, (indexPath.row - 1) < viewModel.getRecentlySearchAddress.count {
//                let item = viewModel.getRecentlySearchAddress[indexPath.row - 1]
//                self.prefillCallback?(item)
//                self.pop()
//                return
//            } else {
//                if (indexPath.row - 1) < viewModel.getMyAddressList.count {
//                    let item = viewModel.getMyAddressList[indexPath.row - 1]
//                    let location = LocationInfoModel(trimmedAddress: item.buildingName ?? "", city: item.cityName ?? "", state: item.stateName ?? "", postalCode: item.zipCode ?? "", latitude: (item.location?.latitude) ?? 0.0, longitude: (item.location?.longitude) ?? 0.0)
//                    self.prefillCallback?(location)
//                    self.pop()
//                    return
//                }
//            }
            
            return
        }
        getDetails(index: indexPath.row)
    }
    
    private func getDetails(index: Int) {
        if isSearching {
            return
        }
        guard let viewModel = self.viewModel else { return }
        if index < viewModel.getList.count {
            let item = viewModel.getList[index]
            if item.partialAddress.isNotNil {
                self.baseView.handleAPIRequest(.reverseGeocoding)
                viewModel.hitDetailAPI(partialMatch: item.partialAddress!)
            }
        }
    }
}

extension GoogleAutoCompleteVC: GoogleAutoCompleteVMDelegate {
    
    func myAddressListResponse(responseType: Result<String, Error>) {
        switch responseType {
        case .success(let response):
            debugPrint(response)
            self.baseView.handleAPIResponse(.addressListFetched, isSuccess: true, noResultFound: false, errorMsg: nil)
        case .failure(let error):
            self.baseView.handleAPIResponse(.addressListFetched, isSuccess: false, noResultFound: false, errorMsg: error.localizedDescription)
        }
    }
    
    func autoCompleteAPIResponse(responseType: Result<String, Error>) {
        mainThread {
            self.isSearching = false
            switch responseType {
            case .success(let response):
                debugPrint(response)
                let count = (self.viewModel?.getList.count ?? 0)
                self.baseView.handleAPIResponse(.autoComplete, isSuccess: true, noResultFound: count == 0, errorMsg: nil)
            case .failure(let error):
                self.viewModel?.clearData()
                self.baseView.handleAPIResponse(.autoComplete, isSuccess: false, noResultFound: false, errorMsg: error.localizedDescription)
            }
        }
        
    }
    
    func detailAPIResponse(responseType: Result<String, Error>) {
        switch responseType {
        case .success(let response):
            debugPrint(response)
            guard let prefillData = self.viewModel?.getPrefillData, let viewModel = self.viewModel else {
                self.baseView.handleAPIResponse(.reverseGeocoding, isSuccess: false, noResultFound: false, errorMsg: nil)
                return
            }
            if viewModel.getFlow == .setDeliveryLocation {
                DataManager.shared.currentDeliveryLocation = prefillData
                let currentLocationSaved = DataManager.shared.fetchRecentSearchesForDeliveryLocation()
                let contains = currentLocationSaved.contains(where: { $0.latitude == prefillData.latitude && $0.longitude == prefillData.longitude && $0.trimmedAddress == prefillData.trimmedAddress && $0.googleTitle == prefillData.googleTitle })
                if contains == false { DataManager.shared.saveToRecentlySearchDeliveryLocation(prefillData) }
                
            }
            self.prefillCallback?(prefillData)
            self.pop()
        case .failure(let error):
            self.baseView.handleAPIResponse(.autoComplete, isSuccess: false, noResultFound: false, errorMsg: error.localizedDescription)
        }
    }
    
}
