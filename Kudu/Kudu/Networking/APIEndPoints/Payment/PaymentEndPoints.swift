//
//  PaymentEndPoints.swift
//  Kudu
//
//  Created by Admin on 18/10/22.
//

import Foundation

enum CheckoutPaymentType: String {
    case token
    case card
    case cod
}

extension APIEndPoints {
    final class PaymentEndPoints {
        static func makeTokenPayment(request: AddCardPaymentRequest, isApplePay: Bool, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .tokenCardPayment(req: request, isApplePay: isApplePay), successHandler: success, failureHandler: failure)
        }
        
        static func makeSavedCardPayment(orderID: String, amount: Double, cvv: String, cardId: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .savedCardPayment(orderId: orderID, cardId: cardId, cvv: cvv, amount: amount), successHandler: success, failureHandler: failure)
        }
        
        static func makeCODPayment(orderID: String, amount: Double, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .codPayment(orderId: orderID, amount: amount), successHandler: success, failureHandler: failure)
        }
        
        static func getCards(success: @escaping SuccessCompletionBlock<GetCardsResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .getCards, successHandler: success, failureHandler: failure)
        }
        
        static func deleteCard(cardId: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .deleteCard(cardId: cardId), successHandler: success, failureHandler: failure)
        }
    }
}
