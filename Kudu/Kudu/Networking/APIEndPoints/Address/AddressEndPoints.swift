//
//  AddressEndPoints.swift
//  Kudu
//
//  Created by Admin on 15/09/22.
//

import Foundation

extension APIEndPoints {
	final class AddressEndPoints {
		static func addAddress(request: AddAddressRequest, success: @escaping SuccessCompletionBlock<AddAddressResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
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
