//
//  CartEndPoints.swift
//  Kudu
//
//  Created by Admin on 15/09/22.
//

import Foundation

extension APIEndPoints {
	final class CartEndPoints {
		static func addItemToCart(req: AddCartItemRequest, success: @escaping SuccessCompletionBlock<CartOperationResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .addItemToCart(req: req), successHandler: success, failureHandler: failure)
		}
		
		static func incrementDecrementCartCount(req: UpdateCartCountRequest, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .updateCartQuantity(req: req), successHandler: success, failureHandler: failure)
		}
		
		static func removeItemFromCart(req: RemoveItemFromCartRequest, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .removeItemFromCart(req: req), successHandler: success, failureHandler: failure)
		}
		
        static func syncCart(storeId: String?, success: @escaping SuccessCompletionBlock<CartListResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .syncCart(storeId: storeId), successHandler: success, failureHandler: failure)
		}
		
		static func getCartConfig(storeId: String?, success: @escaping SuccessCompletionBlock<CartConfigResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .getCartConfig(storeId: storeId), successHandler: success, failureHandler: failure)
		}
		
		static func syncCancellationPolicy(success: @escaping SuccessCompletionBlock<CancellationPolicyResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .cancellationPolicy, successHandler: success, failureHandler: failure)
		}
		
		static func getYouMayAlsoLikeList(servicesType: APIEndPoints.ServicesType, success: @escaping SuccessCompletionBlock<YouMayAlsoLikeResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .youMayAlsoLike(serviceType: servicesType), successHandler: success, failureHandler: failure)
		}
		
		static func clearCart(success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
			Api.requestNew(endpoint: .clearCart, successHandler: success, failureHandler: failure)
		}
        
        static func updateVehicleDetails(updateReq: VehicleUpdateRequest, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .updateVehicle(req: updateReq), successHandler: success, failureHandler: failure)
        }
        
        static func placeOrder(success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .clearCart, successHandler: success, failureHandler: failure)
        }
		
	}
}
