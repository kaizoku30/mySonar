//
//  HomeVC.swift
//  Kudu
//
//  Created by Admin on 06/07/22.
//

import UIKit
import SwiftLocation
import Reachability
import CoreLocation

class HomeVC: BaseVC {
    // MARK: IBOutlets
    @IBOutlet private weak var baseView: HomeView!
    
    // MARK: Properties
    var viewModel: HomeVM?
    private let reachability = try? Reachability()
    private var sideMenuVC: BaseVC?
    private var guestCacheExists = false
    private var bottomDetailVC: BaseVC?
    private var bottomDetailMenuItem: MenuItem?
    
    // MARK: ViewLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        weak var weakSelf = self.navigationController as? BaseNavVC
        weakSelf?.disableSwipeBackGesture = true
        baseView.setNotificationBell()
        viewModel?.checkNotificationStatus(statusUpdated: { [weak self] _ in
            self?.baseView.setNotificationBell()
        })
        handleSectionChange(section: self.viewModel?.getSelectedSection ?? .delivery)
        if DataManager.shared.isUserLoggedIn {
            DataManager.syncHashIDs()
            baseView.syncCart()
        }
        debugPrint("View Will Appear Called For Home")
    }
}

extension HomeVC {
    // MARK: Initial Setup
    private func initialSetup() {
        if GuestUserCache.shared.getAction().isNotNil {
            guestCacheExists = true
        }
        baseView.setupView(self)
        handleActions()
        checkLocationState()
        addObservers()
        reachabilityHandling()
        removeOtherViewControllers()
        handleGuestUserCache()
        self.tabBarController?.navigationController?.viewControllers.removeAll(where: { $0.isKind(of: HomeTabBarVC.self) == false })
    }
    
    private func addObservers() {
        self.observeFor(.internetConnectionFound, selector: #selector(internetRetry))
        self.observeFor(.pickupLocationUpdated, selector: #selector(pickupLocationUpdated))
        self.observeFor(.curbsideLocationUpdated, selector: #selector(curbsideLocationUpdated))
        self.observeFor(.deliveryLocationUpdated, selector: #selector(deliveryLocationUpdated))
        self.observeFor(.syncCartBanner, selector: #selector(syncCartBackground))
    }
    
    private func removeOtherViewControllers() {
        guard let vcInNav = self.navigationController?.viewControllers else { return }
        var viewControllerToRemove: [Int] = []
        for i in 0..<vcInNav.count {
            if vcInNav[i].isKind(of: HomeVC.self) == false {
                viewControllerToRemove.append(i)
            }
        }
        viewControllerToRemove.forEach({
            debugPrint("Removed a VC from Stack")
            self.navigationController?.viewControllers.remove(at: $0)
        })
    }
}

extension HomeVC {
    // MARK: Handle View Actions
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            switch $0 {
            case .setDeliveryLocationFlow:
                self?.goToSetDeliveryFlow()
            case .openSettings:
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            case .openSideMenu:
                break
            case .openNotificationListing:
                self?.goToNotifications()
            case .sectionButtonPressed(let section):
                self?.handleSectionChange(section: section)
            case .setCurbsideLocationFlow, .setPickupLocationFlow:
                self?.goToSetRestaurantFlow()
            case .handleEmailConflict:
                break
            case .viewCart:
                self?.openCartPage()
            }
        }
    }
}

extension HomeVC {
    // MARK: Handle Guest User Cache
    private func handleGuestUserCache() {
        if DataManager.shared.isUserLoggedIn {
            //User Logged In, Need to check Guest User Cache
            if let action = GuestUserCache.shared.getAction() {
                switch action {
                case .addToCart(let req):
                    addCartObject(req: req)
                case .favourite(let req):
                    addGuestUserFavourite(req: req)
                }
            }
        }
    }
    
    private func triggerAddRequestFlow(req: AddCartItemRequest) {
        GuestUserCache.shared.addGuestCartObject(addCartReq: req, added: { [weak self] in
            switch $0 {
            case .success:
                CartUtility.syncCart {
                    mainThread({
                        self?.baseView.syncCart()
                        self?.tabBarController?.removeLoaderOverlay()
                    })
                }
            case .failure(let errorObject):
                self?.tabBarController?.removeLoaderOverlay()
                let error = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self?.baseView.width ?? 0 - 32, height: 48))
                mainThread {
                    guard let baseView = self?.baseView else { return }
                    error.show(message: errorObject.localizedDescription, view: baseView)
                }
            }
        })
    }
    
    private func addGuestUserFavourite(req: FavouriteRequest) {
        GuestUserCache.shared.clearCache()
        mainThread {
            let section = req.servicesAvailable
            switch section {
            case .curbside:
                self.baseView.curbsideTapped()
            case .delivery:
                self.baseView.deliveryTapped()
            case .pickup:
                self.baseView.pickupTapped()
            }
        }
        if req.itemId.isEmpty {
            let vc = MyFavouritesVC.instantiate(fromAppStoryboard: .Home)
            vc.viewModel = MyFavouritesVM(delegate: vc, serviceTypeHome: self.viewModel?.getSelectedSection ?? .delivery)
            self.push(vc: vc)
            return
        }
        
        self.tabBarController?.addLoaderOverlay()
        GuestUserCache.shared.addGuestUserFavourite(favouriteReq: req, added: { [weak self] in
            switch $0 {
            case .success:
                    DataManager.syncHashIDs(completion: {
                        mainThread {
                            self?.tabBarController?.removeLoaderOverlay()
                            let tabBar = self?.tabBarController
                            let homeTab = tabBar as! HomeTabBarVC
                            homeTab.navigateForGuest(itemId: req.itemId, menuId: req.menuId)
                        }
                    })
            case .failure(let error):
                self?.tabBarController?.removeLoaderOverlay()
                let errorView = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self?.baseView.width ?? 0 - 32, height: 48))
                guard let strongSelf = self else { return }
                mainThread {
                    errorView.show(message: error.localizedDescription, view: strongSelf.baseView)
                }
            }
        })
    }
}

extension HomeVC {
    
    // MARK: Location Methods
    private func checkLocationState() {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.handleLocationState(foundState: {
            switch $0 {
            case .servicesDisabled:
                self.baseView.updateLocationLabel(LSCollection.Home.setDeliveryLocation)
                self.baseView.showLocationServicesAlert(type: .locationServicesNotWorking)
                self.hitApis()
            case .permissionDenied:
                self.baseView.updateLocationLabel(LSCollection.Home.setDeliveryLocation)
                self.baseView.showLocationServicesAlert(type: .locationPermissionDenied)
                self.hitApis()
            case .fetchCurrentLocation:
                self.fetchCurrentLocation()
            case .requestLocationAccess:
                self.requestLocationAccess()
            case .locationAlreadyPresent:
                self.handleLocationAlreadyPresent()
            }
        })
    }
    
    private func requestLocationAccess() {
        AppUserDefaults.save(value: true, forKey: .locationAccessRequested)
        CommonLocationManager.requestLocationAccess({ [weak self] in
            switch $0 {
            case .authorizedWhenInUse, .authorizedAlways:
                self?.fetchCurrentLocation()
            default:
                self?.baseView.updateLocationLabel(LSCollection.Home.setDeliveryLocation)
                self?.baseView.showLocationServicesAlert(type: .locationPermissionDenied)
                self?.hitApis()
            }
        })
    }
    
    private func handleLocationAlreadyPresent() {
        let savedLocation = DataManager.shared.currentDeliveryLocation
        viewModel?.setLocation(savedLocation!)
        var title: String = ""
        let isMyAddress = self.viewModel?.getCurrentLocationData?.associatedMyAddress.isNotNil ?? false
        let addressType = APIEndPoints.AddressLabelType(rawValue: self.viewModel?.getCurrentLocationData?.associatedMyAddress?.addressLabel ?? "") ?? .HOME
        if isMyAddress {
            let otherAddress = self.viewModel?.getCurrentLocationData?.associatedMyAddress?.otherAddressLabel ?? ""
            switch addressType {
            case .HOME:
                title = "Home"
            case .WORK:
                title = "Work"
            case .OTHER:
                title = otherAddress
            }
        } else {
            title = (self.viewModel?.getCurrentLocationData?.trimmedAddress) ?? ""
        }
        self.baseView.updateLocationLabel(title)
        self.hitApis()
    }
    
    private func fetchCurrentLocation() {
        CommonLocationManager.getLocationOfDevice(foundCoordinates: {
            if let coordinates = $0 {
                self.baseView.handleAPIRequest(.reverseGeoCodeAddress)
                self.viewModel?.reverseGeoCodeCurrentCoordinates(coordinates, prefillData: nil)
            } else {
                self.baseView.updateLocationLabel(LSCollection.Home.setDeliveryLocation)
                self.baseView.showLocationServicesAlert(type: .couldNotFetchLocation)
                self.hitApis()
            }
        })
    }
}

extension HomeVC {
    // MARK: Cart Operations
    @objc private func syncCartBackground() {
        self.baseView.syncCart()
    }
    
    private func addCartObject(req: AddCartItemRequest) {
        self.tabBarController?.addLoaderOverlay()
        CartUtility.syncCart { [weak self] in
            guard let strongSelf = self else { return }
            mainThread {
                GuestUserCache.shared.clearCache()
                if CartUtility.getCartServiceType != req.servicesAvailable {
                    self?.tabBarController?.removeLoaderOverlay()
                    strongSelf.showCartConflictAlert(req: req)
                } else {
                    strongSelf.triggerAddRequestFlow(req: req)
                }
            }
        }
    }
    
    private func showCartConflictAlert(req: AddCartItemRequest) {
        mainThread {
            let alert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 186))
            alert.setTextAlignment(.left)
            alert.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: nil)
            alert.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: .right)
            alert.configure(title: LSCollection.CartScren.orderTypeHasBeenChanged, message: LSCollection.CartScren.cartWillBeCleared, leftButtonTitle: LSCollection.SignUp.cancel, rightButtonTitle: LSCollection.SignUp.continueText, container: self.baseView)
            alert.handleAction = { [weak self] in
                if $0 == .right {
                    alert.removeSelf()
                    self?.tabBarController?.addLoaderOverlay()
                    CartUtility.clearCartRemotely(clearedConfirmed: {
                        self?.triggerAddRequestFlow(req: req)
                    })
                }
            }
        }
    }
}
extension HomeVC {
    
    // MARK: Sectional Methods
    @objc private func deliveryLocationUpdated() {
        if let locationAdded = DataManager.shared.currentDeliveryLocation {
            self.viewModel?.setLocation(locationAdded)
        }
        self.baseView.deliveryTapped()
    }
    
    @objc private func curbsideLocationUpdated() {
        self.baseView.curbsideTapped()
    }
    
    @objc private func pickupLocationUpdated() {
        self.baseView.pickupTapped()
    }
    
    private func handleSectionChange(section: APIEndPoints.ServicesType) {
        var title = ""
        switch section {
        case .delivery:
            if (self.viewModel?.getCurrentLocationData).isNil {
                title = LSCollection.Home.setDeliveryLocation
            } else {
                let isMyAddress = self.viewModel?.getCurrentLocationData?.associatedMyAddress.isNotNil ?? false
                let addressType = APIEndPoints.AddressLabelType(rawValue: self.viewModel?.getCurrentLocationData?.associatedMyAddress?.addressLabel ?? "") ?? .HOME
                if isMyAddress {
                    let otherAddress = self.viewModel?.getCurrentLocationData?.associatedMyAddress?.otherAddressLabel ?? ""
                    switch addressType {
                    case .HOME:
                        title = "Home"
                    case .WORK:
                        title = "Work"
                    case .OTHER:
                        title = otherAddress
                    }
                } else {
                    title = (self.viewModel?.getCurrentLocationData?.trimmedAddress) ?? ""
                }
            }
        case .curbside:
            let restaurant = DataManager.shared.currentCurbsideRestaurant
            let name = AppUserDefaults.selectedLanguage() == .en ? (restaurant?.restaurantNameEnglish ?? "") : (restaurant?.restaurantNameArabic ?? "")
            title = !(restaurant?.storeId.isEmpty ?? true) ? name : LSCollection.Home.setCurbsideLocation
            if restaurant?.storeId.isEmpty ?? true {
                DataManager.shared.currentCurbsideRestaurant = nil
            }
        case .pickup:
            let restaurant = DataManager.shared.currentPickupRestaurant
            let name = AppUserDefaults.selectedLanguage() == .en ? (restaurant?.restaurantNameEnglish ?? "") : (restaurant?.restaurantNameArabic ?? "")
            title = !(restaurant?.storeId.isEmpty ?? true) ? name : LSCollection.Home.setPickupLocation
            if restaurant?.storeId.isEmpty ?? true {
                DataManager.shared.currentPickupRestaurant = nil
            }
        }
        self.baseView.updateSection(section)
        self.baseView.updateLocationLabel(title)
        self.viewModel?.updateSection(section)
        self.hitApis()
    }
    
    private func hitApis() {
        baseView.handleAPIRequest(.sectionChangedAPIs)
        viewModel?.hitBannerAPI()
        viewModel?.hitMenuAPI()
        viewModel?.hitRecommendationAPI()
        viewModel?.hitInStorePromoAPI()
    }
    
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: TableView Handling
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel else { return UITableViewCell() }
        switch indexPath.row {
        case 0:
            return getPromoBannerCell(tableView, cellForRowAt: indexPath)
        case 1:
            return getMenuCell(tableView, cellForRowAt: indexPath)
        case 2:
            if viewModel.getSelectedSection == .delivery {
                return getRecommendationCell(tableView, cellForRowAt: indexPath)
            } else {
                return getInStoreCell(tableView, cellForRowAt: indexPath)
            }
        case 3:
            if viewModel.getSelectedSection == .delivery {
                return getFavouritesCell(tableView, cellForRowAt: indexPath)
            } else {
                return getRecommendationCell(tableView, cellForRowAt: indexPath)
            }
        default:
            if viewModel.getSelectedSection != .delivery {
                return getFavouritesCell(tableView, cellForRowAt: indexPath)
            } else {
                return UITableViewCell()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //Promo Hide/Show 
        if indexPath.row == 0 && viewModel?.getBannerItems?.count ?? 0 == 0 && !self.baseView.isFetchingBanners {
            return 0
        }
        
        //Menu Hide/Show
        //No handling needed / Never to be hidden
        
        //Recommendation Handling For Delivery
        if viewModel?.getSelectedSection ?? .delivery == .delivery && indexPath.row == 2 && viewModel?.getRecommendationList?.count ?? 0 == 0 && !self.baseView.isFetchingRecommendations {
            return 0
        }
        
        //Recommendation Handling For Curbside/Pickup
        if viewModel?.getSelectedSection ?? .delivery != .delivery && indexPath.row == 3 && viewModel?.getRecommendationList?.count ?? 0 == 0 && !self.baseView.isFetchingRecommendations {
            return 0
        }
        
        //Hiding In Store Promo For Delivery
        if viewModel?.getSelectedSection ?? .delivery == .delivery && indexPath.row == 4 {
            return 0
        }
        
        //In Store Promo Management for Curbside PickUp
        if (viewModel?.getSelectedSection ?? .delivery == .curbside || viewModel?.getSelectedSection ?? .delivery == .pickup) && self.viewModel?.getInStorePromos?.count ?? 0 == 0 && indexPath.row == 2 {
            return 0
        }
        
        return UITableView.automaticDimension
    }
}

extension HomeVC {
    
    // MARK: Custom Cell Handling
    
    private func getInStoreCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: InStorePromoCell.self)
        cell.configure(promos: self.viewModel?.getInStorePromos ?? [], delegate: self)
        return cell
    }
    
    private func getFavouritesCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: HomeFavouritesCell.self)
        cell.goToMyFavourites = { [weak self] in
            guard let strongSelf = self else { return }
            if DataManager.shared.isUserLoggedIn {
                let vc = MyFavouritesVC.instantiate(fromAppStoryboard: .Home)
                vc.viewModel = MyFavouritesVM(delegate: vc, serviceTypeHome: strongSelf.viewModel?.getSelectedSection ?? .delivery)
                strongSelf.push(vc: vc)
            } else {
                GuestUserCache.shared.queueAction(.favourite(req: FavouriteRequest(itemId: "", hashId: "", menuId: "", itemSdmId: -1, isFavourite: false, servicesAvailable: .delivery, modGroups: nil)))
                let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                self?.push(vc: loginVC)
            }
        }
        return cell
    }
    
    private func getPromoBannerCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: HomeOffersDealsContainerCell.self)
        cell.redirectFromBanner = { [weak self] (bannerItem) in
            guard let redirectionType = BannerRedirectionType(rawValue: bannerItem.typeOfRedirection ?? "") else { return }
            guard let tabBar = self?.tabBarController else { return }
            let homeTab = tabBar as! HomeTabBarVC
            mainThread {
                switch redirectionType {
                case .item, .category:
                    homeTab.navigateToUsingBanner(bannerItem, categoryFlow: redirectionType == .category)
                    self?.tabBarController?.selectedIndex = HomeTabBarVC.TabOptions.menu.rawValue
                case .url:
                    let controller = WebViewVC.instantiate(fromAppStoryboard: .Setting)
                    controller.customURL = bannerItem.url ?? ""
                    self?.push(vc: controller)
                }
            }
        }
        if let viewModel = self.viewModel, let promoList = viewModel.getBannerItems {
            cell.configure(promoArray: promoList)
        } else {
            cell.configure(promoArray: nil)
        }
        return cell
    }
    
    private func getMenuCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: HomeExploreMenuCell.self)
        cell.configure(list: viewModel?.getMenuList)
        cell.menuItemTapped = { [weak self] in
            self?.goToMenuExplore(indexSelection: $0)
        }
        cell.viewAllTapped = { [weak self] in
            if (self?.viewModel?.getMenuList ?? []).count == 0 { return }
            self?.goToMenuExplore(indexSelection: 0)
        }
        return cell
    }
    
    private func getRecommendationCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: HomeRecommendationsContainerCell.self)
        cell.openDetailForItem = { [weak self] (menuItem) in
            mainThread {
                if menuItem.isCustomised ?? false {
                    self?.tabBarController?.addLoaderOverlay()
                    APIEndPoints.HomeEndPoints.getItemDetail(itemId: menuItem._id ?? "", success: { [weak self] in
                        guard let copy = $0.data?.first else {
                            self?.tabBarController?.removeLoaderOverlay()
                            return
                        }
                        self?.openCustomisedItemDetail(menuItem: copy)
                        self?.tabBarController?.removeLoaderOverlay()
                    }, failure: { _ in
                        self?.tabBarController?.removeLoaderOverlay()
                    })
                } else {
                    self?.openItemDetail(menuItem: menuItem)
                }
            }
        }
        cell.configure(viewModel?.getRecommendationList ?? [])
        return cell
    }
}

extension HomeVC {
    
    // MARK: Routing
    
    func goToNotifications() {
        let vc = NotificationVC.instantiate(fromAppStoryboard: .Notification)
        vc.hidesBottomBarWhenPushed = true
        self.push(vc: vc)
    }
    
    private func openCartPage() {
        let vc = CartListViewController.instantiate(fromAppStoryboard: .CartPayment)
        vc.flow = .fromHome
        self.push(vc: vc)
    }
    
    private func goToMenuExplore(indexSelection: Int) {
        weak var tabBar = self.tabBarController as? HomeTabBarVC
        tabBar?.updateMenuIndex(indexSelection)
        self.tabBarController?.selectedIndex = HomeTabBarVC.TabOptions.menu.rawValue
    }
    
    private func goToSetRestaurantFlow() {
        let vc = SetRestaurantLocationVC.instantiate(fromAppStoryboard: .Home)
        vc.hidesBottomBarWhenPushed = true
        vc.restaurantSelected = { [weak self] (restaurant) in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            let name = AppUserDefaults.selectedLanguage() == .en ? (restaurant.restaurantNameEnglish) : (restaurant.restaurantNameArabic)
            let title = name
            if viewModel.getSelectedSection == .pickup {
                DataManager.shared.currentPickupRestaurant = restaurant
            } else {
                DataManager.shared.currentCurbsideRestaurant = restaurant
            }
            strongSelf.baseView.updateLocationLabel(title)
            strongSelf.hitApis()
            viewModel.syncCartConfiguration(storeId: restaurant.storeId)
        }
        vc.viewModel = SetRestaurantLocationVM(delegate: vc, flow: self.viewModel?.getSelectedSection ?? .delivery)
        self.push(vc: vc)
    }
    
    private func goToSetDeliveryFlow() {
        let googleAutoCompleteVC = GoogleAutoCompleteVC.instantiate(fromAppStoryboard: .Address)
        googleAutoCompleteVC.hidesBottomBarWhenPushed = true
        googleAutoCompleteVC.viewModel = GoogleAutoCompleteVM(delegate: googleAutoCompleteVC, flow: .setDeliveryLocation, prefillData: self.viewModel?.getCurrentLocationData)
        googleAutoCompleteVC.prefillCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel?.reverseGeoCodeCurrentCoordinates(CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude), prefillData: $0)
        }
        self.push(vc: googleAutoCompleteVC)
    }
}

extension HomeVC {
    
    // MARK: Item/Custom Detail

    private func openItemDetail(menuItem: MenuItem) {
        self.bottomDetailVC = BaseVC()
        self.bottomDetailMenuItem = menuItem
        self.bottomDetailVC?.configureForCustomView()
        self.tabBarController?.addOverlayBlack()
        let itemDetailSheet = BaseItemDetailView(frame: CGRect(x: 0, y: 0, width: self.baseView.width, height: self.baseView.height))
        itemDetailSheet.setRecommendationFlow()
        itemDetailSheet.delegate = self
        itemDetailSheet.configureForExploreMenu(container: self.bottomDetailVC!.view, itemId: menuItem._id ?? "", serviceType: self.viewModel?.getSelectedSection ?? .delivery)
        self.present(self.bottomDetailVC!, animated: true)
    }
    
    private func openCustomisedItemDetail(menuItem: MenuItem) {
        let vc = BaseVC()
        vc.configureForCustomView()
        let bottomSheet = CustomisableItemDetailView(frame: CGRect(x: 0, y: 0, width: self.baseView.width, height: self.baseView.height))
        bottomSheet.configure(item: menuItem, container: vc.view, preLoadTemplate: nil, serviceType: self.viewModel?.getSelectedSection ?? .delivery)
        bottomSheet.addToCart = { [weak self] (modGroupArray, hashId, _) in
            if DataManager.shared.isUserLoggedIn == false {
                GuestUserCache.shared.queueAction(.addToCart(req: AddCartItemRequest(itemId: menuItem._id ?? "", menuId: menuItem.menuId ?? "", hashId: hashId, storeId: DataManager.shared.currentStoreId, itemSdmId: menuItem.itemId ?? 0, quantity: 1, servicesAvailable: DataManager.shared.currentServiceType, modGroups: modGroupArray)))
                vc.dismiss(animated: true, completion: {
                    self?.tabBarController?.removeOverlay()
                    let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                    loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                    self?.push(vc: loginVC)
                })
            } else {
                debugPrint("CALLED")
                self?.tabBarController?.addLoaderOverlay()
                let cartItems = CartUtility.fetchCartLocally()
                guard let _ = cartItems.firstIndex(where: { $0.hashId ?? "" == hashId }) else {
                    //Addition Case
                    let addCartReq = AddCartItemRequest(itemId: menuItem._id ?? "", menuId: menuItem.menuId ?? "", hashId: hashId, storeId: DataManager.shared.currentStoreId, itemSdmId: menuItem.itemId ?? 0, quantity: 1, servicesAvailable: DataManager.shared.currentServiceType, modGroups: modGroupArray)
                    APIEndPoints.CartEndPoints.addItemToCart(req: addCartReq, success: { [weak self] in
                        guard let cartObject = $0.data else {
                            self?.tabBarController?.removeLoaderOverlay()
                            return
                        }
                        var copy = cartObject
                        copy.itemDetails = menuItem
                        CartUtility.addItemToCartLocally(copy)
                        self?.tabBarController?.removeLoaderOverlay()
                        let cartNotification = CartCountNotifier(isIncrement: true, itemId: menuItem._id ?? "", menuId: menuItem.menuId ?? "", hashId: hashId, serviceType: DataManager.shared.currentServiceType, modGroups: modGroupArray)
                        NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
                        self?.baseView.syncCart()
                    }, failure: { _ in
                        self?.tabBarController?.removeLoaderOverlay()
                    })
                    return
                }
                
                let updateReq = UpdateCartCountRequest(isIncrement: true, itemId: menuItem._id ?? "", quantity: 1, hashId: hashId)
                APIEndPoints.CartEndPoints.incrementDecrementCartCount(req: updateReq, success: { [weak self] _ in
                    CartUtility.updateCartCountLocally(hashId, isIncrement: true)
                    let cartNotification = CartCountNotifier(isIncrement: true, itemId: menuItem._id ?? "", menuId: menuItem.menuId ?? "", hashId: hashId, serviceType: DataManager.shared.currentServiceType, modGroups: modGroupArray)
                    NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
                    self?.tabBarController?.removeLoaderOverlay()
                    self?.baseView.syncCart()
                }, failure: { _ in
                    self?.tabBarController?.removeLoaderOverlay()
                })
            }
        }
        bottomSheet.handleDeallocation = { [weak self] in
            vc.dismiss(animated: true, completion: {
                self?.tabBarController?.removeOverlay()
            })
        }
        self.tabBarController?.addOverlayBlack()
        self.present(vc, animated: true)
    }
    
}

extension HomeVC {
    // MARK: Reachability
    
    @objc private func internetRetry() {
        if self.baseView.getTableView?.numberOfRows(inSection: 0) ?? 0 != 0 {
            handleSectionChange(section: viewModel?.getSelectedSection ?? .delivery)
        }
    }
    
    private func reachabilityHandling() {
        reachability?.whenReachable = { _ in
            NotificationCenter.postNotificationForObservers(.internetConnectionFound)
        }
        reachability?.whenUnreachable = { _ in
            print("Not reachable")
            NotificationCenter.postNotificationForObservers(.noConnection)
        }
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}

extension HomeVC: HomeVMDelegate {
    // MARK: API Response Handling
    func inStorePromoAPIResponse(responseType: Result<String, Error>) {
        mainThread {
            switch responseType {
            case .success:
                //  debugPrint(string)
                self.baseView.handleAPIResponse(.getInstorePromo, isSuccess: true, errorMsg: nil)
            case .failure(let error):
                //  debugPrint(error.localizedDescription)
                self.baseView.handleAPIResponse(.getInstorePromo, isSuccess: false, errorMsg: error.localizedDescription)
            }
        }
    }
    
    func recommendationsAPIResponse(responseType: Result<Bool, Error>) {
        mainThread {
            switch responseType {
            case .success:
                //  debugPrint(string)
                self.baseView.handleAPIResponse(.getRecommendations, isSuccess: true, errorMsg: nil)
            case .failure(let error):
                //  debugPrint(error.localizedDescription)
                self.baseView.handleAPIResponse(.getRecommendations, isSuccess: false, errorMsg: error.localizedDescription)
            }
        }
    }
    
    func menuListAPIResponse(forSection: APIEndPoints.ServicesType, responseType: Result<String, Error>) {
        mainThread {
            switch responseType {
            case .success:
                //  debugPrint(string)
                self.baseView.handleAPIResponse(.getMenuList, isSuccess: true, errorMsg: nil)
            case .failure(let error):
                //  debugPrint(error.localizedDescription)
                self.baseView.handleAPIResponse(.getMenuList, isSuccess: false, errorMsg: error.localizedDescription)
            }
        }
    }
    
    func bannerAPIResponse(responseType: Result<String, Error>) {
        mainThread {
            switch responseType {
            case .success:
                // debugPrint(string)
                self.baseView.handleAPIResponse(.getPromoList, isSuccess: true, errorMsg: nil)
            case .failure(let error):
                // debugPrint(error.localizedDescription)
                self.baseView.handleAPIResponse(.getPromoList, isSuccess: false, errorMsg: error.localizedDescription)
            }
        }
    }
    
    func reverseGeocodingSuccess(trimmedAddress: String, isMyAddress: Bool) {
        mainThread {
            if isMyAddress {
                let addressLabel = DataManager.shared.currentDeliveryLocation?.associatedMyAddress?.addressLabel
                let customLabel = DataManager.shared.currentDeliveryLocation?.associatedMyAddress?.otherAddressLabel
                let labelType = APIEndPoints.AddressLabelType(rawValue: addressLabel ?? "")
                if labelType == .HOME || labelType == .WORK {
                    self.baseView.updateLocationLabel(labelType?.displayText ?? "\(trimmedAddress)")
                } else {
                    self.baseView.updateLocationLabel(customLabel ?? "\(trimmedAddress)")
                }
                return
            }
            self.baseView.updateLocationLabel(trimmedAddress)
            self.baseView.handleAPIResponse(.reverseGeoCodeAddress, isSuccess: true, errorMsg: nil)
            self.hitApis()
        }
        
    }
    
    func reverseGeocodingFailed(reason: String) {
        mainThread {
            self.baseView.updateLocationLabel(LSCollection.Home.setDeliveryLocation)
            self.hitApis()
        }
    }
    
    func doesNotDeliverToThisLocation() {
        if self.viewModel?.getSelectedSection ?? .delivery == .delivery && guestCacheExists == false {
            self.baseView.updateLocationLabel(LSCollection.Home.setDeliveryLocation)
            let alert = OutOfReachView(frame: CGRect(x: 0, y: 0, width: self.baseView.width - OutOfReachView.HorizontalPadding, height: 0))
            alert.configure(container: self.baseView)
            alert.handleDeallocation = { [weak self] in
                self?.hitApis()
            }
        }
        if guestCacheExists {
            guestCacheExists = false
        }
    }
}

// MARK: InStorePromoCellDelegate
extension HomeVC: InStorePromoCellDelegate {
    func viewall() {
        let vc = MyOffersVC.instantiate(fromAppStoryboard: .Coupon)
        vc.controllerType = .promo
        self.push(vc: vc)
    }
    
    func openDetailForIndex(index: Int) {
        let vc = MyOffersVC.instantiate(fromAppStoryboard: .Coupon)
        vc.controllerType = .promo
        vc.indexToLaunchForInStore = index
        self.push(vc: vc)
    }
}

extension HomeVC: BaseItemDetailDelegate {
    // MARK: Base Item Detail Handling
    func cartCountUpdatedBaseItem(count: Int, item: MenuItem) {
        mainThread { [weak self] in
            self?.tabBarController?.addLoaderOverlay()
            let cartItems = CartUtility.fetchCartLocally()
            let hashId = MD5Hash.generateHashForTemplate(itemId: item._id ?? "", modGroups: nil)
            guard cartItems.firstIndex(where: { $0.hashId ?? "" == hashId }) != nil else {
                //Addition Case
                let addCartReq = AddCartItemRequest(itemId: item._id ?? "", menuId: item.menuId ?? "", hashId: hashId, storeId: DataManager.shared.currentStoreId, itemSdmId: item.itemId ?? 0, quantity: 1, servicesAvailable: DataManager.shared.currentServiceType, modGroups: nil)
                APIEndPoints.CartEndPoints.addItemToCart(req: addCartReq, success: { [weak self] in
                    guard let cartObject = $0.data else {
                        self?.tabBarController?.removeLoaderOverlay()
                        return
                    }
                    var copy = cartObject
                    copy.itemDetails = self?.bottomDetailMenuItem
                    CartUtility.addItemToCartLocally(copy)
                    self?.tabBarController?.removeLoaderOverlay()
                    let cartNotification = CartCountNotifier(isIncrement: true, itemId: self?.bottomDetailMenuItem?._id ?? "", menuId: self?.bottomDetailMenuItem?.menuId ?? "", hashId: hashId, serviceType: DataManager.shared.currentServiceType, modGroups: nil)
                    NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
                    self?.baseView.syncCart()
                }, failure: { _ in
                    NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart)
                    self?.tabBarController?.removeLoaderOverlay()
                })
                return
            }
            
            let updateReq = UpdateCartCountRequest(isIncrement: true, itemId: self?.bottomDetailMenuItem?._id ?? "", quantity: 1, hashId: hashId)
            APIEndPoints.CartEndPoints.incrementDecrementCartCount(req: updateReq, success: { [weak self] _ in
                CartUtility.updateCartCountLocally(hashId, isIncrement: true)
                let cartNotification = CartCountNotifier(isIncrement: true, itemId: self?.bottomDetailMenuItem?._id ?? "", menuId: self?.bottomDetailMenuItem?.menuId ?? "", hashId: hashId, serviceType: DataManager.shared.currentServiceType, modGroups: nil)
                NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
                self?.tabBarController?.removeLoaderOverlay()
                self?.baseView.syncCart()
            }, failure: { _ in
                self?.tabBarController?.removeLoaderOverlay()
            })
        }
    }
    
    func triggerLoginFlowBaseItem(addReq: AddCartItemRequest) {
        mainThread { [weak self] in
            GuestUserCache.shared.queueAction(.addToCart(req: addReq))
            self?.bottomDetailVC?.dismiss(animated: true, completion: { [weak self] in
                self?.tabBarController?.removeOverlay()
                let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                self?.push(vc: loginVC)
            })
        }
    }
    
    func handleBaseItemViewDeallocation() {
        mainThread { [weak self] in
            self?.bottomDetailVC?.dismiss(animated: true, completion: { [weak self] in
                self?.tabBarController?.removeOverlay()
            })
        }
    }
}
