//
//  SetRestaurantMapLocation.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit
import GoogleMaps
import CoreLocation

class SelectableMarker: GMSMarker {
    var isSelected: Bool = false
    var restaurantId: String = ""
	var restaurantIndex: Int = -1
}

class SetRestaurantMapLocationVC: BaseVC {
	@IBOutlet private weak var kuduNearYouLabel: UILabel!
	@IBOutlet private weak var collectionView: UICollectionView!
	@IBOutlet private weak var topListButton: AppButton!
    @IBOutlet private weak var mapView: GMSMapView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchTFView: AppTextFieldView!
    @IBOutlet private weak var clearButton: AppButton!
    @IBOutlet private weak var searchBarContainerView: UIView!
	@IBOutlet private weak var confirmLocationButton: AppButton!
	@IBOutlet private weak var kuduNearYouView: UIView!
	@IBOutlet private weak var confirmButtonHeightConstraint: NSLayoutConstraint!
	private var showingError = false
	@IBAction private func confirmLocationButtonPressed(_ sender: Any) {
		
		if selectedIsOpen == false {
			if showingError { return }
			showingError = true
			let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.view.width - 32, height: 48))
			toast.show(message: "This store is closed for now", view: self.view, completionBlock: { [weak self] in
				self?.showingError = false
			})
			return
		}
		
		if selectedIndex < restaurantArray.count {
			let item = restaurantArray[selectedIndex]
            let restaurant = item.convertToRestaurantInfo()
			self.restaurantSelected?(restaurant)
			self.pop()
		}
	}
	
   private func curbsideButtonTapped() {
	   if selectedIndex >= restaurantArray.count { return }
        self.view.isUserInteractionEnabled = false
	    let item = restaurantArray[selectedIndex]
       let restaurant = item.convertToRestaurantInfo()
	   DataManager.shared.currentCurbsideRestaurant = restaurant
	   NotificationCenter.postNotificationForObservers(.curbsideLocationUpdated)
        self.triggerMenuFlow(type: .curbside, storeId: item._id ?? "", lat: item.restaurantLocation?.coordinates?.last ?? 0.0, long: item.restaurantLocation?.coordinates?.first ?? 0.0)
    }
	
	private func pickUpButtonTapped() {
		if selectedIndex >= restaurantArray.count { return }
		self.view.isUserInteractionEnabled = false
		let item = restaurantArray[selectedIndex]
        let restaurant = item.convertToRestaurantInfo()
		DataManager.shared.currentPickupRestaurant = restaurant
		NotificationCenter.postNotificationForObservers(.pickupLocationUpdated)
		self.triggerMenuFlow(type: .pickup, storeId: item._id ?? "", lat: item.restaurantLocation?.coordinates?.last ?? 0.0, long: item.restaurantLocation?.coordinates?.first ?? 0.0)
	}

    @IBAction private func backButtonPressed(_ sender: Any) {
        goToListView()
    }
    
    @IBAction private func topListButtonPressed(_ sender: Any) {
        goToListView()
    }
	
	@IBAction private func clearButtonPressed(_ sender: Any) {
		self.clearHandling()
	}

    var restaurantSelected: ((RestaurantInfoModel) -> Void)?
    var restaurantArray: [RestaurantListItem] = []
    var type: APIEndPoints.ServicesType = .pickup
    var markers: [SelectableMarker] = []
    var currentCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var lastTextQuery: String = ""
    var syncSearchBar: ((String) -> Void)?
    var ourStoreFlow = false
    var selectedIndex: Int = -1
	var selectedIsOpen: Bool = false
    var viewSet = false
	var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
		setMarkers()
        searchTFView.currentText = lastTextQuery
        clearButton.handleBtnTap = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.searchTFView.currentText = ""
            strongSelf.searchTFView.unfocus()
            strongSelf.restaurantArray = []
            strongSelf.markers = []
            strongSelf.clearHandling()
        }
		if selectedIndex != -1 && restaurantArray.isEmpty == false && ourStoreFlow {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
				self.collectionView.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
			})
		}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if viewSet { return }
		self.confirmButtonHeightConstraint.constant = ourStoreFlow ? 0 : 48
		if self.restaurantArray.count == 0 { self.confirmButtonHeightConstraint.constant = 0 }
		self.kuduNearYouView.roundTopCorners(cornerRadius: 8)
        self.topListButton.setTitle(LocalizedStrings.SetRestaurant.list, for: .normal)
		self.topListButton.layer.applySketchShadow(color: .black, alpha: 0.14, x: 0, y: 2, blur: 10, spread: 0)
        self.clearButton.isHidden = true
        self.topListButton.isHidden = false
        setupView()
        viewSet = true
    }
    
    private func clearHandling() {
        self.clearButton.isHidden = true
        if !ourStoreFlow {
            self.kuduNearYouLabel.isHidden = true
        }
        self.mapView.clear()
        self.fetchOurStoreResults(text: "")
    }
    
    func goToListView() {
        self.syncSearchBar?(self.searchTFView.currentText)
        self.pop()
    }
    
    func setupView() {
        searchTFView.textFieldType = .address
        if ourStoreFlow {
            searchTFView.placeholderText = "Search store"
        } else {
            searchTFView.placeholderText = LocalizedStrings.SetRestaurant.selectBranch
        }
        searchTFView.font = AppFonts.mulishBold.withSize(14)
        searchTFView.textColor = .black
        searchBarContainerView.roundTopCorners(cornerRadius: 4)
        titleLabel.text = ourStoreFlow ? "Select a Kudu" : LocalizedStrings.SetRestaurant.setPickupLocation
        if type == .curbside && !ourStoreFlow {
            titleLabel.text = LocalizedStrings.SetRestaurant.setCurbsideLocation
        }
        handleTextField()
    }
    
    private func handleTextField() {
        searchTFView.textFieldDidChangeCharacters = { [weak self] in
            guard let strongSelf = self, let text = $0 else { return }
            if text.isEmpty {
                strongSelf.clearHandling()
            } else {
                strongSelf.clearButton.isHidden = false
            }
        }
        
        searchTFView.textFieldDidBeginEditing = { [weak self] in
            let text = self?.searchTFView.currentText ?? ""
            self?.clearButton.isHidden = text.isEmpty
        }
        
        searchTFView.textFieldFinishedEditing = { [weak self] in
            guard let strongSelf = self else { return }
            let text = $0 ?? ""
            if text.isEmpty {
                strongSelf.restaurantArray = []
                strongSelf.markers = []
                strongSelf.clearHandling()
            } else {
                if strongSelf.ourStoreFlow {
                    strongSelf.fetchOurStoreResults(text: text)
                } else {
                    strongSelf.fetchResults(text: text)
                }
                debugPrint("Textfield Unselected")
            }
            
        }
        
    }
    
	func setMarkers() {
        markers = []
		mapView.clear()
        if restaurantArray.isEmpty {
           // mapView.clear()
        } else {
            for i in 0..<restaurantArray.count {
                let item = restaurantArray[i]
                if let coordinates = item.restaurantLocation?.coordinates, coordinates.count == 2 {
                    let long = coordinates[0]
                    let lat = coordinates[1]
                    let marker = SelectableMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: long))
                    marker.userData = i
                    marker.icon = AppImages.SetRestaurantMap.markerSmall
                    marker.isSelected = false
                    marker.title = ""
                    marker.isFlat = true
                    marker.restaurantId = item._id ?? ""
                    marker.map = mapView
					marker.restaurantIndex = i
                    markers.append(marker)
                }
            }
			var coordinates = restaurantArray[safe: 0]?.restaurantLocation?.coordinates ?? [0.0, 0.0]
            var long = coordinates[0]
            var lat = coordinates[1]
			if selectedIndex == -1 {
				selectedIndex = 0
			}
			checkIfSelectedRestaurantOpen()
			markers[selectedIndex].isSelected = true
			markers[selectedIndex].icon = AppImages.SetRestaurantMap.markerLarge
			coordinates = restaurantArray[selectedIndex].restaurantLocation?.coordinates ?? [0.0, 0.0]
			long = coordinates[0]
			lat = coordinates[1]
            fetchInitialPointInMap(initialCoordinates: CLLocationCoordinate2D(latitude: lat, longitude: long))
			collectionView.reloadData()
        }
        setKuduNearYouLabel()
    }
    
    private func setKuduNearYouLabel() {
            if restaurantArray.count == 1 {
                kuduNearYouLabel.text = LocalizedStrings.SetRestaurant.xStoreNearYou.replace(string: CommonStrings.numberPlaceholder, withString: "\(restaurantArray.count)")
            } else {
                kuduNearYouLabel.text = LocalizedStrings.SetRestaurant.xStoresNearYou.replace(string: CommonStrings.numberPlaceholder, withString: "\(restaurantArray.count)")
            }
    }
	
    func fetchInitialPointInMap(initialCoordinates: CLLocationCoordinate2D) {
        let coordinates = initialCoordinates
        let latitude = coordinates.latitude
        let longitude = coordinates.longitude
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
		self.mapView.animate(to: camera)
		
    }
	
	func checkIfSelectedRestaurantOpen() {
		if ourStoreFlow {
			let item = restaurantArray[selectedIndex]
			let currentTime = Date().totalMinutes
			let isOpen = currentTime >= (item.workingHoursStartTimeInMinutes ?? 0) && currentTime <= (item.workingHoursEndTimeInMinutes ?? 0)
			self.selectedIsOpen = isOpen
		} else {
			let item = restaurantArray[selectedIndex]
			let closingMinutes = type == .pickup ? (item.pickupTimingToInMinutes.isNotNil ? item.pickupTimingToInMinutes! : item.workingHoursEndTimeInMinutes ?? 0) : (item.curbSideTimingToInMinutes.isNotNil ? item.curbSideTimingToInMinutes! : item.workingHoursEndTimeInMinutes ?? 0)
			let openingMinutes = type == .pickup ? (item.pickupTimingFromInMinutes.isNotNil ? item.pickupTimingFromInMinutes! : item.workingHoursStartTimeInMinutes ?? 0) : (item.curbSideTimingFromInMinutes.isNotNil ? item.curbSideTimingFromInMinutes! : item.workingHoursStartTimeInMinutes ?? 0)
			let currentMinuteTimeStamp = Date().totalMinutes
			let isOpen = currentMinuteTimeStamp >= openingMinutes && currentMinuteTimeStamp <= closingMinutes
			self.selectedIsOpen = isOpen
		}
		setButton(enabled: true)
	}

}

extension SetRestaurantMapLocationVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
		guard let newIndex = marker.userData as? Int, let oldIndex = markers.firstIndex(where: { $0.isSelected == true }) else { return false }
		markers[oldIndex].isSelected = false
		markers[oldIndex].icon = AppImages.SetRestaurantMap.markerSmall
		markers[newIndex].isSelected = true
		markers[newIndex].icon = AppImages.SetRestaurantMap.markerLarge
		self.selectedIndex = newIndex
		checkIfSelectedRestaurantOpen()
		collectionView.reloadData()
		collectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
        return true
    }
}

extension SetRestaurantMapLocationVC {
	
    private func setButton(enabled: Bool) {
        confirmLocationButton.setTitleColor(enabled ? .white : AppColors.RestaurantListCell.unselectedButtonTextColor, for: .normal)
        confirmLocationButton.backgroundColor = enabled ? AppColors.kuduThemeYellow : AppColors.RestaurantListCell.unselectedButtonBg
        confirmLocationButton.isUserInteractionEnabled = enabled
        
    }
    
    private func isOpen(item: RestaurantListItem, type: APIEndPoints.ServicesType) -> Bool {
        let startString = type == .pickup ? ((item.pickupTimingFrom.isNil ? (item.workingHoursStartTime ?? "") : (item.pickupTimingFrom ?? ""))) : (((item.curbSideTimingFrom.isNil ? (item.workingHoursStartTime ?? "") : (item.curbSideTimingFrom ?? ""))))
        let endString = type == .pickup ? ((item.pickupTimingTo.isNil ? (item.workingHoursEndTime ?? "") : (item.pickupTimingTo ?? ""))) : (((item.curbSideTimingTo.isNil ? (item.workingHoursEndTime ?? "") : (item.curbSideTimingTo ?? ""))))
        debugPrint("Start Time : \(startString), End Time : \(endString)")
        let dateStart = startString.toDate(dateFormat: Date.DateFormat.hmmazzz.rawValue)
        let dateEnd = endString.toDate(dateFormat: Date.DateFormat.hmmazzz.rawValue)
        let currentTime = Date().toString(dateFormat: Date.DateFormat.hmmazzz.rawValue)
        let currentDate = currentTime.toDate(dateFormat: Date.DateFormat.hmmazzz.rawValue)
        guard let dateStart = dateStart, let dateEnd = dateEnd, let currentDate = currentDate else {
            debugPrint("Date parsing failed")
            return false
        }
        let debugString = "Date parsing success \(dateStart) \(dateEnd)"
        debugPrint(debugString)
        return (currentDate.unixTimestamp >= dateStart.unixTimestamp) && (currentDate.unixTimestamp <= dateEnd.unixTimestamp)
    }
}

extension SetRestaurantMapLocationVC {
    func fetchResults(text: String) {
        self.restaurantArray = []
        self.markers = []
		isSearching = true
        mainThread {
            self.mapView.clear()
			self.collectionView.reloadData()
        }
        APIEndPoints.HomeEndPoints.getRestaurantListing(request: RestaurantListRequest(searchKey: text, latitude: currentCoordinates.latitude, longitude: currentCoordinates.longitude, type: type), success: { [weak self] (response) in
            guard let strongSelf = self else { return }
			strongSelf.isSearching = false
            mainThread {
				strongSelf.selectedIndex = -1
                strongSelf.restaurantArray = (response.data?.list) ?? []
				strongSelf.confirmButtonHeightConstraint.constant = strongSelf.restaurantArray.count == 0 ? 0 : 48
				strongSelf.view.layoutIfNeeded()
				strongSelf.setMarkers()
				strongSelf.collectionView.reloadData()
				strongSelf.collectionView.scrollToItem(at: IndexPath(item: strongSelf.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
            }
        }, failure: { [weak self] in
				self?.isSearching = false
				self?.collectionView.reloadData()
                let error = NSError(code: $0.code, localizedDescription: $0.msg)
                SKToast.show(withMessage: error.localizedDescription)
        })
    }
    
    func fetchOurStoreResults(text: String) {
        self.restaurantArray = []
        self.markers = []
		isSearching = true
        mainThread {
            self.mapView.clear()
			self.collectionView.reloadData()
        }
        
        APIEndPoints.HomeEndPoints.ourStoreListing(searchKey: text, latitude: currentCoordinates.latitude, longitude: currentCoordinates.longitude, success: { [weak self] (response) in
            guard let strongSelf = self else { return }
			strongSelf.isSearching = false
            mainThread {
				strongSelf.selectedIndex = -1
                strongSelf.restaurantArray = (response.data?.list) ?? []
				strongSelf.setMarkers()
				strongSelf.collectionView.reloadData()
				strongSelf.collectionView.scrollToItem(at: IndexPath(item: strongSelf.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
            }
        }, failure: { [weak self] in
			self?.isSearching = false
			self?.collectionView.reloadData()
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            SKToast.show(withMessage: error.localizedDescription)
        })
    }
}

extension SetRestaurantMapLocationVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		CGSize(width: confirmLocationButton.width, height: ourStoreFlow ? 157 : 131)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 12
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 12
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		isSearching || restaurantArray.isEmpty ? 1 : restaurantArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueCell(with: RestaurantCollectionViewCell.self, indexPath: indexPath)
		if isSearching {
			cell.shimmer()
		} else if restaurantArray.isEmpty && isSearching == false {
			cell.noResult()
		} else {
			cell.configure(restaurantArray[indexPath.item], ourStoreFlow: ourStoreFlow, index: indexPath.item, selected: indexPath.item == selectedIndex, type: self.type)
		}
		cell.didSelectRestaurant = { [weak self] (index: Int) in
			guard let strongSelf = self else { return }
//			strongSelf.markers[strongSelf.selectedIndex].isSelected = false
//			strongSelf.markers[strongSelf.selectedIndex].icon = AppImages.SetRestaurantMap.markerSmall
			strongSelf.selectedIndex = index
//			strongSelf.markers[strongSelf.selectedIndex].isSelected = true
//			strongSelf.markers[strongSelf.selectedIndex].icon = AppImages.SetRestaurantMap.markerLarge
			strongSelf.setMarkers()
			strongSelf.collectionView.reloadData()
			strongSelf.collectionView.scrollToItem(at: IndexPath(item: strongSelf.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
		}
		cell.curbsidePressed = { [weak self] (index) in
			guard let strongSelf = self else { return }
			strongSelf.selectedIndex = index
			strongSelf.curbsideButtonTapped()
		}
		cell.pickupPressed = { [weak self] (index) in
			guard let strongSelf = self else { return }
			strongSelf.selectedIndex = index
			strongSelf.pickUpButtonTapped()
		}
		return cell
	}
}

extension SetRestaurantMapLocationVC {
	// MARK: Curbside/Pickup Flow
        private func triggerMenuFlow(type: APIEndPoints.ServicesType, storeId: String, lat: Double, long: Double) {
            
            mainThread {
                self.view.isUserInteractionEnabled = true
                self.tabBarController?.selectedIndex = HomeTabBarVC.TabOptions.menu.rawValue
                return
            }
        }
}
