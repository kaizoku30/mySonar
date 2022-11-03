//
//  GetCardsResponse.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import Foundation
import UIKit
import Frames

struct GetCardsResponse: Codable {
    let statusCode: Int?
    let message: String?
    let data: CardData?
}

struct CardData: Codable {
    let cards: [CardObject]?
}

struct CardObject: Codable {
    let last4: String?
    let scheme: String?
    let id: String?
    let cardHolderName: String?
    
    func getCardImage() -> UIImage {
        let image = CardUtils().getImageForScheme(scheme: CardScheme(rawValue: scheme?.lowercased() ?? "") ?? .visa)
        return image
    }
}
