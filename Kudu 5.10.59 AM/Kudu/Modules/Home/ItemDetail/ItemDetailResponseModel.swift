//
//  ItemDetailResponseModel.swift
//  Kudu
//
//  Created by Admin on 28/07/22.
//

import Foundation

struct ItemDetailResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [MenuItem]?
}
