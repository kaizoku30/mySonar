//
//  OurStoreVC.swift
//  Kudu
//
//  Created by Admin on 16/08/22.
//

import UIKit
import CoreLocation

class OurStoreVC: BaseVC {
    
    @IBOutlet private weak var baseView: OurStoreView!
    var viewModel: OurStoreVM!
    private var debouncer = Debouncer(delay: 1)
    private var textQuery: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleActions()
        handleDebouncer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationState()
    }
    
}

extension OurStoreVC {
    private func handleActions() {
        baseView.handleViewActions = { [weak self] (action) in
            guard let strongSelf = self else { return }
            switch action {
            case .backButtonPressed:
                strongSelf.pop()
            case .openSettings:
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            case .searchTextChanged(let updatedText):
                strongSelf.textQuery = updatedText
                strongSelf.debouncer.call()
            case .clearButtonPressed:
                strongSelf.textQuery = ""
                strongSelf.viewModel.fetchRestaurants(searchKey: "")
                strongSelf.baseView.handleAPIRequest(.restaurantListing)
            case .editingStarted:
                strongSelf.viewModel.clearData()
            case .openMap:
                strongSelf.openRestaurantMapVC(selected: nil)
            }
        }
    }
    
    private func handleDebouncer() {
        debouncer.callback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.fetchRestaurants(searchKey: strongSelf.textQuery)
            strongSelf.baseView.handleAPIRequest(.restaurantListing)
        }
    }
    
    private func openRestaurantMapVC(selected: RestaurantListItem?) {
        let vc = SetRestaurantMapLocationVC.instantiate(fromAppStoryboard: .Home)
        vc.ourStoreFlow = true
        vc.restaurantArray = self.viewModel.getRestaurants
        vc.selectedRestaurant = selected
        if let location = self.viewModel.getLocation {
            vc.currentCoordinates = location
            vc.lastTextQuery = self.textQuery
            self.push(vc: vc)
        } else {
            SKToast.show(withMessage: "No Location Found")
        }
        vc.syncSearchBar = { [weak self] in
            self?.baseView.syncSearchTextFromMap(text: $0)
        }
    }
}

extension OurStoreVC {
    private func checkLocationState() {
        if viewModel.getLocation.isNotNil { return }
        if !CommonLocationManager.checkIfLocationServicesEnabled() || !CommonLocationManager.isAuthorized() {
            self.baseView.isUserInteractionEnabled = true
            self.showLocationPermissionAlert()
            return
        } else {
            CommonLocationManager.getLocationOfDevice(foundCoordinates: {
                if let coordinates = $0 {
                    self.viewModel.updateCurrentLocation(CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude))
                    self.baseView.isUserInteractionEnabled = true
                    self.baseView.setupView()
                } else {
                    self.baseView.isUserInteractionEnabled = true
                    self.showLocationPermissionAlert()
                }
            })
        }
    }
    
    private func showLocationPermissionAlert() {
        mainThread {
            let type: LocationServicesDeniedView.LocationAlertType = CommonLocationManager.checkIfLocationServicesEnabled() == false ? .locationServicesNotWorking : .locationPermissionDenied
            self.baseView.showLocationPermissionPopUp(errorType: type)
        }
    }
}

extension OurStoreVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if baseView.currenState == .noResultFound {
            return 0
        }
        
        if baseView.isFetchingRestaurants {
            return 1
        }
        return viewModel.getRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if baseView.isFetchingRestaurants {
            let cell = tableView.dequeueCell(with: AutoCompleteLoaderCell.self)
            return cell
        }
        
        let cell = tableView.dequeueCell(with: OurStoreItemTableViewCell.self)
        if let restaurantData = viewModel.getRestaurants[safe: indexPath.row] {
            cell.configure(restaurant: restaurantData)
        }
        cell.openMapWithSelection = { [weak self] in
            self?.openRestaurantMapVC(selected: $0)
        }
        cell.curbsideTapped = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.baseView.toggleViewInteraction(enabled: false)
            strongSelf.triggerMenuFlow(type: .curbside, storeId: $0._id ?? "", lat: $0.restaurantLocation?.coordinates?.last ?? 0, long: $0.restaurantLocation?.coordinates?.first ?? 0)
            
        }
        cell.pickUpTapped = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.baseView.toggleViewInteraction(enabled: false)
            strongSelf.triggerMenuFlow(type: .pickup, storeId: $0._id ?? "", lat: $0.restaurantLocation?.coordinates?.last ?? 0, long: $0.restaurantLocation?.coordinates?.first ?? 0)
        }
//        cell.deliveryTapped = { [weak self] in
//            guard let strongSelf = self else { return }
//            strongSelf.baseView.toggleViewInteraction(enabled: false)
//            strongSelf.triggerMenuFlow(type: .delivery, storeId: "", lat: strongSelf.viewModel.getLocation?.latitude ?? 0.0, long: strongSelf.viewModel.getLocation?.longitude ?? 0.0)
//        }
        return cell
    }
}

extension OurStoreVC {
    private func triggerMenuFlow(type: HomeVM.SectionType, storeId: String, lat: Double, long: Double) {
        var menuRequest: MenuListRequest = MenuListRequest(servicesType: type, lat: lat, long: long, storeId: storeId)
        if type == .delivery {
            menuRequest = MenuListRequest(servicesType: .delivery, lat: lat, long: long, storeId: nil)
        }
        WebServices.HomeEndPoints.getMenuList(request: menuRequest, success: { [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.baseView.toggleViewInteraction(enabled: true)
            var categories = response.data ?? []
            if categories.isEmpty { return }
            categories[0].isSelectedInApp = true
            let vc = ExploreMenuVC.instantiate(fromAppStoryboard: .Home)
            vc.viewModel = ExploreMenuVM(menuCategories: categories, delegate: vc)
            mainThread {
                strongSelf.push(vc: vc)
                
            }
        }, failure: { [weak self] (error) in
            guard let strongSelf = self else { return }
            strongSelf.baseView.toggleViewInteraction(enabled: true)
            mainThread {
                let errorToast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: strongSelf.view.width - 32, height: 48))
                errorToast.show(message: error.msg, view: strongSelf.view)
            }
        })
    }
}

extension OurStoreVC: OurStoreVMDelegate {
    func ourStoreAPIResponse(responseType: Result<String, Error>) {
        switch responseType {
        case .success(let string):
            debugPrint(string)
            self.baseView.handleAPIResponse(.restaurantListing, resultCount: viewModel.getRestaurants.count, isSuccess: true, errorMsg: nil)
        case .failure(let error):
            debugPrint(error.localizedDescription)
            self.baseView.handleAPIResponse(.restaurantListing, resultCount: 0, isSuccess: false, errorMsg: error.localizedDescription)
        }
    }
}
