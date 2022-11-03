//
//  CartListViewController.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import UIKit

enum CartPageFlow {
    case fromExplore
    case fromHome
    case fromFavourites
    case fromMyOffers
}

class CartListViewController: BaseVC {
    
    @IBOutlet private weak var baseView: CartListView!
    private var youMayAlsoLikeFetched = false
    let viewModel: CartListVM! = CartListVM()
    var updateExploreMenu: (() -> Void)?
    var flow: CartPageFlow = .fromHome
    private var retrySync = false
    private var tempLoaderIndex: Int?
    private var scheduleDate: Int?
    private var initialSetupDone = false
    
    private func doesNotDeliverToThisLocation() {
        mainThread {
            let alert = OutOfReachView(frame: CGRect(x: 0, y: 0, width: self.baseView.width - OutOfReachView.HorizontalPadding, height: 0))
            alert.configure(container: self.baseView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.baseView.addRefreshControl()
        handleActions()
        self.baseView.setCartView(enabled: false)
        if viewModel.getServiceType == .delivery {
            viewModel.checkIfNoStoreExists(lat: viewModel.getDeliveryLocation?.latitude ?? 0.0, long: viewModel.getDeliveryLocation?.longitude ?? 0.0, checked: { [weak self] in
                self?.initialSetupDone = true
                if $0.isNotNil {
                    DataManager.shared.currentDeliveryLocation?.associatedStore = $0
                    var deliveryLocation = self?.viewModel.getDeliveryLocation
                    deliveryLocation?.associatedStore = $0
                    if let loc = deliveryLocation {
                        self?.viewModel.updateDeliveryLocation(loc)
                    }
                    self?.viewModel.updateStore($0!)
                    self?.syncCart()
                } else {
                    self?.viewModel.clearDeliveryLocation()
                    self?.doesNotDeliverToThisLocation()
                    self?.syncCart()
                }
            })
        }
        syncCart()
    }
    
    // MARK: SYNC CART
    
    private func syncCart() {
        CartUtility.syncCart { [weak self] in
            mainThread {
                guard let `self` = self else { return }
                self.viewModel.cartSynced()
                if self.viewModel.getCartObjects.isEmpty {
                    if self.retrySync == false {
                        self.retrySync = true
                        self.syncCart()
                        return
                    } else {
                        self.baseView.removeLoaderOverlay()
                        self.baseView.endRefreshing()
                        self.baseView.showNoCartView()
                        return
                    }
                }
                self.baseView.updateServiceType(self.viewModel.getServiceType, scheduleTime: self.scheduleDate)
                self.viewModel.updateFetchingCartConfig()
                self.getStoreConfig(syncing: true) {
                    if self.viewModel.checkIfFreeItemAdd() {
                        self.addFreeItemToCart()
                    } else {
                        if let coupon = self.viewModel.getCoupon, let couponId = coupon._id, !couponId.isEmpty {
                            let couponInvalid = CartUtility.checkCouponValidationError(coupon)
                            if couponInvalid.isNotNil, let freeItemExists = self.viewModel.getCartObjects.firstIndex(where: { $0.offerdItem ?? false == true }), let freeItem = self.viewModel.getCartObjects[safe: freeItemExists] {
                                self.removeFreeItem(index: freeItemExists, freeItem: freeItem, done: { [weak self] in
                                    self?.showCartPage()
                                })
                            } else {
                                self.showCartPage()
                            }
                        } else {
                            self.showCartPage()
                        }
                    }
                }
            }
        }
    }
    
    private func showCartPage() {
        mainThread {
            self.baseView.tableView.reloadData()
            self.baseView.setupBottomInfo(deliveryLocation: self.viewModel.getDeliveryLocation, restaurantSelected: self.viewModel.getStoreDetails, mode: self.viewModel.getServiceType)
            self.stopLoading()
        }
    }
    
    private func stopLoading() {
        self.baseView.removeLoaderOverlay()
        self.baseView.endRefreshing()
        self.refreshCartView()
        self.fetchYouMayAlsoLikeItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if initialSetupDone {
            self.refreshCartView()
        }
    }
    
    // MARK: Handle Actions
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .makePayment:
                strongSelf.makePayment()
            case .pullToRefreshCalled:
                strongSelf.syncCart()
            case .backButtonPressed:
                strongSelf.updateExploreMenu?()
                strongSelf.pop()
            case .exploreMenuPressed:
                switch strongSelf.flow {
                case .fromExplore:
                    strongSelf.pop()
                case .fromHome, .fromFavourites, .fromMyOffers:
                    strongSelf.tabBarController?.selectedIndex = HomeTabBarVC.TabOptions.menu.rawValue
                    strongSelf.pop()
                }
            case .addAddressFlow:
                strongSelf.changeDeliveryAddressFlow(addAddressFlow: true)
            case .changeAddressFlow:
                strongSelf.changeDeliveryAddressFlow(addAddressFlow: false)
            case .addRestaurantFlow, .changeRestaurantFlow:
                strongSelf.setRestaurantFlow()
            case .deleteItem(_, let index):
                strongSelf.handleDeleteIndex(index)
            case .scheduleOrder:
                strongSelf.openScheduleOrder()
            }
        }
    }
    
    private func openScheduleOrder() {
        self.tabBarController?.addOverlayBlack()
        let vc = DateTimeVC.instantiate(fromAppStoryboard: .CartPayment)
        vc.prefill = self.scheduleDate
        vc.dateTimeSelected = { [weak self] in
            self?.scheduleDate = $0
            self?.baseView.updateServiceType(self?.viewModel.getServiceType ?? .delivery, scheduleTime: self?.scheduleDate)
            vc.dismiss(animated: true, completion: {
                self?.tabBarController?.removeOverlay()
            })
        }
        vc.handleDeallocation = { [weak self] in
            vc.dismiss(animated: true, completion: {
                self?.tabBarController?.removeOverlay()
            })
        }
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    private func handleDeleteIndex(_ index: Int) {
        let strongSelf = self
        let needToHandleCompletionBlock = strongSelf.checkStateOfFreeItems()
        if !needToHandleCompletionBlock.handleCompletion {
            self.viewModel.updateCountLocally(count: 0, index: index)
            if self.viewModel.getCartObjects.isEmpty || self.viewModel.getCartObjects.first?.offerdItem ?? false == true {
                CartUtility.removeCouponFromCartLocally()
                CartUtility.syncCart { //No implementation needed here
                }
                self.baseView.showNoCartView()
                return
            }
            self.baseView.reloadCartItemSection()
            self.refreshCartView()
        } else {
            strongSelf.tempLoaderIndex = index
            strongSelf.baseView.reloadCartItemSection()
            strongSelf.viewModel.updateCountLocally(count: 0, index: index, completionHandler: { [weak self] in
                let updated = strongSelf.checkStateOfFreeItems()
                self?.removeFreeItem(index: updated.index, freeItem: updated.item, done: { [weak self] in
                    guard let `self` = self else { return }
                    self.tempLoaderIndex = nil
                    self.viewModel.updateCountLocally(count: 0, index: index)
                    if self.viewModel.getCartObjects.isEmpty || self.viewModel.getCartObjects.first?.offerdItem ?? false == true {
                        CartUtility.removeCouponFromCartLocally()
                        CartUtility.syncCart { //No implementation needed here
                        }
                        self.baseView.showNoCartView()
                        return
                    }
                    self.baseView.reloadCartItemSection()
                    self.refreshCartView()
                })
            })
        }
    }
    
    private func getStoreConfig(syncing: Bool = false, fetched: (() -> Void)? = nil) {
        if viewModel.isFetchingCartConfig {
            viewModel.fetchCartConfig {
                if !syncing {
                    self.baseView.refreshBillSection()
                }
                self.refreshCartView()
                self.baseView.setCartView(enabled: self.viewModel.allowPayment())
                fetched?()
            }
        }
    }
    
    private func fetchYouMayAlsoLikeItems() {
        viewModel.fetchYouMayAlsoLike { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.youMayAlsoLikeFetched = true
            mainThread {
                strongSelf.baseView.refreshYouMayAlsoLike()
            }
        }
    }
}

extension CartListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = CartListView.Sections.allCases.count
        return viewModel.getServiceType == .delivery ? sections - 1 : sections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = CartListView.Sections(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .cartItems:
            return getCartItemCell(tableView, cellForRowAt: indexPath)
        case .youMayAlsoLike:
            return getYouMayAlsoLikeContainerCell(tableView, cellForRowAt: indexPath)
        case .applyCoupon:
            return getApplyCouponCell(tableView, cellForRowAt: indexPath)
        case .billDetails:
            return getBillDetailsCell(tableView, cellForRowAt: indexPath)
        case .vehicleDetails:
            if viewModel.getServiceType == .delivery {
                return getCancellationPolicy(tableView, cellForRowAt: indexPath)
            }
            return getVehicleDetailsCell(tableView, cellForRowAt: indexPath)
        default:
            return getCancellationPolicy(tableView, cellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        baseView.setCartView(enabled: viewModel.allowPayment())
        guard let section = CartListView.Sections(rawValue: section) else { return 0 }
        switch section {
        case .cartItems:
            return viewModel.getCartObjects.count
        case .youMayAlsoLike:
            if youMayAlsoLikeFetched && viewModel.getYouMayAlsoLikeList.isEmpty { return 0 }
            return 1
        default:
            return 1
        }
    }
}

extension CartListViewController {
    
    // MARK: MAIN CART CARD CELL HANDLING
    
    func getCartItemCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: CartItemTableViewCell.self)
        cell.configure(viewModel.getCartObjects[indexPath.item], index: indexPath.item, isTempLoading: (self.tempLoaderIndex ?? -1) == indexPath.item)
        cell.handleTap = { [weak self] (index) in
            guard let strongSelf = self, let item = strongSelf.viewModel.getCartObjects[safe: index] else { return }
            if item.itemDetails?.isCustomised ?? false == true {
                strongSelf.openCustomisedItemDetail(itemIndex: index, prefill: true)
            } else {
                strongSelf.openItemDetail(itemIndex: index)
            }
        }
        cell.toggleProductDetails = { [weak self] (expand, index) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.updateExpandedDetailsState(expand, index: index)
            strongSelf.baseView.reloadSpecificCartCell(index, .cartItems)
        }
        cell.confirmDelete = { [weak self] (count, index) in
            guard let strongSelf = self else { return }
            strongSelf.baseView.showConfirmDeletePop(count, index)
        }
        cell.cartCountUpdated = { [weak self] (count, index) in
            guard let strongSelf = self else { return }
            let needToHandleCompletionBlock = strongSelf.checkStateOfFreeItems()
            if !needToHandleCompletionBlock.handleCompletion {
                strongSelf.baseView.safelyDisableOutlets(disable: true)
                strongSelf.viewModel.updateCountLocally(count: count, index: index, completionHandler: {
                    strongSelf.baseView.safelyDisableOutlets(disable: false)
                    if strongSelf.viewModel.getCartObjects.isEmpty {
                        strongSelf.baseView.showNoCartView()
                        return
                    }
                    if count == 0 {
                        strongSelf.baseView.reloadCartItemSection(itemDeletion: index)
                    } else {
                        strongSelf.baseView.reloadCartItemSection()
                    }
                    strongSelf.refreshCartView()
                })
            } else {
                strongSelf.tempLoaderIndex = index
                strongSelf.baseView.reloadCartItemSection()
                strongSelf.viewModel.updateCountLocally(count: count, index: index, completionHandler: { [weak self] in
                    self?.removeFreeItem(index: needToHandleCompletionBlock.index, freeItem: needToHandleCompletionBlock.item, done: { [weak self] in
                        self?.tempLoaderIndex = nil
                        let checkFreeItemAdd = self?.viewModel.checkIfFreeItemAdd() ?? false
                        if checkFreeItemAdd && needToHandleCompletionBlock.index.isNil {
                            self?.baseView.bringLoaderToFront()
                            self?.syncCart()
                        } else {
                            if self?.viewModel.getCartObjects.isEmpty ?? false {
                                self?.baseView.showNoCartView()
                                return
                            }
                            if count == 0 {
                                self?.baseView.reloadCartItemSection(itemDeletion: index)
                            } else {
                                self?.baseView.reloadCartItemSection()
                            }
                            self?.refreshCartView()
                        }
                    })
                })
            }
        }
        cell.likeStatusUpdated = { [weak self] (status, index) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.updateLikeStatus(status: status, index: index)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45, execute: {
                strongSelf.baseView.reloadSpecificCartCell(index, .cartItems)
            })
        }
        cell.confirmCustomisationRepeat = { [weak self] (index) in
            guard let strongSelf = self else { return }
            strongSelf.handleCustomiseRepeat(index: index)
        }
        return cell
    }
    
    func getBillDetailsCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.isFetchingCartConfig {
            let cell = tableView.dequeueCell(with: BillDetailShimmerCell.self)
            return cell
        } else {
            let cell = tableView.dequeueCell(with: BillDetailsTableViewCell.self)
            cell.configure(bill: viewModel.calculateBill(), couponObject: viewModel.getCoupon)
            return cell
        }
    }
    
    func getVehicleDetailsCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: VehicleDetailsCell.self)
        if viewModel.getServiceType == .pickup || viewModel.getServiceType == .delivery {
            cell.heightConstraint.constant = 0
        }
        cell.configure(viewModel.getCartConfig?.vehicleDetails)
        cell.updateVehicleDetails = { [weak self] in
            self?.openVehicleDetailsEditor()
        }
        return cell
    }
    
    func getCancellationPolicy(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: CancellationPolicyCell.self)
        return cell
    }
    
}

extension CartListViewController {
    
    private func refreshCartView() {
        mainThread {
            self.baseView.updateCartDetails(itemCount: CartUtility.getItemCount(), totalPrice: CartUtility.getPrice(), deliveryCharge: self.viewModel.getCartConfig?.deliveryCharges, addedCoupon: self.viewModel.getCoupon)
            self.baseView.setCartView(enabled: self.viewModel.allowPayment())
        }
    }
    
    // MARK: CART REPEAT CUSTOMISATION HANDLING
    
    private func handleCustomiseRepeat(index: Int) {
        let popUp = RepeatCustomisationView(frame: CGRect(x: 0, y: 0, width: self.view.width - AppPopUpView.HorizontalPadding, height: 0))
        popUp.configure(container: self.view)
        popUp.handleAction = { [weak self] (action) in
            guard let relevantItem = self?.viewModel.getCartObjects[safe: index] else { return }
            mainThread {
                guard let strongSelf = self else { return }
                if action == .repeatCustomisation {
                    let closureHandlingNeeded = strongSelf.checkStateOfFreeItems()
                    if !closureHandlingNeeded.handleCompletion {
                        self?.viewModel.updateCountLocally(count: (relevantItem.quantity ?? 0) + 1, index: index)
                        self?.baseView.reloadCartItemSection()
                        self?.refreshCartView()
                    } else {
                        //First count will be updated through closure, then we'll get to know if item needs to be added or not
                        self?.tempLoaderIndex = index
                        self?.baseView.reloadCartItemSection()
                        self?.viewModel.updateCountLocally(count: (relevantItem.quantity ?? 0) + 1, index: index, completionHandler: { [weak self] in
                            guard let strongSelf = self else { return }
                            self?.tempLoaderIndex = nil
                            if strongSelf.viewModel.checkIfFreeItemAdd() == true {
                                self?.baseView.bringLoaderToFront()
                                self?.syncCart()
                            } else {
                                self?.baseView.reloadCartItemSection()
                                self?.refreshCartView()
                            }
                        })
                    }
                    
                } else {
                    //Customisation Detail Flow
                    self?.openCustomisedItemDetail(itemIndex: index, prefill: false)
                }
            }
        }
    }
}

extension CartListViewController {
    
    private func openItemDetail(itemIndex: Int) {
        if let itemDetails = viewModel.getCartObjects[safe: itemIndex]?.itemDetails, let cartObject = viewModel.getCartObjects[safe: itemIndex] {
            mainThread { [weak self] in
                guard let strongSelf = self else { return }
                let vc = BaseVC()
                vc.configureForCustomView()
                let itemDetailSheet = ItemDetailView(frame: CGRect(x: 0, y: 0, width: strongSelf.baseView.width, height: strongSelf.baseView.height))
                itemDetailSheet.configureForExploreMenu(container: vc.view, itemId: itemDetails._id ?? "", serviceType: APIEndPoints.ServicesType(rawValue: itemDetails.servicesAvailable ?? "") ?? .delivery, showDeleteConfirmation: true)
                itemDetailSheet.cartCountUpdated = { (count, _) in
                    
                    if count == 0 {
                        strongSelf.handleDeleteIndex(itemIndex)
                        return
                    }
                    
                    let needToHandleCompletionBlock = strongSelf.checkStateOfFreeItems()
                    if !needToHandleCompletionBlock.handleCompletion {
                        if let cartObjectLatest = strongSelf.viewModel.getCartObjects[safe: itemIndex], cartObjectLatest.hashId ?? "" == cartObject.hashId ?? "" {
                            //hashId in system safely
                            strongSelf.baseView.safelyDisableOutlets(disable: true)
                            strongSelf.viewModel.updateCountLocally(count: count, index: itemIndex, completionHandler: {
                                strongSelf.baseView.safelyDisableOutlets(disable: false)
                                if strongSelf.viewModel.getCartObjects.isEmpty {
                                    strongSelf.baseView.showNoCartView()
                                } else {
                                    strongSelf.baseView.reloadCartItemSection()
                                    strongSelf.refreshCartView()
                                    return
                                }
                            })
                        } else {
                            //item being added
                            //should never happen
                            strongSelf.present(fatalErrorAlert(reason: "You should never be able to add item from item detail in cart"), animated: true)
                        }
                    } else {
                        strongSelf.tempLoaderIndex = itemIndex
                        strongSelf.baseView.reloadCartItemSection()
                        if let cartObjectLatest = strongSelf.viewModel.getCartObjects[safe: itemIndex], cartObjectLatest.hashId ?? "" == cartObject.hashId ?? "" {
                            //hashId in system safely
                            strongSelf.viewModel.updateCountLocally(count: count, index: itemIndex, completionHandler: { [weak self] in
                                let updated = strongSelf.checkStateOfFreeItems()
                                self?.removeFreeItem(index: updated.index, freeItem: updated.item, done: { [weak self] in
                                    self?.tempLoaderIndex = nil
                                    let checkFreeItemAdd = self?.viewModel.checkIfFreeItemAdd() ?? false
                                    if checkFreeItemAdd && needToHandleCompletionBlock.index.isNil {
                                        self?.baseView.bringLoaderToFront()
                                        self?.syncCart()
                                    } else {
                                        if strongSelf.viewModel.getCartObjects.isEmpty {
                                            strongSelf.baseView.showNoCartView()
                                        } else {
                                            strongSelf.baseView.reloadCartItemSection()
                                            strongSelf.refreshCartView()
                                            return
                                        }
                                    }
                                })
                            })
                        } else {
                            //item being added
                            //should never happen
                            strongSelf.present(fatalErrorAlert(reason: "You should never be able to add item from item detail in cart"), animated: true)
                        }
                    }
                }
                itemDetailSheet.handleDeallocation = {
                    vc.dismiss(animated: true, completion: { [weak self] in
                        self?.tabBarController?.removeOverlay()
                    })
                }
                strongSelf.tabBarController?.addOverlayBlack()
                strongSelf.present(vc, animated: true)
            }
        }
    }
    
    private func openCustomisedItemDetail(itemIndex: Int, prefill: Bool) {
        if let itemDetails = viewModel.getCartObjects[safe: itemIndex]?.itemDetails, let cartObject = viewModel.getCartObjects[safe: itemIndex] {
            var template: CustomisationTemplate?
            if prefill && cartObject.modGroups.isNotNil {
                template = CustomisationTemplate(modGroups: cartObject.modGroups!, hashId: cartObject.hashId ?? "")
            }
            mainThread { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tabBarController?.addLoaderOverlay()
                strongSelf.viewModel.fetchItemDetail(itemId: itemDetails._id ?? "", completion: { (result) in
                    switch result {
                    case .success(let menuItem):
                        strongSelf.displayCustomisationPage(result: menuItem, cartObject: cartObject, index: itemIndex, prefillTemplate: template)
                        strongSelf.tabBarController?.removeLoaderOverlay()
                    case .failure(let error):
                        debugPrint("Error : \(error.localizedDescription)")
                        strongSelf.tabBarController?.removeLoaderOverlay()
                    }
                })
            }
        }
    }
    
    // MARK: CART CUSTOMISATION DETAIL VIEW HANDLING
    
    private func displayCustomisationPage(result: MenuItem, cartObject: CartListObject, index: Int, prefillTemplate: CustomisationTemplate?) {
        let vc = BaseVC()
        vc.configureForCustomView()
        let bottomSheet = CustomisableItemDetailView(frame: CGRect(x: 0, y: 0, width: self.baseView.width, height: self.baseView.height))
        bottomSheet.configure(item: result, container: vc.view, preLoadTemplate: prefillTemplate, serviceType: APIEndPoints.ServicesType(rawValue: cartObject.servicesAvailable!) ?? .delivery)
        bottomSheet.addToCart = { [weak self] (modGroupArray, hashId, itemId) in
            
            guard let strongSelf = self else {
                return
            }
            self?.tabBarController?.addLoaderOverlay()
            let request = AddCartItemRequest(itemId: itemId, menuId: result.menuId ?? "", hashId: hashId, storeId: cartObject.storeId ?? "", itemSdmId: cartObject.itemSdmId ?? 0, quantity: 1, servicesAvailable: APIEndPoints.ServicesType(rawValue: cartObject.servicesAvailable ?? "") ?? .delivery, modGroups: modGroupArray)
            strongSelf.viewModel.addToCart(req: request, itemDetails: result, added: {
                strongSelf.tabBarController?.removeLoaderOverlay()
                let check = strongSelf.viewModel.checkIfFreeItemAdd()
                if check {
                    strongSelf.baseView.bringLoaderToFront()
                    strongSelf.syncCart()
                } else {
                    strongSelf.addedToCartSuccessfully()
                }
            }, updated: {
                strongSelf.tabBarController?.removeLoaderOverlay()
                let check = strongSelf.viewModel.checkIfFreeItemAdd()
                if check {
                    strongSelf.baseView.bringLoaderToFront()
                    strongSelf.syncCart()
                } else {
                    strongSelf.baseView.reloadCartItemSection()
                    strongSelf.refreshCartView()
                }
            })
        }
        bottomSheet.handleDeallocation = {
            vc.dismiss(animated: true, completion: { [weak self] in
                self?.tabBarController?.removeOverlay()
            })
        }
        self.tabBarController?.addOverlayBlack()
        self.present(vc, animated: true)
    }
    
    private func addedToCartSuccessfully() {
        self.baseView.reloadCartItemSection(itemAddition: viewModel.getCartObjects.count - 1)
        self.refreshCartView()
    }
}

extension CartListViewController {
    // MARK: Address Mgmt Flow
    private func openAddressForm() {
        APIEndPoints.AddressEndPoints.getAddressList(success: { [weak self] (addressResponse) in
            guard let strongSelf = self else { return }
            let addresses = addressResponse.data ?? []
            let addAddressVC = AddNewAddressVC.instantiate(fromAppStoryboard: .Address)
            addAddressVC.viewModel = AddNewAddressVM(_delegate: addAddressVC, forcedDefault: (addresses.count == 0))
            var currentDeliveryLocation = DataManager.shared.currentDeliveryLocation
            if DataManager.shared.currentDeliveryLocation.isNotNil && currentDeliveryLocation?.associatedStore.isNotNil ?? false {
                addAddressVC.viewModel?.configurePrefill(MyAddressListItem(phoneNumber: nil, landmark: nil, id: nil, cityName: currentDeliveryLocation?.city ?? "", countryCode: nil, isDefault: false, stateName: currentDeliveryLocation?.state ?? "", buildingName: currentDeliveryLocation?.trimmedAddress ?? "", location: LocationData(latitude: currentDeliveryLocation?.latitude ?? 0.0, type: "Point", longitude: currentDeliveryLocation?.longitude ?? 0.0), userId: DataManager.shared.loginResponse?.userId ?? "", otherAddressLabel: nil, addressLabel: "HOME", zipCode: currentDeliveryLocation?.postalCode ?? "", status: "unblocked", name: nil), store: currentDeliveryLocation!.associatedStore!)
            } else {
                addAddressVC.viewModel?.configureForNoDeliveryDataOnCart()
            }
            addAddressVC.cartFormFlow = { [weak self] in
                guard let strongSelf = self else { return }
                if currentDeliveryLocation.isNotNil {
                    currentDeliveryLocation?.associatedMyAddress = $0
                    currentDeliveryLocation?.associatedStore = $1
                } else {
                    currentDeliveryLocation = LocationInfoModel(trimmedAddress: $0.buildingName ?? "", city: $0.cityName ?? "", state: $0.stateName ?? "", postalCode: $0.zipCode ?? "", latitude: $0.location?.latitude ?? 0.0, longitude: $0.location?.longitude ?? 0.0, associatedStore: $1, associatedMyAddress: $0)
                }
                DataManager.shared.currentDeliveryLocation = currentDeliveryLocation!
                NotificationCenter.postNotificationForObservers(.deliveryLocationUpdated)
                strongSelf.viewModel.updateDeliveryLocation(currentDeliveryLocation!)
                strongSelf.viewModel.updateStore($1)
                strongSelf.baseView.setupBottomInfo(deliveryLocation: currentDeliveryLocation, restaurantSelected: nil, mode: .delivery)
                strongSelf.getStoreConfig()
            }
            strongSelf.push(vc: addAddressVC)
            strongSelf.baseView.stopAddressButtonLoader()
        }, failure: { _ in
            //Need to manage errors
        })
    }
    
    private func changeDeliveryAddressFlow(addAddressFlow: Bool) {
        let myAddressVC = MyAddressVC.instantiate(fromAppStoryboard: .Address)
        myAddressVC.viewModel = MyAddressVM(_delegate: myAddressVC)
        myAddressVC.viewModel?.configureForCartFlow()
        let currentDeliveryLocation = DataManager.shared.currentDeliveryLocation
        if DataManager.shared.currentDeliveryLocation.isNotNil && currentDeliveryLocation?.associatedStore.isNotNil ?? false && addAddressFlow {
            myAddressVC.viewModel?.addPrefillDataForForm(MyAddressListItem(phoneNumber: nil, landmark: nil, id: nil, cityName: currentDeliveryLocation?.city ?? "", countryCode: nil, isDefault: false, stateName: currentDeliveryLocation?.state ?? "", buildingName: currentDeliveryLocation?.trimmedAddress ?? "", location: LocationData(latitude: currentDeliveryLocation?.latitude ?? 0.0, type: "Point", longitude: currentDeliveryLocation?.longitude ?? 0.0), userId: DataManager.shared.loginResponse?.userId ?? "", otherAddressLabel: nil, addressLabel: "HOME", zipCode: currentDeliveryLocation?.postalCode ?? "", status: "unblocked", name: nil), store: currentDeliveryLocation!.associatedStore!)
        }
        myAddressVC.cartFormFlow = { [weak self] in
            guard let strongSelf = self else { return }
            var newDeliveryLocation = LocationInfoModel(trimmedAddress: $0.buildingName ?? "", city: $0.cityName ?? "", state: $0.stateName ?? "", postalCode: $0.zipCode ?? "", latitude: $0.location?.latitude ?? 0.0, longitude: $0.location?.longitude ?? 0.0)
            newDeliveryLocation.associatedMyAddress = $0
            newDeliveryLocation.associatedStore = $1
            strongSelf.viewModel.updateStore($1)
            DataManager.shared.currentDeliveryLocation = newDeliveryLocation
            NotificationCenter.postNotificationForObservers(.deliveryLocationUpdated)
            strongSelf.viewModel.updateDeliveryLocation(newDeliveryLocation)
            strongSelf.baseView.setupBottomInfo(deliveryLocation: newDeliveryLocation, restaurantSelected: nil, mode: .delivery)
            strongSelf.viewModel.updateFetchingCartConfig()
            strongSelf.getStoreConfig()
            
        }
        self.push(vc: myAddressVC)
        self.baseView.stopAddressButtonLoader()
    }
    
    private func setRestaurantFlow() {
        let vc = SetRestaurantLocationVC.instantiate(fromAppStoryboard: .Home)
        vc.restaurantSelected = { [weak self] (restaurant) in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            if viewModel.getServiceType == .pickup {
                DataManager.shared.currentPickupRestaurant = restaurant
                NotificationCenter.postNotificationForObservers(.pickupLocationUpdated)
            } else {
                DataManager.shared.currentCurbsideRestaurant = restaurant
                NotificationCenter.postNotificationForObservers(.curbsideLocationUpdated)
            }
            let store = restaurant.convertToStoreDetail()
            strongSelf.viewModel.updateStore(store)
            strongSelf.baseView.setupBottomInfo(deliveryLocation: nil, restaurantSelected: store, mode: strongSelf.viewModel.getServiceType)
            strongSelf.viewModel.updateFetchingCartConfig()
            strongSelf.getStoreConfig()
            
        }
        vc.viewModel = SetRestaurantLocationVM(delegate: vc, flow: self.viewModel?.getServiceType ?? .delivery)
        self.push(vc: vc)
        self.baseView.stopAddressButtonLoader()
    }
}

extension CartListViewController {
    private func openVehicleDetailsEditor() {
        let bottomSheet = UpdateVehicleDetailsView(frame: CGRect(x: 0, y: 0, width: self.baseView.width, height: self.baseView.height))
        bottomSheet.configure(container: self.baseView, prefill: self.viewModel.getCartConfig?.vehicleDetails)
        bottomSheet.presentColorPicker = { [weak self] in
            guard let strongSelf = self else { return }
            $0.modalPresentationStyle = .overFullScreen
            strongSelf.present($0, animated: true)
        }
        bottomSheet.dismissColorPicker = { [weak self] in
            self?.dismiss(animated: true)
        }
        bottomSheet.vehicleDetailsUpdated = { [weak self] in
            self?.viewModel.updateFetchingCartConfig()
            self?.getStoreConfig()
        }
    }
}

extension CartListViewController {
    // MARK: You May Also Like
    func getYouMayAlsoLikeContainerCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: YouMayAlsoLikeContainerCell.self)
        cell.configure(fetching: youMayAlsoLikeFetched == false, items: viewModel.getYouMayAlsoLikeList)
        cell.addYouMayAlsoLike = { [weak self] (object) in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            strongSelf.tabBarController?.addLoaderOverlay()
            viewModel.fetchItemDetail(itemId: object.itemDetails?._id ?? "", completion: {
                switch $0 {
                case .success(let item):
                    if item.isCustomised ?? false {
                        strongSelf.openCustomisationForYouMayAlsoLike(result: item)
                        strongSelf.tabBarController?.removeLoaderOverlay()
                    } else {
                        strongSelf.addUpdateBaseItemYouMayAlsoLike(object: object, itemDetails: item)
                    }
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    strongSelf.tabBarController?.removeLoaderOverlay()
                    
                }
            })
        }
        return cell
    }
    
    private func addUpdateBaseItemYouMayAlsoLike(object: YouMayAlsoLikeObject, itemDetails: MenuItem) {
        let hashId = MD5Hash.generateHashForTemplate(itemId: object.itemDetails?._id ?? "", modGroups: nil)
        let request = AddCartItemRequest(itemId: object.itemDetails?._id ?? "", menuId: object.itemDetails?.menuId ?? "", hashId: hashId, storeId: viewModel.getStoreDetails?._id ?? "", itemSdmId: object.itemDetails?.itemId ?? 0, quantity: 1, servicesAvailable: viewModel.getServiceType, modGroups: nil)
        self.viewModel.addToCart(req: request, itemDetails: itemDetails, added: {
            self.tabBarController?.removeLoaderOverlay()
            let check = self.viewModel.checkIfFreeItemAdd()
            if check {
                self.baseView.bringLoaderToFront()
                self.syncCart()
            } else {
                self.addedToCartSuccessfully()
            }
        }, updated: {
            self.tabBarController?.removeLoaderOverlay()
            let check = self.viewModel.checkIfFreeItemAdd()
            if check {
                self.baseView.bringLoaderToFront()
                self.syncCart()
            } else {
                self.baseView.reloadCartItemSection()
                self.refreshCartView()
            }
        })
    }
    
    private func openCustomisationForYouMayAlsoLike(result: MenuItem) {
        let vc = BaseVC()
        vc.configureForCustomView()
        let bottomSheet = CustomisableItemDetailView(frame: CGRect(x: 0, y: 0, width: self.baseView.width, height: self.baseView.height))
        bottomSheet.configure(item: result, container: vc.view, preLoadTemplate: nil, serviceType: self.viewModel.getServiceType)
        bottomSheet.addToCart = { [weak self] (modGroupArray, hashId, itemId) in
            
            guard let strongSelf = self else {
                return
            }
            self?.tabBarController?.addLoaderOverlay()
            let request = AddCartItemRequest(itemId: itemId, menuId: result.menuId ?? "", hashId: hashId, storeId: self?.viewModel.getStoreDetails?._id ?? "", itemSdmId: result.itemId ?? 0, quantity: 1, servicesAvailable: self?.viewModel.getServiceType ?? .delivery, modGroups: modGroupArray)
            strongSelf.viewModel.addToCart(req: request, itemDetails: result, added: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tabBarController?.removeLoaderOverlay()
                let check = strongSelf.viewModel.checkIfFreeItemAdd()
                if check {
                    strongSelf.baseView.bringLoaderToFront()
                    strongSelf.syncCart()
                } else {
                    strongSelf.addedToCartSuccessfully()
                }
            }, updated: {
                self?.tabBarController?.removeLoaderOverlay()
                let check = strongSelf.viewModel.checkIfFreeItemAdd()
                if check {
                    strongSelf.baseView.bringLoaderToFront()
                    strongSelf.syncCart()
                } else {
                    strongSelf.baseView.reloadCartItemSection()
                    strongSelf.refreshCartView()
                }
            })
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

extension CartListViewController {
    // MARK: APPLY COUPON CELL
    private func getApplyCouponCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: ApplyCouponTableViewCell.self)
        var isNotValid = true
        if let coupon = viewModel.getCoupon {
            isNotValid = CartUtility.checkCouponValidationError(coupon).isNotNil
        }
        cell.removeCoupon = { [weak self] in
            self?.baseView.bringLoaderToFront()
            CartUtility.removeCouponFromCart(completionHandler: {
                self?.syncCart()
            }, cartRef: self?.viewModel.getCartObjects ?? [])
        }
        cell.openCouponVC = { [weak self] in
            let vc = CartCouponListVC.instantiate(fromAppStoryboard: .Coupon)
            vc.viewModel.configure(serviceType: self?.viewModel.getServiceType ?? .delivery)
            vc.syncCart = { [weak self] in
                self?.baseView.bringLoaderToFront()
                self?.syncCart()
            }
            self?.push(vc: vc)
        }
        cell.configure(coupon: viewModel.getCoupon, isNotValid: isNotValid)
        return cell
    }
}

extension CartListViewController {
    // MARK: Cart modification - coupon free item syncing
    
    private func checkStateOfFreeItems() -> (handleCompletion: Bool, index: Int?, item: CartListObject?) {
        let strongSelf = self
        var needToHandleCompletionBlock = false
        var freeItemIndexToRemove: Int?
        var freeItemToRemove: CartListObject?
        if let coupon = strongSelf.viewModel.getCoupon, let couponId = coupon._id, !couponId.isEmpty {
            //let couponInvalid = CartUtility.checkCouponValidationError(coupon)
            if let freeItemExists = strongSelf.viewModel.getCartObjects.firstIndex(where: { $0.offerdItem ?? false == true }), let freeItem = strongSelf.viewModel.getCartObjects[safe: freeItemExists] {
                freeItemIndexToRemove = freeItemExists
                freeItemToRemove = freeItem
                needToHandleCompletionBlock = true
            }
            
            if let promoType = PromoOfferType(rawValue: coupon.promoData?.offerType ?? ""), promoType == .item, !viewModel.getCartObjects.contains(where: { $0.offerdItem ?? false }) {
                return (true, nil, nil)
            }
        }
        if needToHandleCompletionBlock {
            return (true, freeItemIndexToRemove, freeItemToRemove)
        } else {
            return (false, nil, nil)
        }
    }
}

extension CartListViewController {
    // MARK: FREE ITEMs
    
    private func addFreeItemToCart() {
        guard let coupon = viewModel.getCoupon, let promoType = PromoOfferType(rawValue: coupon.promoData?.offerType ?? ""), promoType == .item, let items = coupon.promoData?.items else {
            self.showCartPage()
            return
        }
        if items.count == 1 {
            let additionHash = MD5Hash.generateHashForTemplate(itemId: items[0], modGroups: nil)
            self.viewModel.fetchItemDetail(itemId: items[0], completion: { [weak self] in
                guard let `self` = self else { return }
                switch $0 {
                case .success(let item):
                    let addItemReq = AddCartItemRequest(itemId: item._id ?? "", menuId: item.menuId ?? "", hashId: additionHash, storeId: self.viewModel.getStoreDetails?._id ?? "", itemSdmId: item.itemId ?? 0, quantity: 1, servicesAvailable: self.viewModel.getServiceType, modGroups: nil, offerdItem: true)
                    self.viewModel.addToCart(req: addItemReq, itemDetails: item, added: { [weak self] in
                        self?.showCartPage()
                        return
                    }, updated: { //Only add flow matters here
                    })
                case .failure:
                    self.showCartPage()
                    return
                }
            })
        } else {
            self.baseView.backButton.isHidden = true
            let viewController = MultipleCarouselVC.instantiate(fromAppStoryboard: .Coupon)
            viewController.configureForCustomView()
            viewController.viewModel.configure(idsToFetch: items)
            self.tabBarController?.addOverlayBlack()
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overFullScreen
            viewController.handleDeallocation = { [weak self] in
                viewController.dismiss(animated: true, completion: {
                    self?.baseView.backButton.isHidden = false
                    self?.tabBarController?.removeOverlay()
                })
            }
            viewController.addItem = { [weak self] (item) in
                guard let `self` = self else { return }
                let additionHash = MD5Hash.generateHashForTemplate(itemId: item._id ?? "", modGroups: nil)
                let addItemReq = AddCartItemRequest(itemId: item._id ?? "", menuId: item.menuId ?? "", hashId: additionHash, storeId: self.viewModel.getStoreDetails?._id ?? "", itemSdmId: item.itemId ?? 0, quantity: 1, servicesAvailable: self.viewModel.getServiceType, modGroups: nil, offerdItem: true)
                self.viewModel.addToCart(req: addItemReq, itemDetails: item, added: { [weak self] in
                    self?.baseView.backButton.isHidden = false
                    self?.showCartPage()
                    return
                }, updated: { //Only add flow matters here
                })
            }
            self.present(viewController, animated: true)
            return
        }
    }
    
    private func removeFreeItem(index: Int?, freeItem: CartListObject?, done: @escaping (() -> Void)) {
        if CartUtility.checkCouponValidationError(viewModel.getCoupon!).isNil || !viewModel.getCartObjects.contains(where: { $0.offerdItem ?? false }) || index.isNil {
            done()
            return }
        let removeItemReq = RemoveItemFromCartRequest(itemId: freeItem?.itemId ?? "", hashId: freeItem?.hashId ?? "", offeredItem: true)
        APIEndPoints.CartEndPoints.removeItemFromCart(req: removeItemReq, success: { [weak self] _ in
            self?.viewModel.removeCartObject(atIndex: index!)
            CartUtility.removeItemFromCart(freeItem?.hashId ?? "", offeredItem: true)
            done()
        }, failure: { _ in
            done()
        })
    }
}

extension CartListViewController {
    private func makePayment() {
        
        guard let store = viewModel.getStoreDetails else { return }
        let errorMsg = makeNecessaryStoreChecks(store: store)
        if let error = errorMsg, !error.isEmpty {
            let appErrorToast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.baseView.width - 32, height: 48))
            appErrorToast.show(message: error, view: self.baseView)
            return
        }
        
        guard let storeId = viewModel.getStoreDetails?._id, let storeSdmID = viewModel.getStoreDetails?.sdmId, let restaurantLocation = viewModel.getStoreDetails else { return }
        let serviceType = viewModel.getServiceType
        var orderType = OrderTimeType.normal
        let paymentType = PaymentType.COD
        let vat = (viewModel.getCartConfig?.vat ?? 0.0)
        let itemAount = CartUtility.getPrice()
        var totalAmount = viewModel.calculateBill().totalPayable
        var addressId: String?
        var deliveryCharge: Double?
        var userAddress: MyAddressListItem?
        if serviceType == .delivery {
            addressId = viewModel.getDeliveryLocation?.associatedMyAddress?.id ?? ""
            deliveryCharge = viewModel.getCartConfig?.deliveryCharges ?? 0.0
            if let addressFound = viewModel.getDeliveryLocation?.associatedMyAddress {
                userAddress = addressFound
            } else {
                return
            }
        }
        var vehicleDetails: VehicleDetails?
        if serviceType == .curbside {
            if let vehicleDetailsFound = viewModel.getCartConfig?.vehicleDetails {
                vehicleDetails = vehicleDetailsFound
            } else {
                return
            }
        }
        let isCouponApplied = viewModel.getCoupon.isNotNil
        var couponCode: String?
        var couponId: String?
        var offerType: PromoOfferType?
        var discount: Double?
        var promoId: String?
        var posId: Int?
        
        if isCouponApplied {
            couponCode = viewModel.getCoupon?.couponCode?.first?.couponCode ?? ""
            couponId = viewModel.getCoupon?._id ?? ""
            offerType = PromoOfferType(rawValue: viewModel.getCoupon?.promoData?.offerType ?? "")
            discount = CartUtility.calculateSavingsAfterCoupon(obj: viewModel.getCoupon!)
            promoId = viewModel.getCoupon?.promoData?._id ?? ""
            posId = viewModel.getCoupon?.promoData?.posId ?? 0
            totalAmount -= (discount ?? 0.0)
        }
        
        var scheduleTime: Int?
        
        if let date = self.scheduleDate {
            scheduleTime = date
            orderType = .scheduled
        }
        
        let request = OrderPlaceRequest(storeId: storeId, storeSdmId: storeSdmID, restaurantLocation: restaurantLocation, servicesType: serviceType, orderType: orderType, paymentType: paymentType, vat: vat, totalItemAmount: itemAount, totalAmount: totalAmount, deliveryCharge: deliveryCharge, userAddress: userAddress, addressId: addressId, vehicleDetails: vehicleDetails, isCouponApplied: isCouponApplied, couponCode: couponCode, couponId: couponId, discount: discount, offerType: offerType, promoId: promoId, posId: posId, scheduleTime: scheduleTime)
        
        self.baseView.toggleMakePaymentLoader(true)
        // Convert to a string and print
        prettyJSON(request.getRequest())
        hitValidateOrder(request: request)
    }
    
    private func makeNecessaryStoreChecks(store: StoreDetail) -> String? {
        var errorMsg: String?
        
        if (store.paymentMethod ?? []).isEmpty {
            errorMsg = "This store is not accepting payments right now"
        }
        
        if !StoreUtility.checkStoreOpen(store, serviceType: viewModel.getServiceType) {
            errorMsg = "This store is closed for now."
        }
        if viewModel.getServiceType == .delivery && store.isRushHour ?? false == true {
            errorMsg = "This store is not delivering for now due to rush hours."
        }
        switch viewModel.getServiceType {
        case .delivery:
            if store.serviceDelivery ?? false == false {
                errorMsg = "This store is not serviceable for now."
            }
        case .pickup:
            if store.servicePickup ?? false == false {
                errorMsg = "This store is not serviceable for now."
            }
        case .curbside:
            if store.serviceCurbSide ?? false == false {
                errorMsg = "This store is not serviceable for now."
            }
        }
        
        if CartUtility.getPrice() < Double(store.minimumOrderValue ?? 0) {
            errorMsg = "Minimum Cart amount should be SR \(store.minimumOrderValue ?? 0)"
        }
        
        if let someTimeAdded = self.scheduleDate {
            let allow = StoreUtility.checkIfScheduleDateApplicable(date: TimeInterval(someTimeAdded), store: store, service: self.viewModel.getServiceType)
            if !allow {
                errorMsg = "The store is closed on \(Date(timeIntervalSince1970: TimeInterval(someTimeAdded)).toString(dateFormat: Date.DateFormat.dMMMyyyyHHmma.rawValue)). Please change the date to schedule your order."
            }
        }
        return errorMsg
    }
    
    private func hitValidateOrder(request: OrderPlaceRequest) {
        self.viewModel.validateOrder(req: request, validated: { [weak self] (response) in
            switch response {
            case .success(let responseString):
                self?.baseView.toggleMakePaymentLoader(false)
                let vc = PaymentMethodVC.instantiate(fromAppStoryboard: .CartPayment)
                vc.flow = self?.flow
                vc.req = request
                vc.allowedPaymentMethods = (self?.viewModel.getStoreDetails?.paymentMethod ?? []).map({ PaymentType(rawValue: $0) ?? .Card})
                vc.orderId = responseString
                self?.push(vc: vc)
            case .failure(let error):
                guard let strongSelf = self else { return }
                self?.baseView.toggleMakePaymentLoader(false)
                mainThread({
                    let appErrorToast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: strongSelf.baseView.width - 32, height: 48))
                    appErrorToast.show(message: error.localizedDescription, view: strongSelf.baseView)
                })
            }
        })
    }
}

func prettyJSON(_ data: [String: Any]) {
    if let jsonData = try? JSONSerialization.data(withJSONObject: data), let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
       print(JSONString)
    }
}
