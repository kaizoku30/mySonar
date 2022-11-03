//
//  SettingEndPoints.swift
//  Kudu
//
//  Created by Admin on 15/09/22.
//

import Foundation

extension APIEndPoints {
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
        
        static func changePhoneNumber(req: ChangePhoneNumberRequest, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .changePhoneNumber(req: req), successHandler: success, failureHandler: failure)
        }
	}
}
