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
}

class SetRestaurantMapLocationVC: BaseVC {
    
    @IBOutlet private weak var listButton: AppButton!
    @IBOutlet private weak var mapView: GMSMapView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchTFView: AppTextFieldView!
    @IBOutlet private weak var clearButton: AppButton!
    @IBOutlet private weak var kuduNearYouLabel: UILabel!
    @IBOutlet private weak var searchBarContainerView: UIView!
    @IBOutlet private weak var restNameLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var confirmLocationButton: AppButton!
    @IBOutlet private weak var restAddressLabel: UILabel!
    @IBOutlet private weak var openCloseLabel: UILabel!
    @IBOutlet private weak var closeTimingStackView: UIStackView!
    @IBOutlet private weak var closeTimingLabel: UILabel!
    @IBOutlet private weak var shimmerView: UIView!
    @IBOutlet private weak var containerInfoStackView: UIStackView!
    
    @IBAction func confirmLocationTapped(_ sender: Any) {
        let firstIndex = self.restaurantArray.firstIndex(where: { $0.isSelectedInApp ?? false == true })
        if let firstIndex = firstIndex, firstIndex < restaurantArray.count {
            let item = restaurantArray[firstIndex]
            let restaurant = RestaurantInfoModel(restaurantNameEnglish: item.nameEnglish ?? "", restaurantNameArabic: item.nameArabic ?? "", areaNameEnglish: item.restaurantLocation?.areaNameEnglish ?? "", areaNameArabic: item.restaurantLocation?.areaNameArabic ?? "", latitude: (item.restaurantLocation?.coordinates?[1]) ?? 0.0, longitude: (item.restaurantLocation?.coordinates?[0]) ?? 0.0, storeId: item._id ?? "")
            self.restaurantSelected?(restaurant)
            self.pop()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        goToListView()
    }
    
//    @IBAction func clearButtonPressed(_ sender: Any) {
//        self.searchTFView.currentText = ""
//        self.searchTFView.unfocus()
//        self.restaurantArray = []
//        self.markers = []
//        clearHandling()
//    }
    
    private func clearHandling() {
        self.clearButton.isHidden = true
        self.kuduNearYouLabel.isHidden = true
        self.containerInfoStackView.isHidden = true
        self.mapView.clear()
    }
    
    @IBAction func listButtonPressed(_ sender: Any) {
        goToListView()
    }
    
    func goToListView() {
        self.syncSearchBar?(self.searchTFView.currentText)
        self.pop()
    }
    
    var restaurantSelected: ((RestaurantInfoModel) -> Void)?
    var restaurantArray: [RestaurantListItem] = []
    var type: HomeVM.SectionType = .pickup
    var markers: [SelectableMarker] = []
    var currentCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var lastTextQuery: String = ""
    var syncSearchBar: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleInfoLoading(true)
        mapView.delegate = self
        setMarkers()
        setInfoView()
        searchTFView.currentText = lastTextQuery
        clearButton.handleBtnTap = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.searchTFView.currentText = ""
            strongSelf.searchTFView.unfocus()
            strongSelf.restaurantArray = []
            strongSelf.markers = []
            strongSelf.clearHandling()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.listButton.setAttributedTitle(NSAttributedString(string: LocalizedStrings.SetRestaurant.list, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]), for: .normal)
        self.clearButton.isHidden = true
        setupView()
    }
    
    func setupView() {
        searchTFView.textFieldType = .address
        searchTFView.placeholderText = LocalizedStrings.SetRestaurant.selectBranch
        searchTFView.font = AppFonts.mulishBold.withSize(14)
        searchTFView.textColor = .black
        searchBarContainerView.roundTopCorners(cornerRadius: 4)
        titleLabel.text = LocalizedStrings.SetRestaurant.setPickupLocation
        if type == .curbside {
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
                strongSelf.fetchResults(text: text)
                debugPrint("Textfield Unselected")
            }
            
        }
        
    }
    
    func toggleInfoLoading(_ show: Bool) {
        containerInfoStackView.isHidden = show
        if show {
            shimmerView.startShimmering()
        } else {
            shimmerView.stopShimmering()
        }
    }
    
    func setMarkers() {
        markers = []
        if restaurantArray.isEmpty {
            toggleInfoLoading(false)
            containerInfoStackView.isHidden = true
            shimmerView.isHidden = true
            mapView.clear()
        } else {
            containerInfoStackView.isHidden = true
            shimmerView.isHidden = true
            for i in 0..<restaurantArray.count {
                let item = restaurantArray[i]
                if let coordinates = item.restaurantLocation?.coordinates, coordinates.count == 2 {
                    let long = coordinates[0]
                    let lat = coordinates[1]
                    let marker = SelectableMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: long))
                    //let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: long))
                    marker.userData = i
                    marker.icon = AppImages.SetRestaurantMap.markerSmall
                    marker.isSelected = false
                    marker.title = ""
                    marker.isFlat = true
                    marker.map = mapView
                    markers.append(marker)
                }
            }
            let coordinates = restaurantArray[0].restaurantLocation?.coordinates
            let long = coordinates?[0] ?? 0.0
            let lat = coordinates?[1] ?? 0.0
            if markers.count > 0 {
                markers[0].isSelected = true
                markers[0].icon = AppImages.SetRestaurantMap.markerLarge
            }
            fetchInitialPointInMap(initialCoordinates: CLLocationCoordinate2D(latitude: lat, longitude: long))
        }
        kuduNearYouLabel.text = LocalizedStrings.SetRestaurant.xKuduNearYou.replace(string: CommonStrings.numberPlaceholder, withString: "\(restaurantArray.count)")
    }
    
    func setInfoView() {
        let selected = restaurantArray.firstIndex(where: { $0.isSelectedInApp ?? false == true })
        if let index = selected {
            setInfoData(item: restaurantArray[index])
        } else {
            if restaurantArray.isEmpty == true { return }
            restaurantArray[0].isSelectedInApp = true
            setInfoData(item: restaurantArray[0])
        }
    }
    
    func setInfoData(item: RestaurantListItem) {
        let item = item
        let name = AppUserDefaults.selectedLanguage() == .en ? item.nameEnglish ?? "" : item.nameArabic ?? ""
        let areaName = AppUserDefaults.selectedLanguage() == .en ? (item.restaurantLocation?.areaNameEnglish ?? "") : (item.restaurantLocation?.areaNameArabic ?? "")
        restNameLabel.text = name
        confirmLocationButton.setTitle(LocalizedStrings.SetRestaurant.confirmlocationSmall, for: .normal)
        let distance = (item.distance ?? 0.0).round(to: 2).removeZerosFromEnd()
        distanceLabel.text = distance + LocalizedStrings.SetRestaurant.km
        restAddressLabel.text = areaName
        let isOpen = self.isOpen(item: item, type: type)
        closeTimingStackView.isHidden = !isOpen
        let closingTime = type == .pickup ? ((item.pickupTimingTo.isNil ? (item.workingHoursEndTime ?? "") : (item.pickupTimingTo ?? ""))) : (((item.curbSideTimingTo.isNil ? (item.workingHoursEndTime ?? "") : (item.curbSideTimingTo ?? ""))))
        closeTimingLabel.text = "\(LocalizedStrings.SetRestaurant.closed) \(closingTime.replace(string: "AM", withString: LocalizedStrings.SetRestaurant.amString).replace(string: "PM", withString: LocalizedStrings.SetRestaurant.pmString))"
        setButton(enabled: isOpen)
        openCloseLabel.text = isOpen ? LocalizedStrings.SetRestaurant.open : LocalizedStrings.SetRestaurant.closed
        openCloseLabel.textColor = isOpen ? AppColors.RestaurantListCell.openGreen : AppColors.RestaurantListCell.closedRed
        toggleInfoLoading(false)
        kuduNearYouLabel.isHidden = false
    }
    
    func fetchInitialPointInMap(initialCoordinates: CLLocationCoordinate2D) {
        let coordinates = initialCoordinates
        let latitude = coordinates.latitude
        let longitude = coordinates.longitude
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        mapView.camera = camera
    }

}

extension SetRestaurantMapLocationVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let index = marker.userData as? Int
        let selected = markers.firstIndex(where: { $0.isSelected == true })
        let selectedRest = restaurantArray.firstIndex(where: { $0.isSelectedInApp ?? false == true })
        if let selectedIndex = selected, let indexToSelect = index, indexToSelect < markers.count, let selectedRest = selectedRest, indexToSelect < restaurantArray.count {
            markers[selectedIndex].isSelected = false
            markers[selectedIndex].icon = AppImages.SetRestaurantMap.markerSmall
            markers[indexToSelect].isSelected = true
            markers[indexToSelect].icon = AppImages.SetRestaurantMap.markerLarge
            restaurantArray[selectedRest].isSelectedInApp = false
            restaurantArray[indexToSelect].isSelectedInApp = true
            setInfoData(item: restaurantArray[indexToSelect])
        }
        
        return true
    }
}

extension SetRestaurantMapLocationVC {
    private func setButton(enabled: Bool) {
        confirmLocationButton.setTitleColor(enabled ? .white : AppColors.RestaurantListCell.unselectedButtonTextColor, for: .normal)
        confirmLocationButton.backgroundColor = enabled ? AppColors.kuduThemeYellow : AppColors.RestaurantListCell.unselectedButtonBg
        confirmLocationButton.isUserInteractionEnabled = enabled
        
    }
    
    private func isOpen(item: RestaurantListItem, type: HomeVM.SectionType) -> Bool {
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
        mainThread {
            self.toggleInfoLoading(true)
            self.mapView.clear()
        }
        
        WebServices.HomeEndPoints.getRestaurantListing(request: RestaurantListRequest(searchKey: text, latitude: currentCoordinates.latitude, longitude: currentCoordinates.longitude, type: type), success: { [weak self] (response) in
            guard let strongSelf = self else { return }
            mainThread {
                if strongSelf.searchTFView.currentText.isEmpty { return }
                strongSelf.restaurantArray = (response.data?.list) ?? []
                strongSelf.setMarkers()
                strongSelf.setInfoView()
            }
            //self.delegate?.listingAPIResponse(responseType: .success(response.message ?? ""))
            
        }, failure: { [weak self] in
                self?.toggleInfoLoading(false)
                let error = NSError(code: $0.code, localizedDescription: $0.msg)
                SKToast.show(withMessage: error.localizedDescription)
            //self?.delegate?.listingAPIResponse(responseType: .failure(error))
        })
    }
}
