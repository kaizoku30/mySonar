//
//  PaymentTestEndPoints.swift
//  Kudu
//
//  Created by Admin on 28/04/22.
//

import Foundation

class WebServices {
    
    enum AddressLabelType: String {
        case OTHER
        case HOME
        case WORK
    }
    
    enum ServicesType: String {
        case curbside
        case delivery
        case pickup
    }
    
    final class OnboardingEndPoints {
        static func login(mobileNo: String, countryCode: String = "966", success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .login(mobileNo: mobileNo, countryCode: countryCode), successHandler: success, failureHandler: failure)
        }
        static func signUp(name: String, mobileNo: String, email: String?, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .signUp(fullName: name, email: email, mobileNo: mobileNo), successHandler: success, failureHandler: failure)
        }
        static func verifyMobileOtp(signUpRequest: SignUpRequest, mobileOtp: String, success: @escaping SuccessCompletionBlock<OTPVerificationResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            let name = signUpRequest.name
            let email = signUpRequest.email
            let mobileNo = signUpRequest.mobileNum
            Api.requestNew(endpoint: .verifyMobileOtp(fullName: name, email: email, mobileNo: mobileNo, mobileOtp: mobileOtp), successHandler: success, failureHandler: failure)
        }
        static func verifyMobileOtpLogin(mobileNum: String, mobileOtp: String, success: @escaping SuccessCompletionBlock<OTPVerificationResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .verifyMobileOtp(fullName: nil, email: nil, mobileNo: mobileNum, mobileOtp: mobileOtp), successHandler: success, failureHandler: failure)
        }
        static func sendOtp(mobileNo: String, email: String?, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .sendOtp(mobileNo: mobileNo, email: email), successHandler: success, failureHandler: failure)
        }
        static func socialLogin(socialLoginType: SocialLoginType, socialId: String, success: @escaping SuccessCompletionBlock<SocialLoginResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .socialLogIn(socialLoginType: socialLoginType, socialId: socialId), successHandler: success, failureHandler: failure)
        }
        static func socialSignUp(signUpReq: SocialSignUpRequest, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .socialSignup(socialLoginType: signUpReq.socialLoginType, socialId: signUpReq.socialId, fullName: signUpReq.name ?? "", mobileNo: signUpReq.mobileNum ?? "", email: signUpReq.email), successHandler: success, failureHandler: failure)
        }
        static func socialVerification(signUpReq: SocialSignUpRequest, otp: String, success: @escaping SuccessCompletionBlock<OTPVerificationResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .socialVerification(socialLoginType: signUpReq.socialLoginType, socialId: signUpReq.socialId, fullName: signUpReq.name ?? "", mobileNo: signUpReq.mobileNum ?? "", email: signUpReq.email, mobileOtp: otp), successHandler: success, failureHandler: failure)
        }
    }
    
    final class PaymentTestEndPoints {
        static func payADollar(cardToken: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .payment(cardToken: cardToken), successHandler: success, failureHandler: failure)
        }
    }
}

extension WebServices {
    final class AddressEndPoints {
        static func addAddress(request: AddAddressRequest, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .addAddress(request: request), successHandler: success, failureHandler: failure)
        }
        
        static func editAddress(addressId: String, request: AddAddressRequest, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .editAddress(addressId: addressId, request: request), successHandler: success, failureHandler: failure)
        }
        
        static func deleteAddress(id: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .deleteAddress(id: id), successHandler: success, failureHandler: failure)
        }
        
        static func getAddressList(success: @escaping SuccessCompletionBlock<MyAddressResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .getAddressList, successHandler: success, failureHandler: failure)
        }
    }
}

extension WebServices {
    final class SettingsEndPoints {
        static func sendFeedback(request: SendFeedbackRequest, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .sendFeedback(request: request), successHandler: success, failureHandler: failure)
        }
        
        static func supportDetails(success: @escaping SuccessCompletionBlock<SupportDetailsResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .supportDetails, successHandler: success, failureHandler: failure)
        }
        
        static func logout(success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .logout, successHandler: success, failureHandler: failure)
        }
        
        static func deleteAccount(success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .deleteAccount, successHandler: success, failureHandler: failure)
        }
    }
}

extension WebServices {
    final class HomeEndPoints {
        static func getMenuList(request: MenuListRequest, success: @escaping SuccessCompletionBlock<MenuListResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .menuList(request: request), successHandler: success, failureHandler: failure)
        }
        
        static func getGeneralPromoList(success: @escaping SuccessCompletionBlock<GeneralPromoResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .generalPromoList, successHandler: success, failureHandler: failure)
        }
        
        static func getMenuItemList(menuId: String, success: @escaping SuccessCompletionBlock<MenuItemListResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .menuItemList(menuId: menuId), successHandler: success, failureHandler: failure)
        }
        
        static func getItemDetail(itemId: String, success: @escaping SuccessCompletionBlock<ItemDetailResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .itemDetail(itemId: itemId), successHandler: success, failureHandler: failure)
        }
        
        static func getRestaurantSuggestions(request: RestaurantListRequest, success: @escaping SuccessCompletionBlock<RestaurantSuggestionsResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .getRestaurantSuggestions(request: request), successHandler: success, failureHandler: failure)
        }
        
        static func getRestaurantListing(request: RestaurantListRequest, success: @escaping SuccessCompletionBlock<RestaurantListResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .getRestaurantListing(request: request), successHandler: success, failureHandler: failure)
        }
        
        static func getTopSearchedCategories(type: HomeVM.SectionType, success: @escaping SuccessCompletionBlock<TopSearchCategoriesResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .topSearchMenu(servicesType: type), successHandler: success, failureHandler: failure)
        }
        
        static func getSearchSuggestionsMenu(searchKey: String, type: HomeVM.SectionType, success: @escaping SuccessCompletionBlock<SuggestionExploreMenuResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .getSearchSuggestionsMenu(searchKey: searchKey, type: type), successHandler: success, failureHandler: failure)
        }
        
        static func getSearchResultsMenu(searchKey: String, type: HomeVM.SectionType, pageNo: Int, success: @escaping SuccessCompletionBlock<ResultsExploreMenuResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .getSearchResults(pageNo: pageNo, type: type, searchKey: searchKey), successHandler: success, failureHandler: failure)
        }
        
        static func updateProfile(name: String?, email: String?, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .editProfile(name: name, email: email), successHandler: success, failureHandler: failure)
        }
        
        static func verifyEmailOtp(otp: String, email: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .verifyEmailOtp(otp: otp, email: email), successHandler: success, failureHandler: failure)
        }
        
        static func sendOtpOnMail(email: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .sendOtpOnMail(email: email), successHandler: success, failureHandler: failure)
        }
    }
}

extension WebServices {
    final class NotificationEndPoints {
        static func setNotificationPref(req: NotificationPrefRequest, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .notificationPref(req: req), successHandler: success, failureHandler: failure)
        }
    }
}
