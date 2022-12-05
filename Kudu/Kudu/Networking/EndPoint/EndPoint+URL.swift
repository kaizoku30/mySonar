//
//  EndPoint+URL.swift
//  Kudu
//
//  Created by Admin on 26/09/22.
//

import Foundation
import Alamofire

extension Endpoint {
    /// GET, POST or PUT method for each request
    var method: Alamofire.HTTPMethod {
        switch self {
        case .payment, .login, .sendOtp, .verifyMobileOtp, .socialSignup, .socialVerification, .logout, .signUp, .socialLogIn, .addAddress, .sendFeedback, .verifyEmailOtp, .sendOtpOnMail, .addFavourites, .addItemToCart, .placeOrder, .reorderItems, .validateOrder, .tokenCardPayment, .savedCardPayment, .codPayment, .changeDeviceLang, .changePhoneNumber, .uploadCertificate, .changeDeviceToken:
            return .post
        case .getAddressList, .supportDetails, .menuList, .banners, .menuItemList, .getRestaurantSuggestions, .getRestaurantListing, .topSearchMenu, .getSearchSuggestionsMenu, .getSearchResults, .itemDetail, .ourStoreListing, .favouriteItemList, .favouriteHashSync, .getStoreIdForDelivery, .syncCart, .getCartConfig, .cancellationPolicy, .youMayAlsoLike, .getOnlineCouponListing, .getCouponDetail, .selectedRestaurantList, .getCouponCodeDetail, .getRecommendations, .orderDetails, .orderList, .inStoreCouponList, .inStoreCouponDetails, .getCards, .notificationList, .checkUpdateConfiguration:
            return .get
        case .editAddress, .notificationPref, .editProfile, .updateCartQuantity, .removeItemFromCart, .updateVehicle, .updateCouponOnCart, .arrivedAtStore, .rating, .cancelOrder, .redeemInStoreCoupon:
            return .put
        case .deleteAddress, .deleteAccount, .clearCart, .deleteCard, .deleteNotification, .deleteAllNotification:
            return .delete
        }
    }
    
    /// URLEncoding used for GET requests and JSONEncoding for POST and PUT requests
    var encoding: Alamofire.ParameterEncoding {
    
        if self.method == .get {
            return URLEncoding.default
        } else {
            return JSONEncoding.default
        }
    }
    
    /// URL string for each request
    var path: String {
        let baseUrl = Environment().configuration(.kBaseUrl)
        let registerIntermediate = "/\(microService)/api/v1/"
        switch self {
        case .login, .verifyMobileOtp, .signUp, .logout, .sendOtp, .socialLogIn, .socialSignup, .socialVerification, .addAddress, .getAddressList, .editAddress, .sendFeedback, .supportDetails, .menuList, .banners, .menuItemList, .deleteAccount, .getRestaurantSuggestions, . getRestaurantListing, .topSearchMenu, .getSearchSuggestionsMenu, .getSearchResults, .itemDetail, .notificationPref, .editProfile, .verifyEmailOtp, .sendOtpOnMail, .ourStoreListing, .addFavourites, .favouriteItemList, .favouriteHashSync, .getStoreIdForDelivery, .addItemToCart, .updateCartQuantity, .removeItemFromCart, .syncCart, .getCartConfig, .cancellationPolicy, .youMayAlsoLike, .clearCart, .updateVehicle, .getOnlineCouponListing, .updateCouponOnCart, .selectedRestaurantList, .getCouponCodeDetail, .getRecommendations, .placeOrder, .orderList, .orderDetails, .arrivedAtStore, .rating, .cancelOrder, .reorderItems, .validateOrder, .redeemInStoreCoupon, .inStoreCouponList, .tokenCardPayment, .getCards, .savedCardPayment, .codPayment, .deleteCard, .deleteAllNotification, .changeDeviceLang, .changePhoneNumber, .checkUpdateConfiguration, .changeDeviceToken:
            return baseUrl + registerIntermediate + apiPath
        case .getCouponDetail(let id):
            return baseUrl + registerIntermediate + apiPath + "/\(id)"
        case .inStoreCouponDetails(let id):
            return baseUrl + registerIntermediate + apiPath + "/\(id)"
        case .deleteAddress(let id):
            return baseUrl + registerIntermediate + apiPath + "/\(id)"
        case .payment:
            return Constants.CheckOutCredentials.postApiURL
        case .deleteNotification(let id):
            return baseUrl + registerIntermediate + apiPath + "/\(id)"
        case .notificationList(let pageNo, let limit):
            return baseUrl + registerIntermediate + apiPath + "?pageNo=\(pageNo)" + "&limit=\(limit)"
        case .uploadCertificate:
            return "https://api.sandbox.checkout.com/applepay/certificates"
        }
    }
    
    var microService: String {
        switch self {
        case .banners, .menuList, .menuItemList, .getRestaurantSuggestions, .getRestaurantListing, .topSearchMenu, .getSearchSuggestionsMenu, .getSearchResults, .itemDetail, .ourStoreListing, .addFavourites, .favouriteItemList, .favouriteHashSync, .getStoreIdForDelivery, .getRecommendations:
            return "userStore"
        case .addItemToCart, .updateCartQuantity, .removeItemFromCart, .syncCart, .getCartConfig, .cancellationPolicy, .youMayAlsoLike, .clearCart, .updateVehicle, .getOnlineCouponListing, .updateCouponOnCart, .getCouponDetail, .selectedRestaurantList, .getCouponCodeDetail, .inStoreCouponList, .inStoreCouponDetails, .reorderItems:
            return "userCart"
        case .placeOrder, .orderList, .arrivedAtStore, .orderDetails, .rating, .cancelOrder, .validateOrder, .redeemInStoreCoupon, .tokenCardPayment, .getCards, .savedCardPayment, .codPayment, .deleteCard:
            return "userPayment"
        default:
            return "userOnboard"
        }
    }
}

extension Endpoint {
    
    var apiPath: String {
        switch self {
        case .login:
            return "login"
        case .signUp:
            return "signup"
        case .verifyMobileOtp:
            return "verifyMobileOtp"
        case .logout:
            return "logout"
        case .sendOtp:
            return "sendOtp"
        case .socialLogIn:
            return "socialLogin"
        case .socialSignup:
            return "socialSignup"
        case .socialVerification:
            return "socialVerification"
        case .addAddress, .getAddressList, .editAddress:
            return "address"
        case .deleteAddress:
            return "deleteAddress"
        case .sendFeedback:
            return "userFeedback"
        case .supportDetails:
            return "supportDetails"
        case .deleteAccount:
            return "deleteAccount"
        case .menuList:
            return "menuList"
        case .banners:
            return "banners"
        case .menuItemList:
            return "menuItemList"
        case .getRestaurantSuggestions:
            return "storeLocation"
        case .getRestaurantListing:
            return "storeList"
        case .topSearchMenu:
            return "topSearchMenu"
        case .getSearchSuggestionsMenu:
            return "itemSearchList"
        case .getSearchResults:
            return "itemList"
        case .itemDetail:
            return "itemDetails"
        case .notificationPref:
            return "notificationSetting"
        case .editProfile:
            return "updateProfile"
        case .verifyEmailOtp:
            return "verifyEmailOtp"
        case .sendOtpOnMail:
            return "sendOtpOnEmail"
        case .ourStoreListing:
            return "myStoreList"
        case .addFavourites:
            return "addFavourites"
        case .favouriteItemList:
            return "favouriteItemList"
        case .favouriteHashSync:
            return "favouriteHashSync"
        case .getStoreIdForDelivery:
            return "deliveryStore"
        case .addItemToCart:
            return "addToCart"
        case .updateCartQuantity:
            return "updateCartQantity"
        case .removeItemFromCart:
            return "removeCart"
        case .syncCart:
            return "cartList"
        case .getCartConfig:
            return "generalSetting"
        case .cancellationPolicy:
            return "cancellationPolicy"
        case .youMayAlsoLike:
            return "youMayAlsoLike"
        case .clearCart:
            return "removeAllCartItem"
        case .updateVehicle:
            return "vehicleDetails"
        case .getOnlineCouponListing:
            return "couponList"
        case .updateCouponOnCart:
            return "updateCartCoupon"
        case .getCouponDetail:
            return "couponDetails"
        case .selectedRestaurantList:
            return "selectedRestaurantList"
        case .getCouponCodeDetail:
            return "validateCoupon"
        case .getRecommendations:
            return "getRecommendations"
        case .placeOrder:
            return "placeOrder"
        case .orderList:
            return "orderList"
        case .orderDetails:
            return "orderDetails"
        case .arrivedAtStore:
            return "arrivedStore"
        case .cancelOrder:
            return "cancelOrder"
        case .rating:
            return "rateYourOrder"
        case .reorderItems:
            return "reorderItems"
        case .validateOrder:
            return "validateOrder"
        case .inStoreCouponList:
            return "inStoreCouponList"
        case .inStoreCouponDetails:
            return "inStoreCouponDetails"
        case .redeemInStoreCoupon:
            return "redeemInStoreCoupon"
        case .tokenCardPayment, .savedCardPayment, .codPayment:
            return "payments"
        case .getCards:
            return "payments/cards"
        case .deleteCard:
            return "payments/remove-card"
        case .notificationList, .deleteNotification:
            return "notification"
        case .deleteAllNotification:
            return "deleteAllNotification"
        case .changeDeviceLang:
            return "changeDeviceLang"
        case .changePhoneNumber:
            return "changePhoneNumber"
        case .checkUpdateConfiguration:
            return "currentVersion"
        case .changeDeviceToken:
            return "changeDeviceToken"
        default:
            return ""
        }
    }
}
