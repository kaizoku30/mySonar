//
//  HomeView.swift
//  Kudu
//
//  Created by Admin on 07/07/22.
//

import UIKit

class HomeView: UIView {
	@IBOutlet private weak var cartBannerHeight: NSLayoutConstraint!
	@IBOutlet private weak var cartBanner: CartBannerView!
	@IBOutlet private weak var safeAreaView: UIView!
	@IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var deliveryButtonView: UIView!
    @IBOutlet private weak var curbsideButtonView: UIView!
    @IBOutlet private weak var pickUpButtonView: UIView!
    @IBOutlet private weak var deliveryLbl: UILabel!
    @IBOutlet private weak var curbsideLbl: UILabel!
    @IBOutlet private weak var pickUpLbl: UILabel!
    @IBOutlet private weak var deliverToLargeBtn: AppButton!
    @IBOutlet private weak var deliverToBtn: AppButton!
    @IBOutlet private weak var deliveryAddLbl: UILabel!
    @IBOutlet private weak var deliveryAddressBtn: AppButton!
    @IBOutlet private weak var navBarHeight: NSLayoutConstraint!
    @IBOutlet private weak var addressHeight: NSLayoutConstraint!
    @IBOutlet private weak var errorToastView: AppErrorToastView!
    @IBOutlet private weak var notificationBellButton: AppButton!
    
    @IBAction private func sideMenuButtonPressed(_ sender: Any) {
        self.handleViewActions?(.openSideMenu)
    }
    @IBAction private func notificationBellPressed(_ sender: Any) {
        handleViewActions?(.openNotificationListing)
    }
    
    private var buttonContainers: [UIView] = []
    private var buttonLabels: [UILabel] = []
    private var selectedSection: APIEndPoints.ServicesType = .delivery
    private var fetchingRecommendations = false
    private var fetchingBanners = false
    private var fetchingInStorePromos = false
    var isFetchingInStorePromos: Bool { fetchingInStorePromos }
    var isFetchingRecommendations: Bool { fetchingRecommendations }
    var isFetchingBanners: Bool { fetchingBanners }
    
    private enum LocationType: Int {
        case delivery = 0
        case curbside
        case pickup
    }
    
    enum ViewActions {
        case openSettings
        case openSideMenu
        case setDeliveryLocationFlow
        case setCurbsideLocationFlow
        case setPickupLocationFlow
        case openNotificationListing
        case sectionButtonPressed(section: APIEndPoints.ServicesType)
        case handleEmailConflict
		case viewCart
    }
    
    enum APICalled {
        case reverseGeoCodeAddress
        case getPromoList
        case getMenuList
        case getRecommendations
        case getInstorePromo
        case sectionChangedAPIs
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.bounces = false
        initialSetup()
		cartBanner.viewCart = { [weak self] in
			self?.handleViewActions?(.viewCart)
		}
        notificationBellButton.isHidden = DataManager.shared.isUserLoggedIn == false
    }
    
    private func initialSetup() {
        setupTableView()
        deliveryAddressBtn.titleLabel?.lineBreakMode = .byClipping
        buttonContainers = [deliveryButtonView, curbsideButtonView, pickUpButtonView]
        buttonLabels = [deliveryLbl, curbsideLbl, pickUpLbl]
        var tag = 0
        buttonContainers.forEach({
            $0.tag = tag
            tag += 1
        })
        tag = 0
        buttonLabels.forEach({
            $0.tag = tag
            tag += 1
        })
        buttonContainers.forEach({
            $0.isUserInteractionEnabled = true
            let type = LocationType(rawValue: $0.tag)!
            switch type {
            case .delivery:
                $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deliveryTapped)))
            case .curbside:
                $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(curbsideTapped)))
            case .pickup:
                $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickupTapped)))
            }
            
        })
        selectButton(button: .delivery)
        [deliverToBtn, deliverToLargeBtn].forEach({
            $0?.handleBtnTap = { [weak self] in
                self?.setLocationFlow()
            }
        })
        deliveryAddLbl.isUserInteractionEnabled = true
        [deliverToLargeBtn, deliveryAddLbl, deliverToBtn].forEach({
            $0?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setLocationFlow)))
        })
        deliverToLargeBtn.setTitle(LSCollection.Home.deliverTo, for: .normal)
        [deliveryLbl, curbsideLbl, pickUpLbl].forEach({ $0?.adjustsFontSizeToFitWidth = true})
        deliveryLbl.text = LSCollection.Home.delivery
        curbsideLbl.text = LSCollection.Home.curbside
        pickUpLbl.text = LSCollection.Home.pickup
    }
    
    func setupView(_ delegate: HomeVC) {
        tableView.dataSource = delegate
        tableView.delegate = delegate
    }
    
    func setNotificationBell() {
        mainThread {
            self.notificationBellButton.setImage(DataManager.shared.fetchNotificationStatus ? AppImages.MainImages.notificationBell : AppImages.MainImages.noNotificationBell, for: .normal)
        }
    }
	
	func syncCart() {
		cartBanner.syncCart(showCart: { (show) in
			mainThread { [weak self] in
				guard let strongSelf = self else { return }
                strongSelf.refreshCartLocally()
				strongSelf.toggleCartBanner(show)
			}
		})
	}
	
    private func refreshCartLocally() {
        mainThread {
            self.cartBanner.configure()
        }
    }
    
	private func toggleCartBanner(_ show: Bool) {
		if show { cartBanner.configure() }
		self.safeAreaView.backgroundColor = show ? self.cartBanner.color : AppColors.offWhiteTableBg
		UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: {
			self.cartBannerHeight.constant = show ? 54 : 0
		})
	}
    
    private func setupTableView() {
        tableView.backgroundColor = AppColors.HomeScreen.homeTableBG
        tableView.separatorStyle = .none
        tableView.registerCell(with: HomeOffersDealsContainerCell.self)
        tableView.registerCell(with: HomeExploreMenuCell.self)
        tableView.registerCell(with: HomeRecommendationsContainerCell.self)
        tableView.registerCell(with: HomeFavouritesCell.self)
        tableView.registerCell(with: InStorePromoCell.self)
        let uiImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 106))
        uiImageView.contentMode = .scaleAspectFill
        uiImageView.image = AppImages.Home.footerImg
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableFooterView = uiImageView
    }
    
    func updateSection(_ section: APIEndPoints.ServicesType) {
        selectedSection = section
        scrollToTop()
    }
    
    func scrollToTop() {
        mainThread {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    @objc private func setLocationFlow() {
        switch selectedSection {
        case .delivery:
            handleViewActions?(.setDeliveryLocationFlow)
        case .pickup:
            handleViewActions?(.setPickupLocationFlow)
        case .curbside:
            handleViewActions?(.setCurbsideLocationFlow)
        }
        
    }
    
    @objc func deliveryTapped() {
        DataManager.shared.currentServiceType = .delivery
        deliverToLargeBtn.setTitle(LSCollection.Home.deliverTo, for: .normal)
        selectButton(button: .delivery)
        handleViewActions?(.sectionButtonPressed(section: .delivery))
    }
    
    @objc func curbsideTapped() {
        DataManager.shared.currentServiceType = .curbside
        deliverToLargeBtn.setTitle(LSCollection.Home.pickupFrom, for: .normal)
        selectButton(button: .curbside)
        handleViewActions?(.sectionButtonPressed(section: .curbside))
    }
    
    @objc func pickupTapped() {
        DataManager.shared.currentServiceType = .pickup
        deliverToLargeBtn.setTitle(LSCollection.Home.pickupFrom, for: .normal)
        selectButton(button: .pickup)
        handleViewActions?(.sectionButtonPressed(section: .pickup))
    }
    
    private func selectButton(button: LocationType) {
        buttonContainers.forEach({
            if $0.tag == button.rawValue {
                $0.borderWidth = 1
                $0.borderColor = AppColors.HomeScreen.selectedButtonBorder
                $0.alpha = 1
                $0.layer.shadowOpacity = 0
            } else {
                $0.alpha = 0.5
                $0.borderWidth = 0
                $0.layer.applySketchShadow(color: .black.withAlphaComponent(0.04), alpha: 1, x: 0, y: 0, blur: 7, spread: 0)
            }
        })
        buttonLabels.forEach({
            $0.textColor = $0.tag == button.rawValue ? AppColors.kuduThemeBlue : .black
        })
    }
    
    func showLocationServicesAlert(type: LocationServicesDeniedView.LocationAlertType) {
        mainThread {
            let alert = LocationServicesDeniedView(frame: CGRect(x: 0, y: 0, width: LocationServicesDeniedView.locationPopUpWidth, height: LocationServicesDeniedView.locationPopUpHeight))
            alert.configureLocationView(type: type, leftButtonTitle: LSCollection.Home.cancel, rightButtonTitle: LSCollection.Home.setting, container: self)
            alert.handleActionOnLocationView = { [weak self] in
                if $0 == .right {
                    self?.handleViewActions?(.openSettings)
                }
            }
        }
    }
    
    func updateLocationLabel(_ address: String) {
        mainThread {
            self.deliveryAddressBtn.isHidden = true
            self.deliveryAddressBtn.stopBtnLoader(titleColor: AppColors.HomeScreen.buttonColor)
            self.deliveryAddLbl.text = address
            self.deliveryAddLbl.isHidden = false
        }
    }
}

extension HomeView {
    func showAlreadyAssociatedAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            let appAlert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: self.width -  AppPopUpView.HorizontalPadding, height: 0))
            appAlert.configure(title: LSCollection.EditProfile.emailAlreadyVerified, message: LSCollection.EditProfile.emailAlreadyAssociated, leftButtonTitle: LSCollection.EditProfile.cancel, rightButtonTitle: LSCollection.EditProfile.updateButton, container: self)
            appAlert.handleAction = { [weak self] (action) in
                if action == .right {
                    //Need to take to Edit Profile and Email
                    self?.handleViewActions?(.handleEmailConflict)
                }
            }
        })
    }
}

extension HomeView {
    
    func handleAPIRequest(_ api: APICalled) {
        mainThread {
            switch api {
            case .reverseGeoCodeAddress:
                self.deliveryAddLbl.isHidden = true
                self.deliveryAddressBtn.isHidden = false
                self.deliveryAddressBtn.startBtnLoader(color: AppColors.kuduThemeBlue)
            default:
                self.fetchingRecommendations = true
                self.fetchingBanners = true
                self.fetchingInStorePromos = true
                self.tableView.reloadData()
            }
        }
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, errorMsg: String?) {
        mainThread {
            
            if api == .getRecommendations {
                self.fetchingRecommendations = false
            }
            
            if api == .getPromoList {
                self.fetchingBanners = false
            }
            
            if api == .getInstorePromo {
                self.fetchingInStorePromos = false
            }
            
            if !isSuccess && api != .reverseGeoCodeAddress {
                let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
                toast.show(message: errorMsg ?? "", view: self)
            }
            
            switch api {
            case .sectionChangedAPIs:
                break
            case .reverseGeoCodeAddress:
                self.deliveryAddLbl.isHidden = false
                self.deliveryAddressBtn.isHidden = true
                self.deliveryAddressBtn.stopBtnLoader(titleColor: AppColors.HomeScreen.buttonColor)
            default:
                self.tableView.reloadData()
            }
        }
    }
}
