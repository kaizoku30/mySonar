//
//  FavouriteListResponseModel.swift
//  Kudu
//
//  Created by Admin on 19/08/22.
//

import Foundation

struct FavouriteListResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: FavouriteListData?
}

struct FavouriteListData: Codable {
    let data: [FavouriteItem]?
    let total: Int?
    let totalPage: Int?
    let nextHit: Int?
    let limit: Int?
    let filterCount: Int?
}

struct FavouriteItem: Codable {
    let _id: String?
    let itemId: String?
    let hashId: String?
    let quantity: Int?
    var modGroups: [ModGroup]?
    let itemDetails: MenuItem?
    var cartCount: Int?
    var templates: [CustomisationTemplate]?
    
    private enum CodingKeys: String, CodingKey {
        case _id, itemId, quantity, modGroups, itemDetails, cartCount, templates, hashId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try? container.decode(String?.self, forKey: ._id)
        itemId = try? container.decode(String?.self, forKey: .itemId)
        hashId = try? container.decode(String?.self, forKey: .hashId)
        quantity = try? container.decode(Int?.self, forKey: .quantity)
        modGroups = try? container.decode([ModGroup]?.self, forKey: .modGroups)
        itemDetails = try? container.decode(MenuItem?.self, forKey: .itemDetails)
        self.templates = []
        let hashIdCount = CartUtility.fetchCartLocally().first(where: { $0.hashId ?? "" == self.hashId })?.quantity ?? 0
        self.cartCount = hashIdCount
        let loopCount = self.cartCount ?? 0
        for _ in 0..<loopCount {
            templates?.append(CustomisationTemplate(modGroups: self.modGroups ?? [], hashId: self.hashId ?? "", _id: nil, cartId: nil, totalQuantity: self.quantity ?? 0))
        }
    }
}
