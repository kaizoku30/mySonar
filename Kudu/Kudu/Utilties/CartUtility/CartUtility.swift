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
        let decoded = DataManager.decodeAndFetch([CartListObject].self, key: .cart) ?? []
        cart = decoded
    }
    
    static func logStart() {
        _ = CartUtility.shared.cart.count
        debugPrint("CART DEBUGGER LOG : //////////// STARTED")
        CartDebugger.log(.cartInitialised(cartCount: CartUtility.getItemCount()))
    }
	
	static func addItemToCart(_ object: CartListObject) {
        let timeForNotif = DataManager.shared.currentCartConfig?.notificationWaitTime ?? 0
        NotificationScheduler.scheduleNotification(type: .idleCartReminder, timeInterval: Double(timeForNotif * 60))
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            CartUtility.shared.cart.append(object)
            DataManager.encodeAndSaveObject(CartUtility.shared.cart, key: .cart)
            CartDebugger.log(.itemAddedToCart(onServer: false, itemName: object.itemDetails?.nameEnglish ?? "", hashId: object.hashId ?? ""))
        }
	}
	
    static func removeItemFromCart(_ hashId: String, offeredItem: Bool = false) {
        let timeForNotif = DataManager.shared.currentCartConfig?.notificationWaitTime ?? 0
        NotificationScheduler.scheduleNotification(type: .idleCartReminder, timeInterval: Double(timeForNotif * 60))
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            if offeredItem, let offerdItemIndex = CartUtility.shared.cart.firstIndex(where: { $0.offerdItem ?? false == true }) {
                let objectToRemove = CartUtility.shared.cart[offerdItemIndex]
                CartUtility.shared.cart.remove(at: offerdItemIndex)
                if CartUtility.shared.cart.isEmpty { NotificationScheduler.removeScheduledNotification(type: .idleCartReminder) }
                DataManager.encodeAndSaveObject(CartUtility.shared.cart, key: .cart)
                CartDebugger.log(.itemRemovedFromCart(onServer: false, itemName: objectToRemove.itemDetails?.nameEnglish ?? "", hashId: objectToRemove.hashId ?? ""))
                return
            }
            guard let firstIndex = CartUtility.shared.cart.firstIndex(where: { $0.hashId ?? "" == hashId }) else { return }
            let objectToRemove = CartUtility.shared.cart[firstIndex]
            CartUtility.shared.cart.remove(at: firstIndex)
            if CartUtility.shared.cart.isEmpty { NotificationScheduler.removeScheduledNotification(type: .idleCartReminder) }
            DataManager.encodeAndSaveObject(CartUtility.shared.cart, key: .cart)
            CartDebugger.log(.itemRemovedFromCart(onServer: false, itemName: objectToRemove.itemDetails?.nameEnglish ?? "", hashId: objectToRemove.hashId ?? ""))
        }
	}
    
    static func mapObjectWithPlaceholder(_ object: CartListObject) {
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            guard let firstIndex = CartUtility.shared.cart.firstIndex(where: { $0.hashId ?? "" == object.hashId ?? "" }) else { return }
            CartUtility.shared.cart[firstIndex] = object
            DataManager.encodeAndSaveObject(CartUtility.shared.cart, key: .cart)
            CartDebugger.log(.itemMappedWithPlaceholder(itemName: object.itemDetails?.nameEnglish ?? "", hashId: object.hashId ?? ""))
        }
    }
	
	static func updateCartCount(_ hashId: String, isIncrement: Bool) {
        let timeForNotif = DataManager.shared.currentCartConfig?.notificationWaitTime ?? 0
        NotificationScheduler.scheduleNotification(type: .idleCartReminder, timeInterval: Double(timeForNotif * 60))
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            guard let firstIndex = CartUtility.shared.cart.firstIndex(where: { $0.hashId ?? "" == hashId }) else { return }
            let oldArray = CartUtility.shared.cart
            CartUtility.shared.cart[firstIndex].quantity = (oldArray[firstIndex].quantity ?? 0) + (isIncrement ? 1 : -1)
            let updatedObject = CartUtility.shared.cart[firstIndex]
            DataManager.encodeAndSaveObject(CartUtility.shared.cart, key: .cart)
            CartDebugger.log(.itemUpdatedInCart(onServer: false, itemName: updatedObject.itemDetails?.nameEnglish ?? "", hashId: updatedObject.hashId ?? "", updatedCount: updatedObject.quantity ?? 0))
        }
	}
	
	static func fetchCart() -> [CartListObject] {
		return CartUtility.shared.cart
	}
	
	static func syncCart(completion: @escaping (() -> Void)) {
        
        APIEndPoints.CartEndPoints.syncCart(storeId: CartUtility.getCartStoreID, success: { (response) in
            CartUtility.shared.concurrentQueue.async(flags: .barrier) {
                CartUtility.shared.cart = []
                CartUtility.shared.attachedCoupon = nil
                var incomingArray = response.data?.data ?? []
                var indexesToRemove: [Int] = []
                incomingArray.indices.forEach({
                    let object = incomingArray[$0]
                    if object.quantity ?? 0 == 0 && object.offerdItem ?? false == false {
                        indexesToRemove.append($0)
                    }
                })
                indexesToRemove.forEach({
                    let item = incomingArray[$0]
                    CartUtility.removeItemFromCart(item.hashId ?? "")
                })
                incomingArray = incomingArray.filter({ $0.quantity ?? 0 != 0 && $0.offerdItem ?? false == false })
                let incomingCoupon = response.data?.couponData
                CartUtility.shared.cart = incomingArray
                if (incomingArray.isEmpty || CartUtility.shared.appLaunched == true), let incomingCouponID = incomingCoupon?._id {
                    CartUtility.shared.appLaunched = false
                    CartUtility.shared.attachedCoupon = nil
                    CartUtility.removeCouponAndFreeItems(couponId: incomingCouponID, cartArray: incomingArray, completion: completion)
                    return
                }
                CartUtility.shared.appLaunched = false
                if let couponId = response.data?.couponData?._id, !couponId.isEmpty {
                    let couponData = response.data?.couponData
                    CartUtility.shared.attachedCoupon = couponData
                } else {
                    
                }
                DataManager.encodeAndSaveObject(incomingArray, key: .cart)
                CartDebugger.log(.cartSyncedWithServer(updatedCount: CartUtility.getItemCount()))
                CartUtility.syncCancellationPolicy()
                completion()
            }
		}, failure: { _ in
			completion()
		})
	}
    
    static func removeCouponAndFreeItems(couponId: String, cartArray: [CartListObject], completion: @escaping () -> Void) {
        CartUtility.shared.appLaunched = false
        APIEndPoints.CouponEndPoints.updateCouponOnCart(apply: false, couponId: couponId, success: { _ in
            CartUtility.shared.attachedCoupon = nil
            guard let freeItemExists = cartArray.first(where: { $0.offerdItem ?? false == true }) else {
                CartUtility.shared.cart = cartArray
                DataManager.encodeAndSaveObject(cartArray, key: .cart)
                CartDebugger.log(.cartSyncedWithServer(updatedCount: CartUtility.getItemCount()))
                completion()
                return
            }
            APIEndPoints.CartEndPoints.removeItemFromCart(req: RemoveItemFromCartRequest(itemId: freeItemExists.itemId ?? "", hashId: freeItemExists.hashId ?? "", offeredItem: true), success: { _ in
                CartUtility.removeItemFromCart("", offeredItem: true)
                completion()
            }, failure: { _ in
                CartUtility.removeItemFromCart("", offeredItem: true)
                completion()
            })
            
        }, failure: { _ in
            CartUtility.shared.cart = cartArray
            DataManager.encodeAndSaveObject(cartArray, key: .cart)
            CartDebugger.log(.cartSyncedWithServer(updatedCount: CartUtility.getItemCount()))
            CartUtility.syncCancellationPolicy()
            completion()
        })
    }
    
    static private func removeFreeItemFromCart(removed: @escaping (() -> Void)) {
        let cart = CartUtility.fetchCart()
        guard let freeItem = cart.first(where: { $0.offerdItem ?? false == true }) else {
            removed()
            return
        }
        CartUtility.removeItemFromCart(freeItem.hashId ?? "")
    }
    
    static private func attachLatestPromoData(couponId: String, fetched: @escaping ((PromoData?) -> Void)) {
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
	
    static func clearCart(clearedConfirmed: (() -> Void)? = nil) {
        NotificationScheduler.removeScheduledNotification(type: .idleCartReminder)
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            AppUserDefaults.removeValue(forKey: .cart)
            if let someCouponExists = CartUtility.shared.attachedCoupon {
                CartUtility.shared.attachedCoupon = nil
                APIEndPoints.CouponEndPoints.updateCouponOnCart(apply: false, couponId: someCouponExists._id ?? "", success: { _ in
                    CartUtility.shared.cart = []
                    APIEndPoints.CartEndPoints.clearCart(success: { _ in
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
                    clearedConfirmed?()
                }, failure: { _ in
                    clearedConfirmed?()
                })
            }
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
    
    static func addCouponToCartLocally(coupon: CouponObject) {
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            CartUtility.shared.attachedCoupon = coupon
        }
    }
    
    static func removeCouponFromCartLocally() {
        CartUtility.shared.concurrentQueue.async(flags: .barrier) {
            CartUtility.shared.attachedCoupon = nil
            if let freeItem = CartUtility.fetchCart().first, let offeredItem = freeItem.offerdItem, offeredItem == true, let hashId = freeItem.hashId {
                CartUtility.removeItemFromCart(hashId)
            }
        }
    }
    
    static func removeFreeItemFromCart() {
        if let freeItem = CartUtility.fetchCart().first(where: { $0.offerdItem ?? false == true }), let offeredItem = freeItem.offerdItem, offeredItem == true, let hashId = freeItem.hashId {
            CartUtility.removeItemFromCart(hashId)
            APIEndPoints.CartEndPoints.removeItemFromCart(req: RemoveItemFromCartRequest(itemId: freeItem.itemId ?? "", hashId: hashId, offeredItem: true), success: { _ in
                //No implementation needed
            }, failure: { _ in
                    //No implementation needed
                })
        }
    }
}
