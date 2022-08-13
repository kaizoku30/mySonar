//
//  ResultsExploreMenuResponseModel.swift
//  Kudu
//
//  Created by Admin on 28/07/22.
//

import Foundation

struct ResultsExploreMenuResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: ResultsExploreMenuData?
}

struct ResultsExploreMenuData: Codable {
    let list: [MenuSearchResultItem]?
    let pageNo: Int?
    let limit: Int?
    let nextHit: Int?
    let totalRecord: Int?
}
