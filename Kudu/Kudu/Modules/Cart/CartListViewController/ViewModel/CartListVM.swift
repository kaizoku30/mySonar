//
//  CartListVM.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import Foundation

class CartListVM {
    
    private var store: StoreDetail?
    private var cartConfig: CartConfig?
    private var serviceType: APIEndPoints.ServicesType = .delivery
    private var youMayAlsoLikeObjects: [YouMayAlsoLikeObject] = []
    private var objects: [CartListObject] = []
    private var attachedCoupon: CouponObject?
    private var fetchingCartConfig: Bool = false
    private var deliveryLocation: LocationInfoModel?
    var getCartObjects: [CartListObject] { objects }
    var getYouMayAlsoLikeList: [YouMayAlsoLikeObject] { youMayAlsoLikeObjects }
    var getStoreDetails: StoreDetail? { store }
    var getServiceType: APIEndPoints.ServicesType { serviceType }
    var isFetchingCartConfig: Bool { fetchingCartConfig }
    var getCartConfig: CartConfig? { cartConfig }
    var getDeliveryLocation: LocationInfoModel? { deliveryLocation }
    var getCoupon: CouponObject? { attachedCoupon }
    
    init() {
        objects = CartUtility.fetchCart()
        serviceType = APIEndPoints.ServicesType(rawValue: objects.first?.servicesAvailable ?? "") ?? .delivery
        switch serviceType {
        case .curbside:
            let curbsideStore = DataManager.shared.currentCurbsideRestaurant
            if curbsideStore.isNotNil {
                store = curbsideStore?.convertToStoreDetail()
            }
        case .delivery:
            store = DataManager.shared.currentDeliveryLocation?.associatedStore
            deliveryLocation = DataManager.shared.currentDeliveryLocation
        case .pickup:
            let pickUpStore = DataManager.shared.currentPickupRestaurant
            if pickUpStore.isNotNil {
                store = pickUpStore?.convertToStoreDetail()
            }
        }
        if store.isNotNil {
            fetchingCartConfig = true
        }
    }
    
    func allowPayment() -> Bool {
        
        let items = objects
        if items.contains(where: { $0.itemDetails?.isAvailable ?? false == false && $0.offerdItem ?? false == false }) {
            //Out of stock check
            return false
        }
        if serviceType == .curbside {
            if cartConfig?.vehicleDetails.isNil ?? false {
                return false
            }
        }
        if let coupon = self.attachedCoupon {
            var canPay = true
            let couponError = CartUtility.checkCouponValidationError(coupon)
            if couponError.isNotNil {
                canPay = false
                return canPay
            }
            if getStoreDetails.isNil {
                canPay = false
                return canPay
            }
            return canPay
        } else {
            return getStoreDetails.isNotNil
        }
    }
    
    func cartSynced() {
        objects = CartUtility.fetchCart()
        attachedCoupon = CartUtility.getAttachedCoupon
    }
    
    func checkIfFreeItemAdd() -> Bool {
        if self.attachedCoupon.isNil { return false }
        let coupon = self.attachedCoupon!
        if CartUtility.checkCouponValidationError(coupon).isNotNil { return false }
        let promo = coupon.promoData
        let promoType = PromoOfferType(rawValue: promo?.offerType ?? "")
        if promoType.isNotNil {
            if promoType != .item { return false }
            if promoType == .item, let items = promo?.items, !items.isEmpty {
                if objects.contains(where: { $0.offerdItem ?? false == true }) {
                    return false
                } else {
                    return true
                }
            } else { return false }
        } else {
            return false
        }
    }
    
    func updateDeliveryLocation(_ loc: LocationInfoModel) {
        deliveryLocation = loc
    }
    
    func clearDeliveryLocation() {
        deliveryLocation = nil
        store = nil
    }
    
    func updateStore(_ store: StoreDetail) {
        self.store = store
    }
    
    func calculateBill() -> BillDetails {
        var bill = BillDetails()
        let priceBasedOnCart = CartUtility.getPrice()
        bill.totalPayable = priceBasedOnCart
        if self.serviceType == .delivery, let deliveryCharge = cartConfig?.deliveryCharges {
            bill.deliveryCharge = deliveryCharge
            bill.totalPayable += deliveryCharge
            bill.totalPayable = bill.totalPayable.round(to: 2)
        }
        let vat = (cartConfig?.vat ?? 0.0)
        bill.vatPercent = vat.removeZerosFromEnd()
        bill.itemTotal = priceBasedOnCart
        return bill
    }
    
    func updateFetchingCartConfig() {
        self.fetchingCartConfig = true
    }
    
    func fetchCartConfig(fetched: @escaping (() -> Void)) {
        debugPrint(store?._id ?? "")
        CartUtility.getCartConfig(storeId: store?._id, fetched: { [weak self] in
            self?.fetchingCartConfig = false
            self?.cartConfig = $0
            fetched()
        })
    }
    
    func checkIfNoStoreExists(lat: Double, long: Double, checked: @escaping ((Bool) -> Void)) {
        APIEndPoints.HomeEndPoints.getStoreDetailsForDelivery(lat: lat, long: long, servicesType: self.serviceType, success: { _ in
            checked(true)
        }, failure: { (error) in
            if error.code == 422 {
                checked(false)
            } else {
                checked(true)
            }
        })
    }
    
    func fetchYouMayAlsoLike(done: @escaping (() -> Void)) {
        CartUtility.youMayAlsoLikeList(result: { [weak self] (result) in
            if let strongSelf = self {
                switch result {
                case .success(let list):
                    strongSelf.youMayAlsoLikeObjects = list
                    done()
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    done()
                }
            }
        })
    }
    
    func updateExpandedDetailsState(_ state: Bool, index: Int) {
        if index < objects.count {
            objects[index].expandProductDetails = state
        }
    }
    
    func updateLikeStatus(status: Bool, index: Int) {
        guard let object = objects[safe: index], let itemId = object.itemDetails?._id, let hashId = object.hashId else { return }
        if status {
            DataManager.saveHashIDtoFavourites(hashId)
        } else {
            DataManager.removeHashIdFromFavourites(hashId)
        }
        NotificationCenter.postNotificationForObservers(.favouriteStateUpdatedFromCart)
        //updateExploreMenuFavourite?(object.menuId ?? "", object.itemId ?? "")
        let request = FavouriteRequest(itemId: itemId, hashId: hashId, menuId: object.menuId ?? "", itemSdmId: object.itemSdmId ?? 0, isFavourite: status, servicesAvailable: self.serviceType, modGroups: object.modGroups)
        APIEndPoints.HomeEndPoints.hitFavouriteAPI(request: request, success: { (response) in
            debugPrint(response.message ?? "")
        }, failure: { _ in
            //Need to revisit implementation, provide a like delegate method
        })
    }
    
    func updateCountLocally(count: Int, index: Int, completionHandler: (() -> Void)? = nil) {
        guard let object = objects[safe: index] else { return }
        let previousQuantity = object.quantity ?? 0
        let newCount = count
        if newCount > previousQuantity {
            if newCount == 1 {
                // Case should never happen
                debugPrint("INVALID STATE")
            } else {
                let cartNotification = CartCountNotifier(isIncrement: true, itemId: object.itemId ?? "", menuId: object.menuId ?? "", hashId: object.hashId ?? "", serviceType: self.serviceType, modGroups: object.modGroups)
                NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
                //                updateExploreMenuCellCount?(object.menuId ?? "", object.itemId ?? "", object.hashId ?? "", true, object.modGroups ?? [])
                objects[index].quantity = newCount
                updateCartCount(object: object, isIncrement: true, completionHandler: completionHandler)
            }
        } else {
            if newCount == 0 {
                // updateExploreMenuCellCount?(object.menuId ?? "", object.itemId ?? "", object.hashId ?? "", false, object.modGroups ?? [])
                let cartNotification = CartCountNotifier(isIncrement: false, itemId: object.itemId ?? "", menuId: object.menuId ?? "", hashId: object.hashId ?? "", serviceType: self.serviceType, modGroups: object.modGroups)
                NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
                objects.remove(at: index)
                removeItemFromCart(object: object, completionHandler: completionHandler)
            } else {
                let cartNotification = CartCountNotifier(isIncrement: false, itemId: object.itemId ?? "", menuId: object.menuId ?? "", hashId: object.hashId ?? "", serviceType: self.serviceType, modGroups: object.modGroups)
                NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
                //    updateExploreMenuCellCount?(object.menuId ?? "", object.itemId ?? "", object.hashId ?? "", false, object.modGroups ?? [])
                objects[index].quantity = newCount
                updateCartCount(object: object, isIncrement: false, completionHandler: completionHandler)
            }
        }
    }
    
    func addToCart(req: AddCartItemRequest, itemDetails: MenuItem, added: @escaping (() -> Void), updated: @escaping (() -> Void)) {
        if let firstIndex = objects.firstIndex(where: { $0.hashId ?? "" == req.hashId }), req.offerdItem == false {
            let previousCount = objects[firstIndex].quantity ?? 0
            objects[firstIndex].quantity = previousCount + 1
            // updateExploreMenuCellCount?(objects[firstIndex].menuId ?? "", objects[firstIndex].itemId ?? "", objects[firstIndex].hashId ?? "", true, objects[firstIndex].modGroups ?? [])
            let object = objects[firstIndex]
            let cartNotification = CartCountNotifier(isIncrement: true, itemId: object.itemId ?? "", menuId: object.menuId ?? "", hashId: object.hashId ?? "", serviceType: self.serviceType, modGroups: object.modGroups)
            NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
            updateCartCount(object: objects[firstIndex], isIncrement: true, completionHandler: {
                updated()
            })
            return
        }
        let placeholder = req.createPlaceholderCartObject(itemDetails: itemDetails)
        CartUtility.addItemToCart(placeholder)
        // updateExploreMenuCellCount?(placeholder.menuId ?? "", placeholder.itemId ?? "", placeholder.hashId ?? "", true, placeholder.modGroups ?? [])
        let object = placeholder
        if req.offerdItem == false {
            let cartNotification = CartCountNotifier(isIncrement: true, itemId: object.itemId ?? "", menuId: object.menuId ?? "", hashId: object.hashId ?? "", serviceType: self.serviceType, modGroups: object.modGroups)
            NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
        }
        self.objects.append(placeholder)
        APIEndPoints.CartEndPoints.addItemToCart(req: req, success: { [weak self] in
            guard let strongSelf = self, let cartObject = $0.data else { return }
            var copy = cartObject
            copy.itemDetails = itemDetails
            if let index = strongSelf.objects.firstIndex(where: { $0.hashId ?? "" == cartObject.hashId ?? ""}) {
                strongSelf.objects[index] = copy
            }
            CartUtility.mapObjectWithPlaceholder(copy)
            added()
        }, failure: { (error) in
            debugPrint(error.msg)
            added()
        })
    }
}

extension CartListVM {
    
    private func updateCartCount(object: CartListObject, isIncrement: Bool, completionHandler: (() -> Void)? = nil) {
        let updateCartReq = UpdateCartCountRequest(isIncrement: isIncrement, itemId: object.itemDetails?._id ?? "", quantity: 1, hashId: object.hashId ?? "")
        CartUtility.updateCartCount(object.hashId ?? "", isIncrement: isIncrement)
        APIEndPoints.CartEndPoints.incrementDecrementCartCount(req: updateCartReq, success: { (response) in
            debugPrint(response)
            completionHandler?()
        }, failure: { (error) in
            CartUtility.updateCartCount(object.hashId ?? "", isIncrement: !isIncrement)
            debugPrint(error.msg)
            completionHandler?()
        })
    }
    
    private func removeItemFromCart(object: CartListObject, completionHandler: (() -> Void)? = nil) {
        CartUtility.removeItemFromCart(object.hashId ?? "")
        let removeCartReq = RemoveItemFromCartRequest(itemId: object.itemDetails?._id ?? "", hashId: object.hashId ?? "")
        APIEndPoints.CartEndPoints.removeItemFromCart(req: removeCartReq, success: { (response) in
            debugPrint(response)
            completionHandler?()
        }, failure: { (error) in
            debugPrint(error.msg)
            completionHandler?()
        })
    }
    
    func fetchItemDetail(itemId: String, completion: @escaping (Result<MenuItem, Error>) -> Void) {
        APIEndPoints.HomeEndPoints.getItemDetail(itemId: itemId, success: { (response) in
            guard let itemDetail = response.data?.first else { return }
            completion(.success(itemDetail))
        }, failure: {
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            completion(.failure(error))
        })
    }
    
    func removeCartObject(atIndex index: Int) {
        if index < self.objects.count {
            self.objects.remove(at: index)
        }
    }
}
