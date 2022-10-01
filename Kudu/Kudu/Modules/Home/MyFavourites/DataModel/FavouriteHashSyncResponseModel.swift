//
//  FavouriteHashSyncResponseModel.swift
//  Kudu
//
//  Created by Admin on 25/08/22.
//

import Foundation

struct FavouriteHashSyncResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [String]?
}
