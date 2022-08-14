//
//  HomeView.swift
//  Kudu
//
//  Created by Admin on 07/07/22.
//

import UIKit

class HomeView: UIView {
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
    
    @IBAction private func sideMenuButtonPressed(_ sender: Any) {
        self.handleViewActions?(.openSideMenu)
    }
    @IBAction private func loyaltyProgBtnPressed(_ sender: Any) {
        handleViewActions?(.triggerLoyaltyFlow)
    }
    
    private var buttonContainers: [UIView] = []
    private var buttonLabels: [UILabel] = []
    private var selectedSection: HomeVM.SectionType = .delivery
    
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
        case triggerLoyaltyFlow
        case sectionButtonPressed(section: HomeVM.SectionType)
        case handleEmailConflict
    }
    
    enum APICalled {
        case reverseGeoCodeAddress
        case getPromoList
        case getMenuList
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
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
        deliverToLargeBtn.setTitle(LocalizedStrings.Home.deliverTo, for: .normal)
        [deliveryLbl, curbsideLbl, pickUpLbl].forEach({ $0?.adjustsFontSizeToFitWidth = true})
        deliveryLbl.text = LocalizedStrings.Home.delivery
        curbsideLbl.text = LocalizedStrings.Home.curbside
        pickUpLbl.text = LocalizedStrings.Home.pickup
    }
    
    func setupView(_ delegate: HomeVC) {
        tableView.dataSource = delegate
        tableView.delegate = delegate
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
    
    func updateSection(_ section: HomeVM.SectionType) {
        selectedSection = section
    }
    
    func scrollToTop() {
        mainThread {
            self.tableView.scrollToTop(animated: true)
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
    
    @objc private func deliveryTapped() {
        deliverToLargeBtn.setTitle(LocalizedStrings.Home.deliverTo, for: .normal)
        selectButton(button: .delivery)
        handleViewActions?(.sectionButtonPressed(section: .delivery))
    }
    
    @objc private func curbsideTapped() {
        deliverToLargeBtn.setTitle(LocalizedStrings.Home.pickupFrom, for: .normal)
        selectButton(button: .curbside)
        handleViewActions?(.sectionButtonPressed(section: .curbside))
    }
    
    @objc private func pickupTapped() {
        deliverToLargeBtn.setTitle(LocalizedStrings.Home.pickupFrom, for: .normal)
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
    
    func showLocationServicesAlert(type: LocationServicesDeniedView.AlertType) {
        let alert = LocationServicesDeniedView(frame: CGRect(x: 0, y: 0, width: LocationServicesDeniedView.popUpWidth, height: LocationServicesDeniedView.popUpHeight))
        alert.configure(type: type, leftButtonTitle: LocalizedStrings.Home.cancel, rightButtonTitle: LocalizedStrings.Home.setting, container: self)
        alert.handleAction = { [weak self] in
            if $0 == .right {
                self?.handleViewActions?(.openSettings)
            }
        }
    }
    
    func updateLocationLabel(_ address: String) {
        mainThread {
            self.deliveryAddLbl.text = address
        }
    }
}

extension HomeView {
    func showAlreadyAssociatedAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            let appAlert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: self.width -  AppPopUpView.HorizontalPadding, height: 0))
            appAlert.configure(title: LocalizedStrings.EditProfile.emailAlreadyVerified, message: LocalizedStrings.EditProfile.emailAlreadyAssociated, leftButtonTitle: LocalizedStrings.EditProfile.cancel, rightButtonTitle: LocalizedStrings.EditProfile.updateButton, container: self)
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
    
    func handleAPIRequest(_ api: APICalled, sectionSwitched: Bool = false) {
        mainThread {
            switch api {
            case .reverseGeoCodeAddress:
                self.deliveryAddLbl.isHidden = true
                self.deliveryAddressBtn.isHidden = false
                self.deliveryAddressBtn.startBtnLoader(color: AppColors.kuduThemeBlue)
            case .getPromoList:
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            case .getMenuList:
                if sectionSwitched {
                    self.tableView.reloadData()
                    return
                }
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            }
        }
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, errorMsg: String?) {
        mainThread {
            
            switch api {
            case .reverseGeoCodeAddress:
                self.deliveryAddLbl.isHidden = false
                self.deliveryAddressBtn.isHidden = true
                self.deliveryAddressBtn.stopBtnLoader(titleColor: AppColors.HomeScreen.buttonColor)
            case .getPromoList:
                if !isSuccess {
                    let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
                    toast.show(message: errorMsg ?? "", view: self)
                }
               // self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            case .getMenuList:
                if !isSuccess {
                    let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
                    toast.show(message: errorMsg ?? "", view: self)
                }
                self.tableView.setContentOffset(.zero, animated: true)
               // self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            }
            self.tableView.reloadData()
        }
    }
}
