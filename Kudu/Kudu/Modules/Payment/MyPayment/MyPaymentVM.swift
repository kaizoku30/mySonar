//
//  MyPaymentVM.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit

class MyPaymentVM {
    private var cards: [CardObject] = []
    var getCards: [CardObject] { cards }
    
    func getCards(fetched: @escaping (Result<Bool, Error>) -> Void) {
        APIEndPoints.PaymentEndPoints.getCards(success: { [weak self] in
            self?.cards = $0.data?.cards ?? []
            fetched(.success(true))
        }, failure: {
            fetched(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
    
    func deleteCard(cardId: String, done: @escaping (Result<Bool, Error>) -> Void) {
        APIEndPoints.PaymentEndPoints.deleteCard(cardId: cardId, success: { _ in
            done(.success(true))
        }, failure: {
            done(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
}
