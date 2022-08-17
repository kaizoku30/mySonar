import Foundation
import Alamofire

enum SocialLoginType: String {
    case facebook
    case google
    case apple
    case twitter
}

enum Endpoint {
    // MARK: PRELOGIN END POINTS
    case login(mobileNo: String, countryCode: String)
    case sendOtp(mobileNo: String, countryCode: String = "966", email: String?)
    case signUp(fullName: String, email: String?, mobileNo: String, countryCode: String = "966", deviceId: String = "123", deviceToken: String = "321")
    case verifyMobileOtp(fullName: String?, email: String?, mobileNo: String, countryCode: String = "966", mobileOtp: String, deviceId: String = "123", deviceToken: String = "321")
    case socialLogIn(socialLoginType: SocialLoginType, socialId: String, deviceId: String = "123", deviceToken: String = "321")
    case socialSignup(socialLoginType: SocialLoginType, socialId: String, fullName: String, mobileNo: String, email: String?, countryCode: String = "966", deviceId: String = "123", deviceToken: String = "321")
    case socialVerification(socialLoginType: SocialLoginType, socialId: String, fullName: String, mobileNo: String, email: String?, mobileOtp: String, countryCode: String = "966", deviceId: String = "123", deviceToken: String = "321")
    
    // MARK: ADDRESS END POINTS
    case addAddress(request: AddAddressRequest)
    case editAddress(addressId: String, request: AddAddressRequest)
    case getAddressList
    case deleteAddress(id: String)
    
    // MARK: SETTINGS END POINTS
    case sendFeedback(request: SendFeedbackRequest)
    case supportDetails
    case logout
    case deleteAccount
    
    // MARK: HOME END POINTS
    case menuList(request: MenuListRequest)
    case generalPromoList
    case menuItemList(menuId: String)
    case itemDetail(itemId: String)
    case getRestaurantSuggestions(request: RestaurantListRequest)
    case getRestaurantListing(request: RestaurantListRequest)
    case topSearchMenu(servicesType: HomeVM.SectionType)
    case getSearchSuggestionsMenu(searchKey: String, type: HomeVM.SectionType)
    case getSearchResults(pageNo: Int, limit: Int = 10, type: HomeVM.SectionType, searchKey: String)
    case editProfile(name: String?, email: String?)
    case verifyEmailOtp(otp: String, email: String)
    case sendOtpOnMail(email: String)
    case ourStoreListing(searchKey: String, lat: Double, long: Double)
    
    // MARK: NOTIFICATION END POINTS
    case notificationPref(req: NotificationPrefRequest)
    
    case payment(cardToken: String)
    
    /// GET, POST or PUT method for each request
    var method: Alamofire.HTTPMethod {
        switch self {
        case .payment, .login, .sendOtp, .verifyMobileOtp, .socialSignup, .socialVerification, .logout, .signUp, .socialLogIn, .addAddress, .sendFeedback, .verifyEmailOtp, .sendOtpOnMail:
            return .post
        case .getAddressList, .supportDetails, .menuList, .generalPromoList, .menuItemList, .getRestaurantSuggestions, .getRestaurantListing, .topSearchMenu, .getSearchSuggestionsMenu, .getSearchResults, .itemDetail, .ourStoreListing:
            return .get
        case .editAddress, .notificationPref, .editProfile:
            return .put
        case .deleteAddress, .deleteAccount:
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
        case .login, .verifyMobileOtp, .signUp, .logout, .sendOtp, .socialLogIn, .socialSignup, .socialVerification, .addAddress, .getAddressList, .editAddress, .sendFeedback, .supportDetails, .menuList, .generalPromoList, .menuItemList, .deleteAccount, .getRestaurantSuggestions, . getRestaurantListing, .topSearchMenu, .getSearchSuggestionsMenu, .getSearchResults, .itemDetail, .notificationPref, .editProfile, .verifyEmailOtp, .sendOtpOnMail, .ourStoreListing:
            return baseUrl + registerIntermediate + apiPath
        case .deleteAddress(let id):
            return baseUrl + registerIntermediate + apiPath + "/\(id)"
        case .payment:
            return Constants.CheckOutCredentials.postApiURL
        }
    }
    
    var microService: String {
        switch self {
        case .generalPromoList, .menuList, .menuItemList, .getRestaurantSuggestions, .getRestaurantListing, .topSearchMenu, .getSearchSuggestionsMenu, .getSearchResults, .itemDetail, .ourStoreListing:
            return "userStore"
        default:
            return "userOnboard"
        }
    }
    
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
        case .generalPromoList:
            return "generalPromoList"
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
        default:
            return ""
        }
    }
    
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
            if request.storeId.isNotNil {
                params[Constants.APIKeys.storeId.rawValue] = request.storeId!
            }
            
            return params
        case .menuItemList(let menuId):
            return [Constants.APIKeys.menuId.rawValue: menuId]
        case .getRestaurantSuggestions(let request), .getRestaurantListing(let request):
            var params: [String: Any] = [Constants.APIKeys.latitude.rawValue: request.latitude,
                                         Constants.APIKeys.longitude.rawValue: request.longitude,
                                         Constants.APIKeys.servicesType.rawValue: request.type.rawValue]
            if let searchKey = request.searchKey {
                params[Constants.APIKeys.searchKey.rawValue] = searchKey
            }
            return params
        case .topSearchMenu(let servicesType):
            return [Constants.APIKeys.servicesType.rawValue: servicesType.rawValue]
        case .getSearchSuggestionsMenu(let searchKey, let type):
            return [Constants.APIKeys.searchKey.rawValue: searchKey, Constants.APIKeys.servicesType.rawValue: type.rawValue]
        case .getSearchResults(let pageNo, let limit, let type, let searchKey):
            return [Constants.APIKeys.pageNo.rawValue: pageNo,
                    Constants.APIKeys.limit.rawValue: limit,
                    Constants.APIKeys.servicesType.rawValue: type,
                    Constants.APIKeys.searchKey.rawValue: searchKey]
        case .itemDetail(let itemId):
            return [Constants.APIKeys.itemId.rawValue: itemId]
        case .notificationPref(let request):
            return request.getRequestObject()
        case .editProfile(let name, let email):
            var params: [String: Any] = [:]
            if let name = name {
                params[Constants.APIKeys.fullName.rawValue] = name
            }
            if let email = email {
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
        default:
            return [:]
        }
    }
    
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
        case .logout, .addAddress, .getAddressList, .deleteAddress, .editAddress, .sendFeedback, .deleteAccount, .notificationPref, .editProfile, .verifyEmailOtp, .sendOtpOnMail:
            headers["api_key"] = "123456"
            headers["authorization"] = "Bearer \(DataManager.shared.loginResponse?.accessToken ?? "")"
        default:
            headers["authorization"] = "Basic \(Constants.BasicAuthCredentials.b64String)"
        }
        headers["xApiPath"] = self.apiPath
        return HTTPHeaders(headers)
    }
}
