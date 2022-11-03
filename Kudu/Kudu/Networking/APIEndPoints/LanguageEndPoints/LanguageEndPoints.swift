//
//  LanguageEndPoints.swift
//  Kudu
//
//  Created by Harpreet Kaur on 2022-10-26.
//

import Foundation

extension APIEndPoints {
    final class LanguageEndPoints {
        static func changeLanguage(language: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .changeDeviceLang(language: language), successHandler: success, failureHandler: failure)
        }
    }
}
