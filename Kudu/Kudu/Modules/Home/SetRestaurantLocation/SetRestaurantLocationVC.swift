//
//  SetRestaurantLocationVC.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit
import CoreLocation

class SetRestaurantLocationVC: BaseVC {
	@IBOutlet private weak var baseView: SetRestaurantLocationView!
	var viewModel: SetRestaurantLocationVM?
	private var debouncer = Debouncer(delay: 1)
	private var textQuery: String { baseView.getSearchText() }
	private var isFetchingSuggestions = false
	private var isFetchingResultList = false
	private var queueMapFlow = false
	private var selectedIndex = -1
	private var selectedAvailable = false
	//safeAreaInsets
	
	var restaurantSelected: ((RestaurantInfoModel) -> Void)?
	private var observer: NSObjectProtocol?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		debugPrint("Restaurant VC addded")
		handleActions()
		handleDebouncer()
		baseView.isUserInteractionEnabled = false
		observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] _ in
			// do whatever you want when the app is brought back to the foreground
			if self.baseView.getCurrentSection == .suggestions {
				self.baseView.focusTextField()
			}
			
			if let currentLoc = self.viewModel?.getLocation, currentLoc.latitude != 0, currentLoc.longitude != 0 { return }
			self.checkLocationState(launchMap: false)
		}
	}
	
	deinit {
		if let observer = observer {
			NotificationCenter.default.removeObserver(observer)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		baseView.setTitle(flow: viewModel?.getFlow ?? .pickup)
	}
	
	override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		if (viewModel?.getLocation.latitude) == 0 || (viewModel?.getLocation.longitude) == 0 {
			self.checkLocationState(launchMap: false)
		}
		
	}
	
	private func handleActions() {
		baseView.handleViewActions = { [weak self] in
			guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
			switch $0 {
			case .clearButtonPressed:
				viewModel.clearData()
				strongSelf.baseView.handleClearAll()
			case .backButtonPressed:
				strongSelf.pop()
			case .searchTextChanged:
				strongSelf.debouncer.call()
			case .openMap:
				strongSelf.queueMapFlow = true
				strongSelf.isFetchingResultList = true
				strongSelf.viewModel?.fetchResults(text: strongSelf.textQuery)
				strongSelf.baseView.handleAPIRequest(.detailList)
			case .openSettings:
				UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
			case .fetchSuggestions:
				break
			case .fetchList:
				break
			case .searchTextForDetailList(searchText: let searchText):
				strongSelf.isFetchingResultList = true
				strongSelf.viewModel?.fetchResults(text: searchText)
				strongSelf.baseView.handleAPIRequest(.detailList)
			case .confirmLocationPresssed:
				if strongSelf.selectedAvailable == false {
					strongSelf.baseView.showError(message: "This store is closed for now.")
				} else {
					strongSelf.confirmLocationPressed()
				}
			}
		}
	}
	
	private func confirmLocationPressed() {
		guard let item = viewModel?.getList[safe: self.selectedIndex] else { return }
        let restaurant = RestaurantInfoModel(restaurantNameEnglish: item.nameEnglish ?? "", restaurantNameArabic: item.nameArabic ?? "", areaNameEnglish: item.restaurantLocation?.areaNameEnglish ?? "", areaNameArabic: item.restaurantLocation?.areaNameArabic ?? "", latitude: item.restaurantLocation?.coordinates?.last ?? 0.0, longitude: item.restaurantLocation?.coordinates?.first ?? 0.0, cityName: item.restaurantLocation?.cityName ?? "", stateName: item.restaurantLocation?.stateName ?? "", countryName: item.restaurantLocation?.countryName ?? "", storeId: item._id ?? "", sdmId: item.sdmId ?? 0)
		self.restaurantSelected?(restaurant)
		self.pop()
	}
	
	private func checkLocationState(launchMap: Bool) {
        //!CommonLocationManager.checkIfLocationServicesEnabled() ||
		if !CommonLocationManager.isAuthorized() {
			self.baseView.isUserInteractionEnabled = true
			self.showLocationPermissionAlert()
			return
		} else {
			
			CommonLocationManager.getLocationOfDevice(foundCoordinates: {
				if let coordinates = $0 {
					self.viewModel?.updateLocation(CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude))
					if !launchMap {
						self.baseView.isUserInteractionEnabled = true
						self.baseView.setupView(flow: self.viewModel?.getFlow ?? .pickup, safeAreaInsets: self.safeAreaInsets )
					}
				} else {
					self.baseView.isUserInteractionEnabled = true
					self.showLocationPermissionAlert()
				}
			})
		}
	}
	
	private func handleDebouncer() {
		debouncer.callback = { [weak self] in
			guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
			if strongSelf.textQuery.isEmpty {
				viewModel.clearData()
				return
			}
			if strongSelf.baseView.getCurrentSection == .suggestions {
				strongSelf.isFetchingSuggestions = true
				strongSelf.viewModel?.fetchSuggestions(text: strongSelf.textQuery)
				strongSelf.baseView.handleAPIRequest(.suggestions)
			}
		}
	}
	
	private func showLocationPermissionAlert() {
		mainThread {
//			let type: LocationServicesDeniedView.LocationAlertType = CommonLocationManager.checkIfLocationServicesEnabled() == false ? .locationServicesNotWorking : .locationPermissionDenied
            self.baseView.showLocationServicesAlert(type: .locationServicesNotWorking)
		}
	}
}

extension SetRestaurantLocationVC: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let currentSection = baseView.getCurrentSection
		switch currentSection {
		case .suggestions:
			if isFetchingSuggestions {
				return 5
			}
			return viewModel?.getSuggestions.count ?? 0
		case .results:
			if isFetchingResultList {
				return 5
			}
			return ((viewModel?.getList.count) ?? 0) + 1 //For Header Row
		case .blankScreen:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let currentSection = baseView.getCurrentSection
		switch currentSection {
		case .suggestions:
			if isFetchingSuggestions {
				return getLoaderCell(tableView, cellForRowAt: indexPath)
			}
			return getSuggestionsCell(tableView, cellForRowAt: indexPath)
		case .results:
			if isFetchingResultList {
				let cell = tableView.dequeueCell(with: ResultShimmerTableViewCell.self)
				return cell
			}
		case .blankScreen:
			return UITableViewCell()
		}
		
		if indexPath.row == 0 {
			return getRestaurantListInfoTableViewCell(tableView, cellForRowAt: indexPath)
		} else {
			return getRestaurantListItemCell(tableView, cellForRowAt: indexPath)
		}
	}
	
	private func getLoaderCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: SuggestionShimmerCell.self)
		return cell
	}
	
	private func getRestaurantListInfoTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: RestaurantListInfoTableViewCell.self)
		cell.configure(numberOfStores: viewModel?.getList.count ?? 0)
		return cell
	}
	
	private func getRestaurantListItemCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: RestaurantItemTableViewCell.self)
		guard let viewModel = self.viewModel, indexPath.row - 1 < (viewModel.getList.count) else { return cell }
		let item = viewModel.getList[indexPath.row - 1]
		cell.configure(item: item, type: viewModel.getFlow, index: indexPath.row - 1, selected: indexPath.row - 1 == selectedIndex)
		cell.cellTapped = { [weak self] (index: Int, isOpen: Bool) in
			self?.selectedIndex = index
			self?.selectedAvailable = isOpen
			mainThread {
				self?.baseView.refreshTableView(enableConfirmLocation: true)
			}
		}
		return cell
	}
	
	private func getSuggestionsCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: AutoCompleteResultCell.self)
		guard let viewModel = self.viewModel else { return cell }
		if indexPath.row < viewModel.getSuggestions.count {
			let item = viewModel.getSuggestions[indexPath.row]
			let name = AppUserDefaults.selectedLanguage() == .en ? (item.nameEnglish ?? "") : (item.nameArabic ?? "")
			let area = AppUserDefaults.selectedLanguage() == .en ? (item.restaurantLocation?.areaNameEnglish) ?? "" : (item.restaurantLocation?.areaNameArabic) ?? ""
			cell.configure(title: name, subtitle: area, index: indexPath.row)
		}
		cell.cellTapped = { [weak self] (indexOfSuggestion) in
			guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
			if indexOfSuggestion < viewModel.getSuggestions.count {
				let item = viewModel.getSuggestions[indexOfSuggestion]
                let restaurant = RestaurantInfoModel(restaurantNameEnglish: item.nameEnglish ?? "", restaurantNameArabic: item.nameArabic ?? "", areaNameEnglish: item.restaurantLocation?.areaNameEnglish ?? "", areaNameArabic: item.restaurantLocation?.areaNameArabic ?? "", latitude: item.restaurantLocation?.coordinates?.last ?? 0.0, longitude: item.restaurantLocation?.coordinates?.first ?? 0.0, cityName: item.restaurantLocation?.cityName ?? "", stateName: item.restaurantLocation?.stateName ?? "", countryName: item.restaurantLocation?.countryName ?? "", storeId: item._id ?? "", sdmId: item.sdmId ?? 0)
				strongSelf.restaurantSelected?(restaurant)
				strongSelf.pop()
			}
		}
		return cell
	}
	
}

extension SetRestaurantLocationVC: SetRestaurantLocationVMDelegate {
	
	func suggestionsAPIResponse(responseType: Result<String, Error>) {
		self.isFetchingSuggestions = false
		switch responseType {
		case .success(let string):
			debugPrint(string)
			baseView.handleAPIResponse(.suggestions, isSuccess: true, noResultFound: (viewModel?.getSuggestions.count) ?? 0 == 0, errorMsg: nil)
		case .failure(let error):
			baseView.handleAPIResponse(.suggestions, isSuccess: false, noResultFound: false, errorMsg: error.localizedDescription)
		}
	}
	
	func listingAPIResponse(responseType: Result<String, Error>) {
		self.isFetchingResultList = false
		switch responseType {
		case .success(let string):
			debugPrint(string)
			
			if queueMapFlow {
				queueMapFlow = false
				triggerMapFlow()
			}
			baseView.handleAPIResponse(.detailList, isSuccess: true, noResultFound: (viewModel?.getList.count) ?? 0 == 0, errorMsg: nil)
		case .failure(let error):
			baseView.handleAPIResponse(.detailList, isSuccess: false, noResultFound: false, errorMsg: error.localizedDescription)
		}
	}
	
}

extension SetRestaurantLocationVC {
	private func triggerMapFlow() {
		let vc = SetRestaurantMapLocationVC.instantiate(fromAppStoryboard: .Home)
		vc.type = self.viewModel?.getFlow ?? .delivery
		if self.baseView.getCurrentSection == .blankScreen || self.baseView.getSearchText().isEmpty {
			vc.restaurantArray = []
		} else {
			vc.restaurantArray = self.viewModel?.getList ?? []
		}
		if let location = self.viewModel?.getLocation {
			vc.currentCoordinates = location
			vc.lastTextQuery = self.textQuery
			self.push(vc: vc)
		} else {
			SKToast.show(withMessage: "No Location Found")
		}
		vc.restaurantSelected = { [weak self] in
			self?.restaurantSelected?($0)
			self?.pop()
		}
		vc.syncSearchBar = { [weak self] in
			self?.baseView.syncSearchTextFromMap(text: $0)
		}
	}
}
