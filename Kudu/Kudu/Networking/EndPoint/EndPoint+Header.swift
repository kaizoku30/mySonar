//
//  EndPoint+Header.swift
//  Kudu
//
//  Created by Admin on 26/09/22.
//

import Foundation
import Alamofire

extension Endpoint {
    
    /// http header for each request (if needed)
    var header: HTTPHeaders? {
        var currentLanguage = AppUserDefaults.value(forKey: .selectedLanguage) as? String ?? ""
        if currentLanguage == "" {
            currentLanguage = AppUserDefaults.Language.en.rawValue
        }
        var headers = ["platform": "2", "language": currentLanguage]
        switch self {
        case .payment:
            headers = [:]
            headers["authorization"] = "sk_test_146d56ed-4dcd-493a-9db2-866c924c0bba"
        case .logout, .addAddress, .getAddressList, .deleteAddress, .editAddress, .deleteAccount, .notificationPref, .editProfile, .verifyEmailOtp, .sendOtpOnMail, .addFavourites, .favouriteItemList, .favouriteHashSync, .addItemToCart, .updateCartQuantity, .removeItemFromCart, .syncCart, .getCartConfig, .cancellationPolicy, .youMayAlsoLike, .clearCart, .updateVehicle, .getOnlineCouponListing, .updateCouponOnCart, .getCouponDetail, .selectedRestaurantList, .getCouponCodeDetail, .placeOrder:
            headers["api_key"] = "123456"
            headers["authorization"] = "Bearer \(DataManager.shared.loginResponse?.accessToken ?? "")"
        default:
            headers["authorization"] = "Basic \(Constants.BasicAuthCredentials.b64String)"
        }
        headers["xApiPath"] = self.apiPath
        return HTTPHeaders(headers)
    }
}
