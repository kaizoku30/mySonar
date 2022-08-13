//
//  HomeVC.swift
//  Kudu
//
//  Created by Admin on 06/07/22.
//

import UIKit
import SwiftLocation
import Reachability

class HomeVC: BaseVC {
    // MARK: IBOutlets
    @IBOutlet private weak var baseView: HomeView!
    
    // MARK: Properties
    var viewModel: HomeVM?
    private let reachability = try! Reachability()
    private var sideMenuVC: BaseVC?
    
    // MARK: ViewLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.setupView(self)
        handleActions()
        handleLocationState()
        self.observeFor(.internetConnectionFound, selector: #selector(internetRetry))
        self.observeFor(.differentEmailPressed, selector: #selector(goToEditProfileVC))
        self.reachabilityHandling()
        self.removeOtherViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        weak var weakSelf = self.navigationController as? BaseNavVC
        weakSelf?.disableSwipeBackGesture = true
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
    
    private func handleLocationState() {
        let savedLocation = DataManager.shared.currentDeliveryLocation
        if savedLocation.isNil {
            if CommonLocationManager.checkIfLocationServicesEnabled() == false {
                baseView.updateLocationLabel(LocalizedStrings.Home.setDeliveryLocation)
                baseView.showLocationServicesAlert(type: .locationServicesNotWorking)
                self.hitApis()
            } else {
                if CommonLocationManager.isLocationRequested() {
                    if CommonLocationManager.isAuthorized() == false {
                        self.baseView.updateLocationLabel(LocalizedStrings.Home.setDeliveryLocation)
                        baseView.showLocationServicesAlert(type: .locationPermissionDenied)
                        self.hitApis()
                    } else {
                        fetchCurrentLocation()
                    }
                } else {
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
                }
            }
        } else {
            viewModel?.setLocation(savedLocation!)
            self.baseView.updateLocationLabel(savedLocation!.trimmedAddress)
            self.hitApis()
        }
        
    }
    
    private func fetchCurrentLocation() {
        CommonLocationManager.getLocationOfDevice(foundCoordinates: {
            if let coordinates = $0 {
                self.baseView.handleAPIRequest(.reverseGeoCodeAddress)
                self.viewModel?.reverseGeoCodeCurrentCoordinates(coordinates)
            } else {
                self.baseView.showLocationServicesAlert(type: .locationPermissionDenied)
                self.hitApis()
            }
        })
    }
    
    private func hitApis() {
        viewModel?.hitPromoAPI()
        viewModel?.hitMenuAPI()
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
            }
        }
    }
    
    private func handleSectionChange(section: HomeVM.SectionType) {
            var title = ""
            switch section {
            case .delivery:
                if (self.viewModel?.getCurrentLocationData).isNil {
                    title = LocalizedStrings.Home.setDeliveryLocation
                } else {
                    title = (self.viewModel?.getCurrentLocationData?.trimmedAddress) ?? ""
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
            self.viewModel?.hitMenuAPI()
            self.baseView.handleAPIRequest(.getMenuList, sectionSwitched: true)
    }
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: TableView Handling
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        return viewModel.getSelectedSection == .delivery ? 4 : 5
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
                let cell = tableView.dequeueCell(with: HomeRecommendationsContainerCell.self)
                return cell
            } else {
                let cell = tableView.dequeueCell(with: InStorePromoCell.self)
                return cell
            }
        case 3:
            if viewModel.getSelectedSection == .delivery {
                let cell = tableView.dequeueCell(with: HomeFavouritesCell.self)
                return cell
            } else {
                let cell = tableView.dequeueCell(with: HomeRecommendationsContainerCell.self)
                return cell
            }
        default:
            let cell = tableView.dequeueCell(with: HomeFavouritesCell.self)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height > self.view.frame.size.height && scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentSize.height - scrollView.frame.size.height), animated: false)
        }
    }
}

extension HomeVC {
    
    func getPromoBannerCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: HomeOffersDealsContainerCell.self)
        if let viewModel = self.viewModel, let promoList = viewModel.getPromoList {
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
            self?.viewModel?.selectMenuItem($0)
            self?.goToMenuExplore()
        }
        cell.viewAllTapped = { [weak self] in
            if (self?.viewModel?.getMenuList ?? []).count == 0 { return }
            self?.viewModel?.selectMenuItem(0)
            self?.goToMenuExplore()
        }
        return cell
    }
}

extension HomeVC {
    
    @objc private func goToEditProfileVC() {
        let vc = EditProfileVC.instantiate(fromAppStoryboard: .Home)
        vc.viewModel = EditProfileVM(delegate: vc, handleEmailConflict: true)
        self.push(vc: vc)
    }
    
    func goToProfileVC() {
        sideMenuVC = ProfileVC.instantiate(fromAppStoryboard: .Home)
        guard let childVC = sideMenuVC as? ProfileVC else { return }
        let dimmedView = UIView(frame: baseView.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        baseView.addSubview(dimmedView)
        childVC.view.width = baseView.width * 0.85
        let selectedLanguage = AppUserDefaults.selectedLanguage()
        if selectedLanguage == .en {
            //Coming from left
            childVC.view.transform = CGAffineTransform(translationX: -childVC.view.width, y: 0)
        } else {
            //Coming from right
            childVC.view.transform = CGAffineTransform(translationX: self.baseView.width, y: 0)
        }
        
        baseView.addSubview(childVC.view)
        self.addChild(childVC)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            if selectedLanguage == .en {
                childVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
            } else {
                childVC.view.transform = CGAffineTransform(translationX: self.baseView.width * (0.15), y: 0)
            }
            
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
                    self?.push(vc: viewController)
                }
            }
        }
        childVC.showEmailConflictAlert = { [weak self] in
            mainThread {
                self?.baseView.showAlreadyAssociatedAlert()
            }
        }
    }
    
    func goToGuestProfileVC() {
        sideMenuVC = GuestProfileVC.instantiate(fromAppStoryboard: .Home)
        guard let childVC = sideMenuVC as? GuestProfileVC else { return }
        let dimmedView = UIView(frame: baseView.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        baseView.addSubview(dimmedView)
        childVC.view.width = baseView.width * 0.85
        let selectedLanguage = AppUserDefaults.selectedLanguage()
        if selectedLanguage == .en {
            //Coming from left
            childVC.view.transform = CGAffineTransform(translationX: -childVC.view.width, y: 0)
        } else {
            //Coming from right
            childVC.view.transform = CGAffineTransform(translationX: self.baseView.width, y: 0)
        }
        baseView.addSubview(childVC.view)
        self.addChild(childVC)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            if selectedLanguage == .en {
                childVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
            } else {
                childVC.view.transform = CGAffineTransform(translationX: self.baseView.width * (0.15), y: 0)
            }
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
                    self?.push(vc: viewController)
                }
            }
        }
    }
}

extension HomeVC {
    
    func goToMenuExplore() {
        let vc = ExploreMenuVC.instantiate(fromAppStoryboard: .Home)
        vc.viewModel = ExploreMenuVM(menuCategories: viewModel?.getMenuList ?? [], delegate: vc)
        self.push(vc: vc)
    }
    
    func goToSetRestaurantFlow() {
        let vc = SetRestaurantLocationVC.instantiate(fromAppStoryboard: .Home)
        vc.restaurantSelected = { [weak self] (restaurant) in
            guard let `self` = self, let viewModel = self.viewModel else { return }
            let name = AppUserDefaults.selectedLanguage() == .en ? (restaurant.restaurantNameEnglish) : (restaurant.restaurantNameArabic)
            let title = name
            if viewModel.getSelectedSection == .pickup {
                DataManager.shared.currentPickupRestaurant = restaurant
            } else {
                DataManager.shared.currentCurbsideRestaurant = restaurant
            }
            self.baseView.updateLocationLabel(title)
            self.viewModel?.hitMenuAPI()
            self.baseView.handleAPIRequest(.getMenuList)
        }
        vc.viewModel = SetRestaurantLocationVM(delegate: vc, flow: self.viewModel?.getSelectedSection ?? .delivery)
        self.push(vc: vc)
    }
    
    func goToSetDeliveryFlow() {
        let googleAutoCompleteVC = GoogleAutoCompleteVC.instantiate(fromAppStoryboard: .Address)
        googleAutoCompleteVC.viewModel = GoogleAutoCompleteVM(delegate: googleAutoCompleteVC, flow: .setDeliveryLocation, prefillData: self.viewModel?.getCurrentLocationData)
        googleAutoCompleteVC.prefillCallback = { [weak self] in
            guard let `self` = self else { return }
            self.viewModel?.setLocation($0)
            self.baseView.updateLocationLabel($0.trimmedAddress)
            self.viewModel?.hitMenuAPI()
        }
        self.push(vc: googleAutoCompleteVC)
    }
}

extension HomeVC {
    @objc private func internetRetry() {
        handleSectionChange(section: viewModel?.getSelectedSection ?? .delivery)
    }
    
    private func reachabilityHandling() {
        reachability.whenReachable = { _ in
            NotificationCenter.postNotificationForObservers(.internetConnectionFound)
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            NotificationCenter.postNotificationForObservers(.noConnection)
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}

extension HomeVC: HomeVMDelegate {
    
    func menuListAPIResponse(forSection: HomeVM.SectionType, responseType: Result<String, Error>) {
        mainThread {
            switch responseType {
            case .success(let string):
                debugPrint(string)
                self.baseView.handleAPIResponse(.getMenuList, isSuccess: true, errorMsg: nil)
            case .failure(let error):
                debugPrint(error.localizedDescription)
                self.baseView.handleAPIResponse(.getMenuList, isSuccess: false, errorMsg: error.localizedDescription)
            }
        }
    }
    
    func generalPromoAPIResponse(responseType: Result<String, Error>) {
        mainThread {
            switch responseType {
            case .success(let string):
                debugPrint(string)
                self.baseView.handleAPIResponse(.getPromoList, isSuccess: true, errorMsg: nil)
            case .failure(let error):
                debugPrint(error.localizedDescription)
                self.baseView.handleAPIResponse(.getPromoList, isSuccess: false, errorMsg: error.localizedDescription)
            }
        }
    }
    
    func reverseGeocodingSuccess(trimmedAddress: String) {
        mainThread {
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
}
