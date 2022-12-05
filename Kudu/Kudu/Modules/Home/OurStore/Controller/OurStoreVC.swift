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
	private var selectedIndex: Int = -1
    
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
		if let selected = selected, let index = self.viewModel.getRestaurants.firstIndex(where: { $0._id ?? "" == selected._id ?? ""}) {
			vc.selectedIndex = index
		}
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
        CommonLocationManager.getLocationOfDevice(foundCoordinates: { (coordinates) in
            mainThread {
                self.baseView.toggleOutOfReachView(coordinates.isNil)
                if !CommonLocationManager.isAuthorized() {
                    self.baseView.isUserInteractionEnabled = true
                    self.showLocationPermissionAlert()
                    return
                } else {
                    if coordinates.isNotNil {
                        self.baseView.setupView()
                        self.viewModel.updateCurrentLocation(CLLocationCoordinate2D(latitude: coordinates?.latitude ?? 0.0, longitude: coordinates?.longitude ?? 0.0))
                        self.viewModel.fetchRestaurants(searchKey: "")
                        self.baseView.isUserInteractionEnabled = true
                        return
                    } else {
                        self.baseView.isUserInteractionEnabled = true
                        self.showLocationPermissionAlert()
                    }
                }
            }
        })
        
    }
    
    private func showLocationPermissionAlert() {
        mainThread {
//            let type: LocationServicesDeniedView.LocationAlertType = CommonLocationManager.checkIfLocationServicesEnabled() == false ? .locationServicesNotWorking : .locationPermissionDenied
            self.baseView.showLocationPermissionPopUp(errorType: .locationServicesNotWorking)
        }
    }
}

extension OurStoreVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if baseView.currenState == .noResultFound {
            return 0
        }
        
        if baseView.isFetchingRestaurants {
            return 5
        }
        return viewModel.getRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if baseView.isFetchingRestaurants {
            let cell = tableView.dequeueCell(with: ResultShimmerTableViewCell.self)
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
            let item = $0
            let restaurant = item.convertToRestaurantInfo()
			DataManager.shared.currentCurbsideRestaurant = restaurant
			NotificationCenter.postNotificationForObservers(.curbsideLocationUpdated)
            strongSelf.triggerMenuFlow(type: .curbside, storeId: $0._id ?? "", lat: $0.restaurantLocation?.coordinates?.last ?? 0, long: $0.restaurantLocation?.coordinates?.first ?? 0)
            
        }
        cell.pickUpTapped = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.baseView.toggleViewInteraction(enabled: false)
            let item = $0
            let restaurant = item.convertToRestaurantInfo()
			DataManager.shared.currentPickupRestaurant = restaurant
			NotificationCenter.postNotificationForObservers(.pickupLocationUpdated)
            strongSelf.triggerMenuFlow(type: .pickup, storeId: $0._id ?? "", lat: $0.restaurantLocation?.coordinates?.last ?? 0, long: $0.restaurantLocation?.coordinates?.first ?? 0)
        }
        return cell
    }
}

extension OurStoreVC {
    private func triggerMenuFlow(type: APIEndPoints.ServicesType, storeId: String, lat: Double, long: Double) {
        mainThread {
            self.baseView.toggleViewInteraction(enabled: true)
            self.tabBarController?.selectedIndex = HomeTabBarVC.TabOptions.menu.rawValue
            return
        }
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
