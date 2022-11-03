//
//  PaymentMethodVM.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import Foundation

class PaymentMethodVM {
    
    private var cards: [CardObject] = []
    var getCards: [CardObject] { cards }
    
    func getCards(fetched: @escaping ((Result<Bool, Error>) -> Void)) {
        APIEndPoints.PaymentEndPoints.getCards(success: { [weak self] in
            self?.cards = $0.data?.cards ?? []
            fetched(.success(true))
        }, failure: {
            fetched(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
    
    func makeSavedCardPayment(orderId: String, amount: Double, cvv: String, cardId: String, result: @escaping ((Result<Bool, Error>) -> Void)) {
        APIEndPoints.PaymentEndPoints.makeSavedCardPayment(orderID: orderId, amount: amount, cvv: cvv, cardId: cardId, success: { _ in
            result(.success(true))
        }, failure: {
            result(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
}
