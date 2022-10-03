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
    
    // MARK: ViewLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.setupView(self)
        handleActions()
        checkLocationState()
        self.observeFor(.internetConnectionFound, selector: #selector(internetRetry))
        self.observeFor(.pickupLocationUpdated, selector: #selector(pickupLocationUpdated))
        self.observeFor(.curbsideLocationUpdated, selector: #selector(curbsideLocationUpdated))
        self.observeFor(.deliveryLocationUpdated, selector: #selector(deliveryLocationUpdated))
        self.reachabilityHandling()
        self.removeOtherViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        weak var weakSelf = self.navigationController as? BaseNavVC
        weakSelf?.disableSwipeBackGesture = true
        handleSectionChange(section: self.viewModel?.getSelectedSection ?? .delivery)
        if AppUserDefaults.value(forKey: .loginResponse).isNotNil {
            DataManager.syncHashIDs()
            baseView.refreshCartLocally()
            baseView.syncCart()
        }
        debugPrint("View Will Appear Called For Home")
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        weak var weakSelf = self.navigationController as? BaseNavVC
        weakSelf?.disableSwipeBackGesture = false
    }
    
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
    
    private func checkLocationState() {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.handleLocationState(foundState: {
            switch $0 {
            case .servicesDisabled:
                self.baseView.updateLocationLabel(LocalizedStrings.Home.setDeliveryLocation)
                self.baseView.showLocationServicesAlert(type: .locationServicesNotWorking)
                self.hitApis()
            case .permissionDenied:
                self.baseView.updateLocationLabel(LocalizedStrings.Home.setDeliveryLocation)
                self.baseView.showLocationServicesAlert(type: .locationPermissionDenied)
                self.hitApis()
            case .fetchCurrentLocation:
                self.fetchCurrentLocation()
            case .requestLocationAccess:
                AppUserDefaults.save(value: true, forKey: .locationAccessRequested)
                CommonLocationManager.requestLocationAccess({ [weak self] in
                    switch $0 {
                    case .authorizedWhenInUse, .authorizedAlways:
                        self?.fetchCurrentLocation()
                    default:
                        self?.baseView.updateLocationLabel(LocalizedStrings.Home.setDeliveryLocation)
                        self?.baseView.showLocationServicesAlert(type: .locationPermissionDenied)
                        self?.hitApis()
                    }
                })
            case .locationAlreadyPresent:
                let savedLocation = DataManager.shared.currentDeliveryLocation
                viewModel.setLocation(savedLocation!)
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
        })
    }
    
    private func fetchCurrentLocation() {
        CommonLocationManager.getLocationOfDevice(foundCoordinates: {
            if let coordinates = $0 {
                self.baseView.handleAPIRequest(.reverseGeoCodeAddress)
                self.viewModel?.reverseGeoCodeCurrentCoordinates(coordinates, prefillData: nil)
            } else {
                self.baseView.updateLocationLabel(LocalizedStrings.Home.setDeliveryLocation)
                self.baseView.showLocationServicesAlert(type: .couldNotFetchLocation)
                self.hitApis()
            }
        })
    }
    
    private func hitApis() {
        viewModel?.hitPromoAPI()
        viewModel?.hitMenuAPI()
        viewModel?.hitRecommendationAPI()
        baseView.handleAPIRequest(.getPromoList)
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            switch $0 {
            case .setDeliveryLocationFlow:
                self?.goToSetDeliveryFlow()
            case .openSettings:
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            case .openSideMenu:
                if AppUserDefaults.value(forKey: .loginResponse).isNil {
                    self?.goToGuestProfileVC()
                } else {
                    self?.goToProfileVC()
                }
            case .triggerLoyaltyFlow:
                SKToast.show(withMessage: "Under Development")
            case .sectionButtonPressed(let section):
                self?.handleSectionChange(section: section)
            case .setCurbsideLocationFlow, .setPickupLocationFlow:
                self?.goToSetRestaurantFlow()
            case .handleEmailConflict:
                self?.goToEditProfileVC()
            case .viewCart:
                self?.openCartPage()
            }
        }
    }
    
    private func openCartPage() {
        let vc = CartListViewController.instantiate(fromAppStoryboard: .CartPayment)
        vc.flow = .fromHome
        self.push(vc: vc)
    }
    
    private func handleSectionChange(section: APIEndPoints.ServicesType) {
        var title = ""
        switch section {
        case .delivery:
            if (self.viewModel?.getCurrentLocationData).isNil {
                title = LocalizedStrings.Home.setDeliveryLocation
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
            title = restaurant.isNotNil ? name : LocalizedStrings.Home.setCurbsideLocation
        case .pickup:
            let restaurant = DataManager.shared.currentPickupRestaurant
            let name = AppUserDefaults.selectedLanguage() == .en ? (restaurant?.restaurantNameEnglish ?? "") : (restaurant?.restaurantNameArabic ?? "")
            title = restaurant.isNotNil ? name : LocalizedStrings.Home.setPickupLocation
        }
        self.baseView.updateSection(section)
        self.baseView.updateLocationLabel(title)
        self.viewModel?.updateSection(section)
        self.viewModel?.hitPromoAPI()
        self.viewModel?.hitMenuAPI()
        self.viewModel?.hitRecommendationAPI()
        self.baseView.handleAPIRequest(.getMenuList, sectionSwitched: true)
    }
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: TableView Handling
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
        //guard let viewModel = self.viewModel else { return 0 }
        //return viewModel.getSelectedSection == .delivery ? 4 : 5
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
                let cell = tableView.dequeueCell(with: InStorePromoCell.self)
                return cell
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
    
    private func getFavouritesCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: HomeFavouritesCell.self)
        cell.goToMyFavourites = { [weak self] in
            guard let strongSelf = self else { return }
            if AppUserDefaults.value(forKey: .loginResponse).isNotNil {
                let vc = MyFavouritesVC.instantiate(fromAppStoryboard: .Home)
                vc.viewModel = MyFavouritesVM(delegate: vc, serviceTypeHome: strongSelf.viewModel?.getSelectedSection ?? .delivery)
                strongSelf.push(vc: vc)
            } else {
                let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                self?.push(vc: loginVC)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel?.getSelectedSection ?? .delivery == .delivery && indexPath.row == 4 {
            return 0
        }
        
        if viewModel?.getSelectedSection ?? .delivery == .delivery && indexPath.row == 2 && viewModel?.getRecommendationList?.count ?? 0 == 0 && !self.baseView.isFetchingRecommendations {
            return 0
        }
        
        if viewModel?.getSelectedSection ?? .delivery != .delivery && indexPath.row == 3 && viewModel?.getRecommendationList?.count ?? 0 == 0 && !self.baseView.isFetchingRecommendations {
            return 0
        }
        
        if indexPath.row == 0 && viewModel?.getBannerItems?.count ?? 0 == 0 && !self.baseView.isFetchingBanners {
            return 0
        }
        
        return UITableView.automaticDimension
    }
}

extension HomeVC {
    
    func getPromoBannerCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func getMenuCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
}

extension HomeVC {
    
    @objc private func goToEditProfileVC() {
        mainThread {
            guard let nav = self.navigationController, let editProfileExists = nav.viewControllers.first(where: { $0.isKind(of: EditProfileVC.self) }) else {
                let vc = EditProfileVC.instantiate(fromAppStoryboard: .Home)
                vc.viewModel = EditProfileVM(delegate: vc, handleEmailConflict: true)
                if self.navigationController?.viewControllers.contains(where: { $0.isKind(of: EditProfileVC.self) }) ?? false {
                    return
                }
                self.push(vc: vc)
                return
            }
            
            debugPrint("Edit Profile Exists \(editProfileExists) in stack already, avoid multiple push")
        }
    }
    
    func goToProfileVC() {
        sideMenuVC = ProfileVC.instantiate(fromAppStoryboard: .Home)
        guard let childVC = sideMenuVC as? ProfileVC else { return }
        childVC.showEmailConflictAlert = { [weak self] in
            self?.baseView.showAlreadyAssociatedAlert()
        }
        openSideNav(vc: childVC)
    }
    
    func openSideNav(vc: AccountProfileVC) {
        var childVC: AccountProfileVC = vc
        childVC = vc.isKind(of: GuestProfileVC.self) ? vc as! GuestProfileVC : vc as! ProfileVC
        let dimmedView = UIView(frame: baseView.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        dimmedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSideMenu)))
        baseView.addSubview(dimmedView)
        childVC.view.width = baseView.width * 0.85
        let selectedLanguage = AppUserDefaults.selectedLanguage()
        childVC.view.transform = selectedLanguage == .en ? CGAffineTransform(translationX: -childVC.view.width, y: 0) : CGAffineTransform(translationX: self.baseView.width, y: 0)
        baseView.addSubview(childVC.view)
        self.addChild(childVC)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            childVC.view.transform = selectedLanguage == .en ? CGAffineTransform(translationX: 0, y: 0) : CGAffineTransform(translationX: self.baseView.width * (0.15), y: 0)
        }, completion: {
            if $0 {
                childVC.didMove(toParent: self)
            }
        })
        childVC.removeContainerOverlay = { [weak self] in
            mainThread {
                self?.baseView.subviews.forEach({ if $0.tag == Constants.CustomViewTags.dimViewTag {
                    $0.removeFromSuperview()
                } })
            }
        }
        childVC.pushVC = { [weak self] (viewController) in
            mainThread {
                if let viewController = viewController {
                    if viewController.isKind(of: PhoneVerificationVC.self) {
                        let phoneVC = viewController as! PhoneVerificationVC
                        phoneVC.differentEmailPressed = { [weak self] in
                            self?.goToEditProfileVC()
                        }
                    }
                    self?.push(vc: viewController)
                }
            }
        }
    }
    
    @objc private func dismissSideMenu() {
        NotificationCenter.postNotificationForObservers(.dismissSideMenu)
    }
    
    func goToGuestProfileVC() {
        sideMenuVC = GuestProfileVC.instantiate(fromAppStoryboard: .Home)
        guard let childVC = sideMenuVC as? GuestProfileVC else { return }
        openSideNav(vc: childVC)
    }
}

extension HomeVC {
    
    func goToMenuExplore(indexSelection: Int) {
        weak var tabBar = self.tabBarController as? HomeTabBarVC
        tabBar?.updateMenuIndex(indexSelection)
        self.tabBarController?.selectedIndex = HomeTabBarVC.TabOptions.menu.rawValue
    }
    
    func goToSetRestaurantFlow() {
        let vc = SetRestaurantLocationVC.instantiate(fromAppStoryboard: .Home)
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
            strongSelf.viewModel?.hitPromoAPI()
            strongSelf.viewModel?.hitMenuAPI()
            strongSelf.viewModel?.hitRecommendationAPI()
            strongSelf.baseView.handleAPIRequest(.getMenuList)
            viewModel.syncCartConfiguration(storeId: restaurant.storeId)
        }
        vc.viewModel = SetRestaurantLocationVM(delegate: vc, flow: self.viewModel?.getSelectedSection ?? .delivery)
        self.push(vc: vc)
    }
    
    func goToSetDeliveryFlow() {
        let googleAutoCompleteVC = GoogleAutoCompleteVC.instantiate(fromAppStoryboard: .Address)
        googleAutoCompleteVC.viewModel = GoogleAutoCompleteVM(delegate: googleAutoCompleteVC, flow: .setDeliveryLocation, prefillData: self.viewModel?.getCurrentLocationData)
        googleAutoCompleteVC.prefillCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel?.reverseGeoCodeCurrentCoordinates(CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude), prefillData: $0)
        }
        self.push(vc: googleAutoCompleteVC)
    }
}

extension HomeVC {
    // MARK: RECOMMENDATIONS HANDLING
    
    func getRecommendationCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    private func openItemDetail(menuItem: MenuItem) {
        let vc = BaseVC()
        vc.configureForCustomView()
        self.tabBarController?.addOverlayBlack()
        let itemDetailSheet = ItemDetailView(frame: CGRect(x: 0, y: 0, width: self.baseView.width, height: self.baseView.height))
        itemDetailSheet.setRecommendationFlow()
        itemDetailSheet.configureForExploreMenu(container: vc.view, itemId: menuItem._id ?? "", serviceType: self.viewModel?.getSelectedSection ?? .delivery)
        itemDetailSheet.cartCountUpdated = { [weak self] (_, item) in
            self?.tabBarController?.addLoaderOverlay()
            let cartItems = CartUtility.fetchCart()
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
                    copy.itemDetails = menuItem
                    CartUtility.addItemToCart(copy)
                    self?.tabBarController?.removeLoaderOverlay()
                    let cartNotification = CartCountNotifier(isIncrement: true, itemId: menuItem._id ?? "", menuId: menuItem.menuId ?? "", hashId: hashId, serviceType: DataManager.shared.currentServiceType, modGroups: nil)
                    NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
                    self?.baseView.syncCart()
                }, failure: { _ in
                    self?.tabBarController?.removeLoaderOverlay()
                })
                return
            }
            
            let updateReq = UpdateCartCountRequest(isIncrement: true, itemId: menuItem._id ?? "", quantity: 1, hashId: hashId)
            APIEndPoints.CartEndPoints.incrementDecrementCartCount(req: updateReq, success: { [weak self] _ in
                CartUtility.updateCartCount(hashId, isIncrement: true)
                let cartNotification = CartCountNotifier(isIncrement: true, itemId: menuItem._id ?? "", menuId: menuItem.menuId ?? "", hashId: hashId, serviceType: DataManager.shared.currentServiceType, modGroups: nil)
                NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
                self?.tabBarController?.removeLoaderOverlay()
                self?.baseView.syncCart()
            }, failure: { _ in
                self?.tabBarController?.removeLoaderOverlay()
            })
        }
        itemDetailSheet.triggerLoginFlow = {
            vc.dismiss(animated: true, completion: { [weak self] in
                self?.tabBarController?.removeOverlay()
                let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                self?.push(vc: loginVC)
            })
        }
        itemDetailSheet.handleDeallocation = {
            vc.dismiss(animated: true, completion: { [weak self] in
                self?.tabBarController?.removeOverlay()
            })
        }
        self.present(vc, animated: true)
    }
    
    private func openCustomisedItemDetail(menuItem: MenuItem) {
        let vc = BaseVC()
        vc.configureForCustomView()
        let bottomSheet = CustomisableItemDetailView(frame: CGRect(x: 0, y: 0, width: self.baseView.width, height: self.baseView.height))
        bottomSheet.configure(item: menuItem, container: vc.view, preLoadTemplate: nil, serviceType: self.viewModel?.getSelectedSection ?? .delivery)
        bottomSheet.addToCart = { [weak self] (modGroupArray, hashId, _) in
            if AppUserDefaults.value(forKey: .loginResponse).isNil {
                vc.dismiss(animated: true, completion: {
                    self?.tabBarController?.removeOverlay()
                    let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                    loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                    self?.push(vc: loginVC)
                })
            } else {
                debugPrint("CALLED")
                self?.tabBarController?.addLoaderOverlay()
                let cartItems = CartUtility.fetchCart()
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
                        CartUtility.addItemToCart(copy)
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
                    CartUtility.updateCartCount(hashId, isIncrement: true)
                    let cartNotification = CartCountNotifier(isIncrement: true, itemId: menuItem._id ?? "", menuId: menuItem.menuId ?? "", hashId: hashId, serviceType: DataManager.shared.currentServiceType, modGroups: modGroupArray)
                    NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
                    self?.tabBarController?.removeLoaderOverlay()
                    self?.baseView.syncCart()
                }, failure: { _ in
                    self?.tabBarController?.removeLoaderOverlay()
                })
            }
            //            guard let strongSelf = self else { return }
            //            let hashIdExists = strongSelf.viewModel.getItems.firstIndex(where: { $0.hashId ?? "" == hashId })
            //            if hashIdExists.isNotNil {
            //                let previousCount = strongSelf.viewModel.getItems[hashIdExists!].cartCount ?? 0
            //                strongSelf.viewModel.updateCountLocally(count: previousCount + 1, index: hashIdExists!)
            //                strongSelf.baseView.refreshCartLocally()
            //                strongSelf.baseView.refreshTableView()
            //            } else {
            //                var copy = result
            //                copy.servicesAvailable = serviceAvailable
            //                strongSelf.viewModel.addToCartDirectly(menuItem: copy, hashId: hashId, modGroups: modGroupArray ?? [])
            //                strongSelf.baseView.refreshCartLocally()
            //            }
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
            self.baseView.updateLocationLabel(LocalizedStrings.Home.setDeliveryLocation)
            self.hitApis()
        }
    }
    
    func doesNotDeliverToThisLocation() {
        self.baseView.updateLocationLabel(LocalizedStrings.Home.setDeliveryLocation)
        let alert = OutOfReachView(frame: CGRect(x: 0, y: 0, width: self.baseView.width - OutOfReachView.HorizontalPadding, height: 0))
        alert.configure(container: self.baseView)
        alert.handleDeallocation = { [weak self] in
            self?.hitApis()
        }
    }
}
