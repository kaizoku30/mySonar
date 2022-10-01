//
//  Endpoint+Parameters.swift
//  Kudu
//
//  Created by Admin on 26/09/22.
//

import Foundation

extension Endpoint {
    
    /// parameters Dictionary for each request
    var parameters: [String: Any] {
        switch self {
        case .payment(let cardToken):
            return ["source": ["type": "token", "token": cardToken],
                    "amount": 1, "currency": "USD", "reference": "ORD=5023-4E38"]
        case .login(let mobileNo, let countryCode):
            return [Constants.APIKeys.mobileNo.rawValue: mobileNo,
                    Constants.APIKeys.countryCode.rawValue: countryCode]
        case .signUp(let fullName, let email, let mobileNo, let countryCode, let deviceId, let deviceToken):
            var params: [String: Any] = [Constants.APIKeys.fullName.rawValue: fullName,
                                         Constants.APIKeys.mobileNo.rawValue: mobileNo,
                                         Constants.APIKeys.countryCode.rawValue: countryCode,
                                         Constants.APIKeys.deviceId.rawValue: deviceId,
                                         Constants.APIKeys.deviceToken.rawValue: deviceToken]
            if let email = email {
                params[Constants.APIKeys.email.rawValue] = email
            }
            return params
        case .verifyMobileOtp(let fullName, let email, let mobileNo, let countryCode, let mobileOtp, let deviceId, let deviceToken):
            var params: [String: Any] = [Constants.APIKeys.mobileNo.rawValue: mobileNo,
                                         Constants.APIKeys.countryCode.rawValue: countryCode,
                                         Constants.APIKeys.deviceId.rawValue: deviceId,
                                         Constants.APIKeys.deviceToken.rawValue: deviceToken,
                                         Constants.APIKeys.mobileOtp.rawValue: mobileOtp]
            if let email = email {
                params[Constants.APIKeys.email.rawValue] = email
            }
            if let fullName = fullName {
                params[Constants.APIKeys.fullName.rawValue] = fullName
            }
            return params
        case .sendOtp(let mobileNo, let countryCode, let email):
            var params: [String: Any] = [Constants.APIKeys.mobileNo.rawValue: mobileNo,
                                         Constants.APIKeys.countryCode.rawValue: countryCode]
            if let email = email {
                params[Constants.APIKeys.email.rawValue] = email
            }
            return params
        case .socialLogIn(let socialLoginType, let socialId, let deviceId, let deviceToken):
            let params: [String: Any] = [Constants.APIKeys.socialLoginType.rawValue: socialLoginType.rawValue,
                                         Constants.APIKeys.socialId.rawValue: socialId,
                                         Constants.APIKeys.deviceId.rawValue: deviceId,
                                         Constants.APIKeys.deviceToken.rawValue: deviceToken]
            return params
        case .socialSignup(let socialLoginType, let socialId, let fullName, let mobileNo, let email, let countryCode, let deviceId, let deviceToken) :
            var params: [String: Any] = [Constants.APIKeys.fullName.rawValue: fullName,
                                         Constants.APIKeys.mobileNo.rawValue: mobileNo,
                                         Constants.APIKeys.countryCode.rawValue: countryCode,
                                         Constants.APIKeys.deviceId.rawValue: deviceId,
                                         Constants.APIKeys.deviceToken.rawValue: deviceToken,
                                         Constants.APIKeys.socialLoginType.rawValue: socialLoginType.rawValue,
                                         Constants.APIKeys.socialId.rawValue: socialId]
            if email.isNotNil {
                params[Constants.APIKeys.email.rawValue] = email!
            }
            return params
        case .socialVerification(let socialLoginType, let socialId, let fullName, let mobileNo, let email, let mobileOtp, let countryCode, let deviceId, let deviceToken):
            var params: [String: Any] = [Constants.APIKeys.fullName.rawValue: fullName,
                                         Constants.APIKeys.mobileNo.rawValue: mobileNo,
                                         Constants.APIKeys.countryCode.rawValue: countryCode,
                                         Constants.APIKeys.deviceId.rawValue: deviceId,
                                         Constants.APIKeys.deviceToken.rawValue: deviceToken,
                                         Constants.APIKeys.socialLoginType.rawValue: socialLoginType.rawValue,
                                         Constants.APIKeys.socialId.rawValue: socialId,
                                         Constants.APIKeys.mobileOtp.rawValue: mobileOtp]
            if email.isNotNil {
                params[Constants.APIKeys.email.rawValue] = email!
            }
            return params
        case .addAddress(let request):
            return request.getRequestJson()
        case .editAddress(let addressId, let request):
            var json = request.getRequestJson()
            json[Constants.APIKeys.addressId.rawValue] = addressId
            return json
        case .sendFeedback(let request):
            return request.getRequestJson()
        case .menuList(let request):
            var params: [String: Any] = [Constants.APIKeys.servicesType.rawValue: request.servicesType.rawValue]
            if request.long.isNotNil && request.lat.isNotNil {
                params[Constants.APIKeys.longitude.rawValue] = request.long!
                params[Constants.APIKeys.latitude.rawValue] = request.lat!
            }
            if let storeId = request.storeId, !storeId.isEmpty {
                params[Constants.APIKeys.storeId.rawValue] = storeId
            }
            
            return params
        case .menuItemList(let menuId):
            var params: [String: Any] = [Constants.APIKeys.menuId.rawValue: menuId]
            if AppUserDefaults.value(forKey: .loginResponse).isNotNil {
                params[Constants.APIKeys.userId.rawValue] = DataManager.shared.loginResponse?.userId ?? ""
            }
            return params
        case .getRestaurantSuggestions(let request), .getRestaurantListing(let request):
            var params: [String: Any] = [Constants.APIKeys.latitude.rawValue: request.latitude,
                                         Constants.APIKeys.longitude.rawValue: request.longitude,
                                         Constants.APIKeys.servicesType.rawValue: request.type.rawValue]
            if let searchKey = request.searchKey, !searchKey.isEmpty {
                params[Constants.APIKeys.searchKey.rawValue] = searchKey
            }
            return params
        case .topSearchMenu(let servicesType):
            return [Constants.APIKeys.servicesType.rawValue: servicesType.rawValue]
        case .getSearchSuggestionsMenu(let searchKey, let type, let storeId):
            var params: [String: Any] = [Constants.APIKeys.searchKey.rawValue: searchKey, Constants.APIKeys.servicesType.rawValue: type.rawValue]
            if let storeId = storeId, !storeId.isEmpty {
                params[Constants.APIKeys.storeId.rawValue] = storeId
            }
            return params
        case .getSearchResults(let storeId, let pageNo, let limit, let type, let searchKey):
            var params: [String: Any] = [Constants.APIKeys.pageNo.rawValue: pageNo,
                                         Constants.APIKeys.limit.rawValue: limit,
                                         Constants.APIKeys.servicesType.rawValue: type,
                                         Constants.APIKeys.searchKey.rawValue: searchKey]
            if AppUserDefaults.value(forKey: .loginResponse).isNotNil {
                params[Constants.APIKeys.userId.rawValue] = DataManager.shared.loginResponse?.userId ?? ""
            }
            if let storeId = storeId, storeId.isEmpty == false {
                params[Constants.APIKeys.storeId.rawValue] = storeId
            }
            return params
        case .itemDetail(let itemId):
            var params: [String: Any] = [Constants.APIKeys.itemId.rawValue: itemId]
            if AppUserDefaults.value(forKey: .loginResponse).isNotNil {
                params[Constants.APIKeys.userId.rawValue] = DataManager.shared.loginResponse?.userId ?? ""
            }
            return params
        case .notificationPref(let request):
            return request.getRequestObject()
        case .editProfile(let name, let email):
            var params: [String: Any] = [:]
            if let name = name, !name.isEmpty {
                params[Constants.APIKeys.fullName.rawValue] = name
            }
            if let email = email, email.isEmpty == false {
                params[Constants.APIKeys.email.rawValue] = email
            }
            return params
        case .verifyEmailOtp(let otp, let email):
            return [Constants.APIKeys.email.rawValue: email,
                    Constants.APIKeys.emailOtp.rawValue: otp]
        case .sendOtpOnMail(let email):
            return [Constants.APIKeys.email.rawValue: email]
        case .ourStoreListing(let searchKey, let lat, let long):
            return [Constants.APIKeys.searchKey.rawValue: searchKey,
                    Constants.APIKeys.latitude.rawValue: lat,
                    Constants.APIKeys.longitude.rawValue: long]
        case .addFavourites(let req):
            return req.getRequestJson()
        case .favouriteItemList(let pageNo, let limit):
            return [Constants.APIKeys.pageNo.rawValue: pageNo, Constants.APIKeys.limit.rawValue: limit]
        case .getStoreIdForDelivery(let lat, let long, let serviceType):
            return [Constants.APIKeys.latitude.rawValue: lat, Constants.APIKeys.longitude.rawValue: long, Constants.APIKeys.servicesType.rawValue: serviceType.rawValue]
        case .addItemToCart(let request):
            return request.getRequestJson()
        case .updateCartQuantity(let request):
            return request.getRequestJson()
        case .removeItemFromCart(let request):
            return request.getRequestJson()
        case .getCartConfig(let storeId):
            if let storeId = storeId {
                return [Constants.APIKeys.storeId.rawValue: storeId]
            }
            return [:]
        case .youMayAlsoLike(let serviceType):
            return [Constants.APIKeys.servicesAvailable.rawValue: serviceType]
        case .updateVehicle(let req):
            return req.getRequestJSON()
        case .updateCouponOnCart(let apply, let couponId):
            return [Constants.APIKeys.applyCoupon.rawValue: apply, Constants.APIKeys.couponId.rawValue: couponId]
        case .getOnlineCouponListing(let serviceType):
            return [Constants.APIKeys.servicesAvailable.rawValue: serviceType.rawValue]
        case .selectedRestaurantList(let exclude, let pageNo, let limit, let searchKey):
            var params: [String: Any] = [:]
            var commaString: String = ""
            exclude.forEach({
                if commaString.isEmpty {
                    commaString = $0
                } else {
                    commaString += ",\($0)"
                }
            })
            params[Constants.APIKeys.excludeLocations.rawValue] = commaString
            params[Constants.APIKeys.pageNo.rawValue] = pageNo
            params[Constants.APIKeys.limit.rawValue] = limit
            if let searchKey = searchKey, searchKey.isEmpty == false {
                params[Constants.APIKeys.searchKey.rawValue]  = searchKey
            }
            return params
        case .getCouponCodeDetail(let couponCode):
            return [Constants.APIKeys.couponCode.rawValue: couponCode]
        case .syncCart(let storeId):
            if let storeId = storeId, storeId.isEmpty == false {
                return [Constants.APIKeys.storeId.rawValue: storeId]
            }
            return [:]
        case .getRecommendations(let serviceType):
            return [Constants.APIKeys.servicesAvailable.rawValue: serviceType.rawValue]
        case .banners(let serviceType):
            return [Constants.APIKeys.servicesAvailable.rawValue: serviceType.rawValue]
        case .placeOrder(let req):
            return req.getRequest()
        default:
            return [:]
        }
    }
}
