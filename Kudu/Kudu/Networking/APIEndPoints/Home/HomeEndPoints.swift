//
//  HomeEndPoints.swift
//  Kudu
//
//  Created by Admin on 15/09/22.
//

import Foundation

enum BannerRedirectionType: String {
    case item
    case category
    case url
}

extension APIEndPoints {
	final class HomeEndPoints {
		static func getMenuList(request: MenuListRequest, success: @escaping SuccessCompletionBlock<MenuListResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .menuList(request: request), successHandler: success, failureHandler: failure)
		}
		
        static func getBanners(serviceType: APIEndPoints.ServicesType, success: @escaping SuccessCompletionBlock<BannerResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .banners(serviceType: serviceType), successHandler: success, failureHandler: failure)
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
		
		static func getTopSearchedCategories(type: APIEndPoints.ServicesType, success: @escaping SuccessCompletionBlock<TopSearchCategoriesResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .topSearchMenu(servicesType: type), successHandler: success, failureHandler: failure)
		}
		
        static func getSearchSuggestionsMenu(storeId: String?, searchKey: String, type: APIEndPoints.ServicesType, success: @escaping SuccessCompletionBlock<SuggestionExploreMenuResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .getSearchSuggestionsMenu(searchKey: searchKey, type: type, storeId: storeId), successHandler: success, failureHandler: failure)
		}
		
        static func getSearchResultsMenu(storeId: String?, searchKey: String, type: APIEndPoints.ServicesType, pageNo: Int, success: @escaping SuccessCompletionBlock<ResultsExploreMenuResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .getSearchResults(storeId: storeId, pageNo: pageNo, type: type, searchKey: searchKey), successHandler: success, failureHandler: failure)
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
		
		static func ourStoreListing(searchKey: String, latitude: Double, longitude: Double, success: @escaping SuccessCompletionBlock<RestaurantListResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .ourStoreListing(searchKey: searchKey, lat: latitude, long: longitude), successHandler: success, failureHandler: failure)
		}
		
		static func hitFavouriteAPI(request: FavouriteRequest, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .addFavourites(req: request), successHandler: success, failureHandler: failure)
		}
		
		static func getFavourites(pageNo: Int, limit: Int = 10, success: @escaping SuccessCompletionBlock<FavouriteListResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .favouriteItemList(pageNo: pageNo, limit: limit), successHandler: success, failureHandler: failure)
		}
		
		static func syncHashIDsForFavourites(success: @escaping SuccessCompletionBlock<FavouriteHashSyncResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .favouriteHashSync, successHandler: success, failureHandler: failure)
		}
		
		static func getStoreDetailsForDelivery(lat: Double, long: Double, servicesType: ServicesType, success: @escaping SuccessCompletionBlock<StoreDetailResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .getStoreIdForDelivery(lat: lat, long: long, serviceType: servicesType), successHandler: success, failureHandler: failure)
		}
        
        static func getRecommendations(serviceType: APIEndPoints.ServicesType, success: @escaping SuccessCompletionBlock<RecommendationListResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .getRecommendations(serviceType: serviceType), successHandler: success, failureHandler: failure)
        }
	}
}
