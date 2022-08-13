//
//  RestaurantSuggestionsResponseModel.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import Foundation

struct RestaurantSuggestionsResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [RestaurantListItem]?
}
