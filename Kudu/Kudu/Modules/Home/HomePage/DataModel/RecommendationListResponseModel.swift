//
//  RecommendationListResponse.swift
//  Kudu
//
//  Created by Admin on 28/09/22.
//

import Foundation

struct RecommendationListResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [RecommendationObject]?
}

struct RecommendationObject: Codable {
    let servicesAvailable: String?
    let itemId: Int?
    let _id: String?
    let status: String?
    let image: String?
    let item: [MenuItem]?
}
