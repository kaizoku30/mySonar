//
//  CouponEndPoints.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import Foundation

extension APIEndPoints {
    final class CouponEndPoints {
        static func getOnlineCouponListing(serviceType: ServicesType, success: @escaping SuccessCompletionBlock<CouponListingResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .getOnlineCouponListing(serviceType: serviceType), successHandler: success, failureHandler: failure)
        }
        
        static func updateCouponOnCart(apply: Bool, couponId: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .updateCouponOnCart(apply: apply, couponId: couponId), successHandler: success, failureHandler: failure)
        }
        
        static func getCouponDetail(id: String, success: @escaping SuccessCompletionBlock<CouponDetailResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .getCouponDetail(id: id), successHandler: success, failureHandler: failure)
        }
        
        static func getCouponDetail(withCouponCode code: String, success: @escaping SuccessCompletionBlock<CouponCodeBasedDetailResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .getCouponCodeDetail(couponCode: code), successHandler: success, failureHandler: failure)
        }
        
        static func getAllStoresFilteredBy(excludedStores: [String], pageNo: Int, searchKey: String?, success: @escaping SuccessCompletionBlock<SelectedStoresResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .selectedRestaurantList(exclude: excludedStores, pageNo: pageNo, searchKey: searchKey), successHandler: success, failureHandler: failure)
        }
    }
}
