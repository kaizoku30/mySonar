//
//  CartUtility.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import Foundation

final class CartUtility {
    
	private static let shared = CartUtility()
    private let concurrentQueue = DispatchQueue(label: "cartConcurrentQueue", attributes: .concurrent)
	private var cart: [CartListObject] = []
    private var cartCurrentStoreId: String?
    private var currentCartConfig: CartConfig?
    private var attachedCoupon: CouponObject?
	private var cancellationPolicy: String = ""
    private var appLaunched = true
    private var comingFromMyOffers = false
    
    static func setComingFromMyOffers() {
        CartUtility.shared.comingFromMyOffers = true
    }
    
    static func unSetComingFromMyOffers() {
        CartUtility.shared.comingFromMyOffers = false
    }
    
    static var getCancellationPolicy: String {
        CartUtility.shared.cancellationPolicy
    }
    static var getAttachedCoupon: CouponObject? {
        CartUtility.shared.attachedCoupon
    }
    static var getCartStoreID: String? {
        CartUtility.shared.cartCurrentStoreId
    }
    static var getCurrentConfig: CartConfig? {
        CartUtility.shared.currentCartConfig
    }
    
    static var getCartServiceType: APIEndPoints.ServicesType {
        let service = APIEndPoints.ServicesType(rawValue: CartUtility.shared.cart.first?.servicesAvailable ?? "") ?? .delivery
        return service
    }
    
    private init () {
        //CartUtility.syncCart { }
    }
    
    static func logStart() {
        _ = CartUtility.shared.cart.count
        debugPrint("CART DEBUGGER LOG : //////////// STARTED")
        CartDebugger.log(.cartInitialised(cartCount: CartUtility.getItemCount()))
    }
}

extension CartUtility {
    static func syncCancellationPolicy() {
        if DataManager.shared.isUserLoggedIn == false { return }
        APIEndPoints.CartEndPoints.syncCancellationPolicy(success: {
            let htmlString = $0.data?.description ?? ""
            CartUtility.shared.cancellationPolicy = htmlString.html2String
        }, failure: { _ in
            //Need to see if any need of implementation here
        })
    }
    
    static func getPrice() -> Double {
        let cartList = CartUtility.shared.cart
        var priceBasedOnList: Double = 0
        cartList.forEach({
            
            if $0.offerdItem ?? false { return }
            
            let basePrice = $0.itemDetails?.price ?? 0.0
            var modBasedPrice: Double = 0
            $0.modGroups?.forEach({ (modGroup) in
                modGroup.modifiers?.forEach({ (modifier) in
                    var modifierCount = modifier.count ?? 1
                    if modifierCount == 0 { modifierCount = 1 }
                    modBasedPrice += ((modifier.price ?? 0.0)*Double((modifierCount)))
                })
            })
            let computedPrice = basePrice + modBasedPrice
            let quantityBasedPrice = computedPrice * Double(($0.quantity ?? 0))
            priceBasedOnList += quantityBasedPrice
        })
        return priceBasedOnList
    }
    
    static func getPriceForAnItem(_ item: CartListObject) -> Double {
        let basePrice = item.itemDetails?.price ?? 0.0
        var modBasedPrice: Double = 0
        item.modGroups?.forEach({ (modGroup) in
            modGroup.modifiers?.forEach({ (modifier) in
                modBasedPrice += modifier.price ?? 0.0
            })
        })
        let computedPrice = basePrice + modBasedPrice
        let quantityBasedPrice = computedPrice * Double((item.quantity ?? 0))
        return quantityBasedPrice
    }
    
    static func getItemCount() -> Int {
        let cartList = CartUtility.shared.cart
        var numberOfItems: Int = 0
        cartList.forEach({
            if $0.offerdItem ?? false { return }
            numberOfItems += $0.quantity ?? 0
        })
        return numberOfItems
    }
    
    static func youMayAlsoLikeList(result: @escaping (Result<[YouMayAlsoLikeObject], Error>) -> Void) {
        APIEndPoints.CartEndPoints.getYouMayAlsoLikeList(servicesType: CartUtility.getCartServiceType, success: { response in
            result(.success(response.data ?? []))
        }, failure: {
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            result(.failure(error))
        })
    }
}

extension CartUtility {
    
	static func syncCart(completion: @escaping (() -> Void)) {
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            APIEndPoints.CartEndPoints.syncCart(storeId: CartUtility.getCartStoreID, success: { (response) in
                
                CartUtility.shared.cart = []
                CartUtility.shared.attachedCoupon = nil
                var incomingArray = response.data?.data ?? []
                var itemsToRemove: [String] = []
                for index in incomingArray.indices {
                    let item = incomingArray[index]
                    if item.quantity ?? 0 == 0 {
                        itemsToRemove.append(item._id ?? "")
                    }
                }
                CartUtility.removeMultipleItemsRemotely(incomingArray: incomingArray, array: itemsToRemove, completion: { _ in
                    incomingArray = incomingArray.filter({ $0.quantity ?? 0 > 0 })
                    let incomingCoupon = response.data?.couponData
                    CartUtility.shared.cart = incomingArray
                    
                    if CartUtility.shared.appLaunched {
                        CartUtility.unSetComingFromMyOffers()
                    }
                    
                    if (incomingArray.isEmpty || CartUtility.shared.appLaunched == true), let incomingCouponID = incomingCoupon?._id, !CartUtility.shared.comingFromMyOffers {
                        CartUtility.shared.appLaunched = false
                        CartUtility.shared.attachedCoupon = nil
                        CartUtility.removeCouponAndFreeItemsRemotely(couponId: incomingCouponID, cartArray: incomingArray, completion: completion)
                        return
                    }
                    CartUtility.shared.appLaunched = false
                    if let couponId = response.data?.couponData?._id, !couponId.isEmpty {
                        let couponData = response.data?.couponData
                        CartUtility.shared.attachedCoupon = couponData
                    }
                    CartDebugger.log(.cartSyncedWithServer(updatedCount: CartUtility.getItemCount()))
                    CartUtility.syncCancellationPolicy()
                    completion()
                })
            }, failure: { _ in
                completion()
            })}
	}
    
    static func removeMultipleItemsRemotely(incomingArray: [CartListObject], array: [String], completion: (([CartListObject]) -> Void)?) {
        var incomingArrayToUpdate: [CartListObject] = incomingArray
        var indexArrayToEmpty: [String] = array
        if array.isEmpty {
            completion?(incomingArrayToUpdate)
            return
        }
        for id in array {
            guard let index = incomingArrayToUpdate.firstIndex(where: { $0._id ?? "" == id }) else {
                completion?(incomingArrayToUpdate)
                return
            }
            CartUtility.removeItemFromCartRemotely(menuItem: incomingArray[index].itemDetails!, hashId: incomingArray[index].hashId!, completion: {
                    switch $0 {
                    case .success:
                        incomingArrayToUpdate.remove(at: index)
                        indexArrayToEmpty.remove(object: id)
                        if indexArrayToEmpty.isEmpty {
                            completion?(incomingArrayToUpdate)
                        }
                    case .failure:
                        completion?(incomingArrayToUpdate)
                        return
                    }
            })
        }
    }
    
    static func getCartConfig(storeId: String?, fetched: @escaping ((CartConfig?) -> Void)) {
        debugPrint("FETCHING CART CONFIG")
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            CartUtility.shared.cartCurrentStoreId = storeId
        }
        APIEndPoints.CartEndPoints.getCartConfig(storeId: storeId, success: {
            fetched($0.data)
            CartUtility.shared.currentCartConfig = $0.data
            if let storeDetails = $0.data?.storeDetails {
                switch CartUtility.getCartServiceType {
                case .curbside:
                    DataManager.shared.currentCurbsideRestaurant = storeDetails.convertToRestaurantInfo()
                case .pickup:
                    DataManager.shared.currentPickupRestaurant = storeDetails.convertToRestaurantInfo()
                default:
                    DataManager.shared.currentDeliveryLocation?.associatedStore = storeDetails
                }
            }
        }, failure: { _ in
            fetched(nil)
        })
    }
}

extension CartUtility {
    // MARK: Local Operations
    
    static func clearLocalData() {
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            CartUtility.shared.cart = []
            CartUtility.shared.attachedCoupon = nil
        }
    }
    
    static private func removeFreeItemFromCartLocally(removed: @escaping (() -> Void)) {
        let cart = CartUtility.fetchCartLocally()
        guard let freeItem = cart.first(where: { $0.offerdItem ?? false == true }) else {
            removed()
            return
        }
        CartUtility.removeItemFromCartLocally(freeItem.hashId ?? "")
    }
    
    static func addItemToCartLocally(_ object: CartListObject) {
        let timeForNotif = DataManager.shared.currentCartConfig?.notificationWaitTime ?? 0
        NotificationScheduler.scheduleNotification(type: .idleCartReminder, timeInterval: Double(timeForNotif * 60))
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            CartUtility.shared.cart.append(object)
            CartDebugger.log(.itemAddedToCart(onServer: false, itemName: object.itemDetails?.nameEnglish ?? "", hashId: object.hashId ?? ""))
        }
    }
    
    static func removeItemFromCartLocally(_ hashId: String, offeredItem: Bool = false) {
        let timeForNotif = DataManager.shared.currentCartConfig?.notificationWaitTime ?? 0
        NotificationScheduler.scheduleNotification(type: .idleCartReminder, timeInterval: Double(timeForNotif * 60))
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            if offeredItem, let offerdItemIndex = CartUtility.shared.cart.firstIndex(where: { $0.offerdItem ?? false == true }) {
                let objectToRemove = CartUtility.shared.cart[offerdItemIndex]
                CartUtility.shared.cart.remove(at: offerdItemIndex)
                if CartUtility.shared.cart.isEmpty { NotificationScheduler.removeScheduledNotification(type: .idleCartReminder) }
                CartDebugger.log(.itemRemovedFromCart(onServer: false, itemName: objectToRemove.itemDetails?.nameEnglish ?? "", hashId: objectToRemove.hashId ?? ""))
                return
            }
            guard let firstIndex = CartUtility.shared.cart.firstIndex(where: { $0.hashId ?? "" == hashId }) else { return }
            let objectToRemove = CartUtility.shared.cart[firstIndex]
            CartUtility.shared.cart.remove(at: firstIndex)
            if CartUtility.shared.cart.isEmpty { NotificationScheduler.removeScheduledNotification(type: .idleCartReminder) }
            CartDebugger.log(.itemRemovedFromCart(onServer: false, itemName: objectToRemove.itemDetails?.nameEnglish ?? "", hashId: objectToRemove.hashId ?? ""))
        }
    }
    
    static func updateCartCountLocally(_ hashId: String, isIncrement: Bool) {
        let timeForNotif = DataManager.shared.currentCartConfig?.notificationWaitTime ?? 0
        NotificationScheduler.scheduleNotification(type: .idleCartReminder, timeInterval: Double(timeForNotif * 60))
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            guard let firstIndex = CartUtility.shared.cart.firstIndex(where: { $0.hashId ?? "" == hashId }) else { return }
            let oldArray = CartUtility.shared.cart
            CartUtility.shared.cart[firstIndex].quantity = (oldArray[firstIndex].quantity ?? 0) + (isIncrement ? 1 : -1)
            let updatedObject = CartUtility.shared.cart[firstIndex]
            CartDebugger.log(.itemUpdatedInCart(onServer: false, itemName: updatedObject.itemDetails?.nameEnglish ?? "", hashId: updatedObject.hashId ?? "", updatedCount: updatedObject.quantity ?? 0))
        }
    }
    
    static func fetchCartLocally() -> [CartListObject] {
        return CartUtility.shared.cart
    }
}

extension CartUtility {
    // MARK: Remote Operations
    
    static func clearCartRemotely(clearedConfirmed: (() -> Void)? = nil) {
        CartUtility.unSetComingFromMyOffers()
        CartUtility.shared.appLaunched = false
        CartUtility.shared.attachedCoupon = nil
        if let incomingCouponID = CartUtility.getAttachedCoupon?._id, !incomingCouponID.isEmpty {
            CartUtility.removeCouponAndFreeItemsRemotely(couponId: incomingCouponID, cartArray: CartUtility.fetchCartLocally(), completion: {
                CartUtility.executeClearCartRemotely(clearedConfirmed: clearedConfirmed)
            })
        } else {
            CartUtility.executeClearCartRemotely(clearedConfirmed: clearedConfirmed)
        }
    }
        
    static private func executeClearCartRemotely(clearedConfirmed: (() -> Void)? = nil) {
            NotificationScheduler.removeScheduledNotification(type: .idleCartReminder)
            CartUtility.shared.concurrentQueue.async(flags: .barrier) {
                if let someCouponExists = CartUtility.shared.attachedCoupon {
                    CartUtility.shared.attachedCoupon = nil
                    APIEndPoints.CouponEndPoints.updateCouponOnCart(apply: false, couponId: someCouponExists._id ?? "", success: { _ in
                        CartUtility.shared.cart = []
                        APIEndPoints.CartEndPoints.clearCart(success: { _ in
                            NotificationCenter.postNotificationForObservers(.syncCartBanner)
                            clearedConfirmed?()
                        }, failure: { _ in
                             clearedConfirmed?()
                        })
                    }, failure: { _ in
                        CartUtility.shared.cart = []
                        clearedConfirmed?()
                    })
                } else {
                    CartUtility.shared.cart = []
                    APIEndPoints.CartEndPoints.clearCart(success: { _ in
                        NotificationCenter.postNotificationForObservers(.syncCartBanner)
                        clearedConfirmed?()
                    }, failure: { _ in
                        clearedConfirmed?()
                    })
                }
        }
    }
    
    static func addItemToCartRemotely(addToCartReq: AddCartItemRequest, menuItem: MenuItem, completion: ((Result<Bool, Error>) -> Void)? = nil) {
        
        APIEndPoints.CartEndPoints.addItemToCart(req: addToCartReq, success: { (response) in
            guard let cartItem = response.data else { return }
            debugPrint(response)
            var copy = cartItem
            copy.itemDetails = menuItem
            CartUtility.addItemToCartLocally(copy)
            NotificationCenter.postNotificationForObservers(.syncCartBanner)
            completion?(.success(true))
        }, failure: { (error) in
            debugPrint(error.msg)
            completion?(.failure(NSError(localizedDescription: error.msg)))
        })
    }
    
    static func updateCartCountRemotely(menuItem: MenuItem, hashId: String, isIncrement: Bool, quantity: Int, completion: ((Result<Bool, Error>) -> Void)? = nil) {
        guard let itemId = menuItem._id else { return }
        let updateCartReq = UpdateCartCountRequest(isIncrement: isIncrement, itemId: itemId, quantity: 1, hashId: hashId)
        APIEndPoints.CartEndPoints.incrementDecrementCartCount(req: updateCartReq, success: { (response) in
            CartUtility.updateCartCountLocally(hashId, isIncrement: isIncrement)
            debugPrint(response)
            NotificationCenter.postNotificationForObservers(.syncCartBanner)
            completion?(.success(true))
        }, failure: { (error) in
            debugPrint(error.msg)
            completion?(.failure(NSError(localizedDescription: error.msg)))
        })
    }
    
    static func removeItemFromCartRemotely(menuItem: MenuItem, hashId: String, completion: ((Result<Bool, Error>) -> Void)? = nil) {
        guard let itemId = menuItem._id else { return }
        let removeCartReq = RemoveItemFromCartRequest(itemId: itemId, hashId: hashId)
        APIEndPoints.CartEndPoints.removeItemFromCart(req: removeCartReq, success: { (response) in
            debugPrint(response)
            CartUtility.removeItemFromCartLocally(hashId)
            NotificationCenter.postNotificationForObservers(.syncCartBanner)
            completion?(.success(true))
        }, failure: { (error) in
            debugPrint(error.msg)
            completion?(.failure(NSError(localizedDescription: error.msg)))
        })
    }
}

extension CartUtility {
    // MARK: Coupon Validation
    static func checkCouponValidationError(_ obj: CouponObject) -> CouponValidationFailedReason? {
        let cartType = CartUtility.getCartServiceType
        let excludedStoreIDs = obj.excludeLocations ?? []
        let currentStoreId = CartUtility.getCartStoreID
        if let storeIdExists = currentStoreId, excludedStoreIDs.contains(where: { $0 == storeIdExists}) {
            return .storeIdConflict(delivery: cartType == .delivery)
        }
        
        let couponFromDate = Date(timeIntervalSince1970: Double(obj.validFrom ?? 0)/1000)
        let couponToDate = Date(timeIntervalSince1970: Double(obj.validTo ?? 0)/1000)
        let currentDate = Date()
        if currentDate < couponFromDate || currentDate > couponToDate {
            return .timeBounds
        }
        
        let isTwentyFourSeven = obj.promoData?.twenty4By7 ?? false
        
        let couponFromTime = obj.validFromTime ?? 0
        let couponToTime = obj.validToTime ?? 0
        let currentTime = Date().totalMinutes
        
        if !isTwentyFourSeven {
            var couponValidToday = false
            let applicableDays = obj.promoData?.eachDayTime ?? []
            applicableDays.forEach({ (dayObj) in
                guard let correspondingWeekday = TimeRange.WeekDay(rawValue: dayObj.dayName ?? "") else { return }
                if correspondingWeekday.checkIfToday() {
                    let fromTimeWeekday = dayObj.validFromTime ?? 0
                    let toTimeWeekday = dayObj.validToTime ?? 0
                    var interSectionStart: Int = fromTimeWeekday
                    if couponFromTime > fromTimeWeekday {
                        interSectionStart = couponFromTime
                    }
                    var interSectionEnd: Int = toTimeWeekday
                    if couponToTime < interSectionEnd {
                        interSectionEnd = couponToTime
                    }
                    if currentTime >= interSectionStart && currentTime <= interSectionEnd {
                        couponValidToday = true
                        return
                    }
                }
            })
            if !couponValidToday {
                return .timeBounds
            }
        }
        
        if currentTime < couponFromTime {
            return .timeBounds
        }
        if currentTime > couponToTime {
            return .timeBounds
        }
        
        if let couponServiceType = APIEndPoints.ServicesType(rawValue: obj.promoData?.servicesAvailable ?? ""), cartType != couponServiceType {
            return .serviceTypeMismatch(correctOrderType: couponServiceType)
        }
        let couponCartAmount = obj.promoData?.minimumCartAmount ?? 0
        let cartAmount = CartUtility.getPrice()
        if Int(cartAmount) < couponCartAmount {
            return .amountNotEnough(amountReq: couponCartAmount)
        }
        var menuIdExists = false
        var currentCart = CartUtility.fetchCartLocally()
        currentCart = currentCart.filter({ $0.offerdItem ?? false == false })
        let currentMenuIDs: [String] = currentCart.map({ $0.menuId ?? "" })
        let requiredMenuIDs: [String] = obj.promoData?.cartMustCategories ?? []
        if requiredMenuIDs.isEmpty == false {
            currentMenuIDs.forEach({ (menuId) in
                if requiredMenuIDs.contains(where: { $0 == menuId }) {
                    menuIdExists = true
                }
            })
            if menuIdExists {
                return nil
            }
        }
        var itemIdExists = false
        let currentItemIDs: [String] = currentCart.map({ $0.itemId ?? "" })
        let requiredItemIDs: [String] = obj.promoData?.cartMustItems ?? []
        if requiredItemIDs.isEmpty == false {
            currentItemIDs.forEach({ (itemId) in
                if requiredItemIDs.contains(where: { $0 == itemId }) {
                    itemIdExists = true
                }
            })
            if itemIdExists {
                return nil
            }
        }
        if itemIdExists == false && menuIdExists == false {
            return .itemIDsNeeded
        }
        return nil
    }
    
    static private func fetchPromoData(couponId: String, fetched: @escaping ((PromoData?) -> Void)) {
        APIEndPoints.CouponEndPoints.getCouponDetail(id: couponId, success: {
            guard let promoData = $0.data?.first?.promoData else {
                fetched(nil)
                return
            }
            fetched(promoData)
        }, failure: { _ in
            fetched(nil)
        })
    }
}

extension CartUtility {
    // MARK: Handling Coupon Application
    
    static func applyCouponToCart(_ object: CouponObject, completionHandler: @escaping ((Bool) -> Void)) {
        APIEndPoints.CouponEndPoints.updateCouponOnCart(apply: true, couponId: object._id ?? "", success: { _ in
            CartUtility.addCouponToCartLocally(coupon: object)
            completionHandler(true)
        }, failure: { _ in
            completionHandler(false)
        })
    }
    
    static func addCouponToCartLocally(coupon: CouponObject) {
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            CartUtility.shared.attachedCoupon = coupon
        }
    }
    
    static func calculateSavingsAfterCoupon(obj: CouponObject) -> Double {
        let type = PromoOfferType(rawValue: obj.promoData?.offerType ?? "")!
        switch type {
        case .discount:
            let currentAmount = (CartUtility.getPrice())
            let discountType = DeliveryDiscountType(rawValue: obj.promoData?.discountType ?? "")!
            if discountType == .fixedDiscount {
                let fixedDiscount = obj.promoData?.discountedAmount ?? 0
                if currentAmount > Double(fixedDiscount) {
                    return Double(fixedDiscount)
                } else {
                    return Double(currentAmount)
                }
            } else {
                let discountPercentage = obj.promoData?.discountInPercentage ?? 0
                let fraction = Double(discountPercentage)/100
                var discount = currentAmount*fraction
                let maxAmount = obj.promoData?.maximumDiscount ?? 0
                if Int(discount) > maxAmount {
                    discount = Double(maxAmount)
                }
                return discount
            }
        case .item:
            return 0
        case .freeDelivery:
            let deliveryCharge = CartUtility.getCurrentConfig?.deliveryCharges ?? 0.0
            return Double((deliveryCharge))
        case .discountedDelivery:
            let percentage = Double(obj.promoData?.specialDeliveryPrice ?? 0)
            let deliveryCharge = CartUtility.getCurrentConfig?.deliveryCharges ?? 0.0
            let fraction = percentage/100
            let discount = fraction*deliveryCharge
            return discount
        }
    }
}

extension CartUtility {
    // MARK: Handling Coupon Removal
    
    static func removeCouponAndFreeItemsRemotely(couponId: String, cartArray: [CartListObject], completion: @escaping () -> Void) {
        CartUtility.shared.appLaunched = false
        APIEndPoints.CouponEndPoints.updateCouponOnCart(apply: false, couponId: couponId, success: { _ in
            CartUtility.shared.attachedCoupon = nil
            guard let freeItemExists = cartArray.first(where: { $0.offerdItem ?? false == true }) else {
                CartUtility.shared.cart = cartArray
                CartDebugger.log(.cartSyncedWithServer(updatedCount: CartUtility.getItemCount()))
                completion()
                return
            }
            APIEndPoints.CartEndPoints.removeItemFromCart(req: RemoveItemFromCartRequest(itemId: freeItemExists.itemId ?? "", hashId: freeItemExists.hashId ?? "", offeredItem: true), success: { _ in
                CartUtility.removeItemFromCartLocally("", offeredItem: true)
                completion()
            }, failure: { _ in
                completion()
            })
            
        }, failure: { _ in
            CartUtility.shared.cart = cartArray
            CartDebugger.log(.cartSyncedWithServer(updatedCount: CartUtility.getItemCount()))
            CartUtility.syncCancellationPolicy()
            completion()
        })
    }
}
