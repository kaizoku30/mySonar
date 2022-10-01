//
//  CartUtility+Coupon.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import Foundation

enum CouponValidationFailedReason: Equatable {
    case timeBounds
    case serviceTypeMismatch(correctOrderType: APIEndPoints.ServicesType)
    case amountNotEnough(amountReq: Int)
    case menuIDsNeeded
    case itemIDsNeeded
   // case cartEmpty
    case storeIdConflict(delivery: Bool)
    
    var errorMsg: String {
        switch self {
        case .timeBounds:
            return "Offer is not applicable for now"
            //return "Offer only valid from \(validFromTime) to \(validToTime)"
        case .serviceTypeMismatch(let correctOrderType):
            var string = "Delivery"
            switch correctOrderType {
            case .curbside:
                string = "Curbside"
            case .delivery:
                break
            case .pickup:
                string = "PickUp"
            }
            return "Offer only valid for \(string) Order Type"
        case .amountNotEnough(let minAmount):
            return "Minimum Cart amount should be SR \(minAmount)"
        case .menuIDsNeeded, .itemIDsNeeded:
            return "Cart does not contain required items"
//        case .cartEmpty:
//            return "Your cart is empty"
        case .storeIdConflict(let isDelivery):
            if isDelivery {
                return "Offer is not valid for the selected location"
            } else {
                return "Offer is not valid for the selected store"
            }
        }
    }
}

extension CartUtility {
    
    static func checkCouponValidationError(_ obj: CouponObject) -> CouponValidationFailedReason? {
        
//        if CartUtility.getItemCount() == 0 {
//            debugPrint("COUPON CART EMPTY")
//            return .cartEmpty
//        }
        let cartType = CartUtility.getCartServiceType
        let excludedStoreIDs = obj.excludeLocations ?? []
        let currentStoreId = CartUtility.getCartStoreID
        if let storeIdExists = currentStoreId, excludedStoreIDs.contains(where: { $0 == storeIdExists}) {
            debugPrint("COUPON STORE MISMATCH")
            return .storeIdConflict(delivery: cartType == .delivery)
        }
        
        let couponFromDate = Date(timeIntervalSince1970: Double(obj.validFrom ?? 0)/1000)
        let couponToDate = Date(timeIntervalSince1970: Double(obj.validTo ?? 0)/1000)
        let currentDate = Date()
        if currentDate < couponFromDate || currentDate > couponToDate {
            debugPrint("COUPON TIME MISMATCH")
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
            debugPrint("COUPON TIME MISMATCH")
            return .timeBounds
        }
        if currentTime > couponToTime {
            debugPrint("COUPON TIME MISMATCH")
            return .timeBounds
        }
        
        if let couponServiceType = APIEndPoints.ServicesType(rawValue: obj.promoData?.servicesAvailable ?? ""), cartType != couponServiceType {
            debugPrint("COUPON SERVICE TYPE MISMATCH")
            return .serviceTypeMismatch(correctOrderType: couponServiceType)
        }
        let couponCartAmount = obj.promoData?.minimumCartAmount ?? 0
        let cartAmount = CartUtility.getPrice()
        if Int(cartAmount) < couponCartAmount {
            debugPrint("COUPON AMOUNT MISMATCH")
            return .amountNotEnough(amountReq: couponCartAmount)
        }
        var menuIdExists = false
        let currentCart = CartUtility.fetchCart()
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
    
    static func removeCouponFromCart(completionHandler: @escaping (() -> Void), cartRef: [CartListObject]?) {
        guard let coupon = CartUtility.getAttachedCoupon, let couponId = coupon._id, couponId.isEmpty == false else {
            completionHandler()
            return
        }
        var cartItems: [CartListObject] = []
        if cartRef.isNotNil {
            cartItems = cartRef!
        } else {
            cartItems = CartUtility.fetchCart()
        }
        self.removeCouponAndFreeItems(couponId: couponId, cartArray: cartItems, completion: completionHandler)
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
