//
//  CartListView.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import UIKit
import NVActivityIndicatorView

class CartListView: UIView {
    
    @IBOutlet weak var scheduleTimeLabel: UILabel!
    @IBOutlet weak var backButton: AppButton!
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noItemInCartView: UIView!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    // MARK: Cart Outlets
    @IBOutlet weak var bottomCartInfoContainer: UIView!
    @IBOutlet weak var makePaymentButton: AppButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var totalPayableLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var totalIsInclusiveLabel: UILabel!
    @IBOutlet weak var orderOptionsContainer: UIView!
    
    // MARK: Address Time Outlets
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var setDeliveryLocationLabel: UILabel!
    @IBOutlet weak var addressButton: AppButton!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var deliveringToLabel: UILabel!
    
    @IBAction func makePayment(_ sender: Any) {
        if makePaymentButton.backgroundColor == AppColors.kuduThemeYellow {
            handleViewActions?(.makePayment)
        }
    }
    
    @IBAction func scheduleButtonPressed(_ sender: Any) {
        // Need to add scheduling functionality here
        handleViewActions?(.scheduleOrder)
    }
    
    @IBAction func addressButtonPressed(_ sender: Any) {
        addressButton.startBtnLoader(color: AppColors.kuduThemeYellow)
        if locationState == .noLocationAdded {
            handleViewActions?(serviceType == .delivery ? .addAddressFlow : .addRestaurantFlow)
        } else {
            handleViewActions?(serviceType == .delivery ? .changeAddressFlow : .changeRestaurantFlow)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        handleViewActions?(.backButtonPressed)
    }
    
    @IBAction func exploreMenuButtonPressed(_ sender: Any) {
        handleViewActions?(.exploreMenuPressed)
    }
    
    enum Sections: Int, CaseIterable {
        case cartItems = 0
        case youMayAlsoLike
        case applyCoupon
        case billDetails
        case vehicleDetails
        case cancellationPolicy
    }
    
    var handleViewActions: ((ViewAction) -> Void)?
    private var serviceType: APIEndPoints.ServicesType = .delivery
    private var locationState: LocationState = .noLocationAdded
    private lazy var refreshControl = UIRefreshControl()
    
    enum LocationState {
        case noLocationAdded
        case locationAdded
    }
    
    enum ViewAction {
        case makePayment
        case backButtonPressed
        case exploreMenuPressed
        case addAddressFlow
        case changeAddressFlow
        case addRestaurantFlow
        case changeRestaurantFlow
        case deleteItem(count: Int, index: Int)
        case pullToRefreshCalled
        case scheduleOrder
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bringLoaderToFront()
        initialSetup()
        refreshControl.tintColor = AppColors.kuduThemeBlue
        
    }
    
    func addRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefreshCalled), for: .valueChanged)
    }
    
    func bringLoaderToFront() {
        mainThread {
            self.loaderView.isHidden = false
            self.viewTitleLabel.isHidden = true
            self.activityIndicator.startAnimating()
            self.bringSubviewToFront(self.loaderView)
        }
    }
    
    @objc private func pullToRefreshCalled() {
        bringLoaderToFront()
        self.handleViewActions?(.pullToRefreshCalled)
    }
    
    func safelyDisableOutlets(disable: Bool) {
        self.tableView.isUserInteractionEnabled = !disable
        self.makePaymentButton.isUserInteractionEnabled = !disable
        self.addressButton.isUserInteractionEnabled = !disable
        self.scheduleButton.isUserInteractionEnabled = !disable
    }
    
    func endRefreshing() {
        mainThread {
            self.refreshControl.endRefreshing()
        }
    }
    
    private func initialSetup() {
        bottomCartInfoContainer.roundTopCorners(cornerRadius: 32)
        orderOptionsContainer.roundTopCorners(cornerRadius: 32)
        bottomCartInfoContainer.layer.applySketchShadow(color: .black, alpha: 0.1, x: 0, y: -2, blur: 4, spread: 0)
    }
    
    func removeLoaderOverlay() {
        loaderView.isHidden = true
        viewTitleLabel.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    func updateServiceType(_ type: APIEndPoints.ServicesType, scheduleTime: Int?) {
        serviceType = type
        if scheduleTime.isNotNil {
            self.scheduleTimeLabel.text = Date(timeIntervalSince1970: Double(scheduleTime!)).toString(dateFormat: Date.DateFormat.dMMMyyyyHHmma.rawValue)
        } else {
            switch serviceType {
            case .curbside:
                self.scheduleTimeLabel.text = "Pickup now"
            case .delivery:
                self.scheduleTimeLabel.text = "Delivering now"
            case .pickup:
                self.scheduleTimeLabel.text = "Pickup now"
            }
        }
    }
    
    func stopLoaderTemporarily() {
        mainThread {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func setupBottomInfo(deliveryLocation: LocationInfoModel?, restaurantSelected: StoreDetail?, mode: APIEndPoints.ServicesType) {
        
        if mode == .delivery {
            locationState = deliveryLocation.isNil || (deliveryLocation?.associatedMyAddress.isNil ?? true) ? .noLocationAdded : .locationAdded
        }
        
        if mode == .pickup || mode == .curbside {
            locationState = restaurantSelected.isNil ? .noLocationAdded : .locationAdded
        }
        
        if mode == .delivery {
            if deliveryLocation.isNil || (deliveryLocation?.associatedMyAddress.isNil ?? true) {
                deliveringToLabel.isHidden = true
                addressLabel.isHidden = true
                setDeliveryLocationLabel.isHidden = false
                addressButton.setTitle("Add Address", for: .normal)
                setCartView(enabled: false)
            } else {
                setDeliveryLocationLabel.isHidden = true
                addressLabel.text = deliveryLocation?.trimmedAddress ?? ""
                var deliverToString = ""
                let type = APIEndPoints.AddressLabelType(rawValue: deliveryLocation?.associatedMyAddress?.addressLabel ?? "") ?? .HOME
                if type == .HOME || type == .WORK {
                    deliverToString = type == .HOME ? "Home" : "Work"
                } else {
                    deliverToString = deliveryLocation?.associatedMyAddress?.otherAddressLabel ?? ""
                }
                let completeString = "Delivering to " + deliverToString
                deliveringToLabel.text = completeString
                addressLabel.isHidden = false
                deliveringToLabel.isHidden = false
                addressButton.setTitle("Change", for: .normal)
                setCartView(enabled: true)
            }
        } else {
            if let restaurant = restaurantSelected {
                setDeliveryLocationLabel.isHidden = true
                let language = AppUserDefaults.selectedLanguage()
                addressLabel.text = language == .en ? restaurant.nameEnglish : restaurant.nameArabic
                deliveringToLabel.text = "Pickup from Branch"
                addressLabel.isHidden = false
                deliveringToLabel.isHidden = false
                addressButton.setTitle("Change", for: .normal)
                setCartView(enabled: true)
            } else {
                deliveringToLabel.isHidden = true
                addressLabel.isHidden = true
                setDeliveryLocationLabel.text = "Pickup from Branch"
                addressButton.setTitle("Select Store", for: .normal)
                setCartView(enabled: false)
            }
        }
    }
    
    func showNoCartView() {
        NotificationCenter.postNotificationForObservers(.syncCartBanner)
        self.viewTitleLabel.text = ""
        self.bringSubviewToFront(noItemInCartView)
    }
    
    func stopAddressButtonLoader() {
        self.addressButton.stopBtnLoader(titleColor: AppColors.kuduThemeYellow)
    }
    
    func refreshYouMayAlsoLike() {
        self.tableView.reloadData()
        //self.tableView.reloadSections(IndexSet(integer: Sections.youMayAlsoLike.rawValue), with: .fade)
    }
    
    func refreshBillSection() {
        mainThread {
            self.tableView.reloadSections(IndexSet(integer: Sections.billDetails.rawValue), with: .fade)
            self.tableView.reloadSections(IndexSet(integer: Sections.vehicleDetails.rawValue), with: .fade)
            self.tableView.reloadSections(IndexSet(integer: Sections.applyCoupon.rawValue), with: .none)
        }
    }
    
    func reloadSpecificCartCell(_ row: Int, _ section: Sections) {
        self.tableView.reloadRowsWithoutAnimation(indexPaths: [IndexPath(row: row, section: section.rawValue)])
        if section == .cartItems {
            self.tableView.reloadSections(IndexSet(integer: Sections.billDetails.rawValue), with: .none)
            self.tableView.reloadSections(IndexSet(integer: Sections.applyCoupon.rawValue), with: .none)
        }
        guard let coupon = CartUtility.getAttachedCoupon else { return }
        let inValidCoupon = CartUtility.checkCouponValidationError(coupon)
        //self.handleViewActions?(.addRemoveFreeItem(add: inValidCoupon.isNil))
    }
    
    func reloadCartItemSection(itemAddition: Int? = nil, itemDeletion: Int? = nil) {
        
        if itemAddition.isNil && itemDeletion.isNil {
            self.tableView.reloadSections(IndexSet(integer: Sections.cartItems.rawValue), with: .none)
            self.tableView.reloadSections(IndexSet(integer: Sections.billDetails.rawValue), with: .none)
            self.tableView.reloadSections(IndexSet(integer: Sections.applyCoupon.rawValue), with: .none)
            guard let coupon = CartUtility.getAttachedCoupon else { return }
            // let inValidCoupon = CartUtility.checkCouponValidationError(coupon)
            //  self.handleViewActions?(.addRemoveFreeItem(add: inValidCoupon.isNil))
            return
        }
        
        self.tableView.performBatchUpdates({
            if let itemAddition = itemAddition {
                self.tableView.insertRows(at: [IndexPath(row: itemAddition, section: 0)], with: .bottom)
            }
            
            if let itemDeletion = itemDeletion {
                self.tableView.deleteRows(at: [IndexPath(row: itemDeletion, section: 0)], with: AppUserDefaults.selectedLanguage() == .en ? .left : .right)
            }
            
        }, completion: {
            if !$0 { return }
            self.tableView.reloadData()
            //guard let coupon = CartUtility.getAttachedCoupon else { return }
            // let inValidCoupon = CartUtility.checkCouponValidationError(coupon)
            //self.handleViewActions?(.addRemoveFreeItem(add: inValidCoupon.isNil))
        })
    }
    
    func updateCartDetails(itemCount: Int, totalPrice: Double, deliveryCharge: Double?, addedCoupon: CouponObject?) {
        self.viewTitleLabel.text = "\(itemCount) Items in Cart"
        var finalPrice = totalPrice
        if let deliveryCharge = deliveryCharge, self.serviceType == .delivery {
            finalPrice += deliveryCharge
        }
        if let couponObject = addedCoupon, let promoType = PromoOfferType(rawValue: couponObject.promoData?.offerType ?? ""), promoType != .item {
            let savings = CartUtility.calculateSavingsAfterCoupon(obj: couponObject)
            if savings > 0 {
                finalPrice -= savings
            }
        }
        self.priceLabel.text = "SR \(finalPrice.round(to: 2).removeZerosFromEnd())"
    }
    
    func setCartView(enabled: Bool) {
        mainThread {
            self.bottomCartInfoContainer.backgroundColor = enabled ? AppColors.kuduThemeYellow : UIColor(r: 239, g: 239, b: 239, alpha: 1)
            self.makePaymentButton.backgroundColor = enabled ? AppColors.kuduThemeYellow : UIColor(r: 239, g: 239, b: 239, alpha: 1)
            self.makePaymentButton.borderColor = enabled ? .white : UIColor(r: 91, g: 90, b: 90, alpha: 1)
            self.makePaymentButton.setTitleColor(enabled ? .white : UIColor(r: 91, g: 90, b: 90, alpha: 1), for: .normal)
            self.totalPayableLabel.textColor = enabled ? .white : UIColor(r: 91, g: 90, b: 90, alpha: 1)
            self.separatorView.backgroundColor = enabled ? .white : UIColor(r: 91, g: 90, b: 90, alpha: 1)
            self.priceLabel.textColor = enabled ? .white : UIColor(r: 91, g: 90, b: 90, alpha: 1)
            self.totalIsInclusiveLabel.textColor = enabled ? .white : UIColor(r: 91, g: 90, b: 90, alpha: 1)
        }
    }
}

extension CartListView {
    func showConfirmDeletePop(_ count: Int, _ index: Int) {
        let popUp = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 156))
        popUp.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: nil)
        popUp.configure(message: "Are you sure you want to remove this item from your cart ?", leftButtonTitle: "Delete", rightButtonTitle: "Cancel", container: self, setMessageAsTitle: true)
        popUp.handleAction = { [weak self] in
            if $0 == .left {
                self?.handleViewActions?(.deleteItem(count: count, index: index))
            }
        }
    }
    
    func toggleMakePaymentLoader(_ show: Bool) {
        mainThread({
            if show {
                self.makePaymentButton.setTitle("", for: .normal)
                self.makePaymentButton.startBtnLoader(color: .white)
            } else {
                self.makePaymentButton.stopBtnLoader(titleColor: .white)
                self.makePaymentButton.setTitle("Make Payment", for: .normal)
            }
        })
    }
}
