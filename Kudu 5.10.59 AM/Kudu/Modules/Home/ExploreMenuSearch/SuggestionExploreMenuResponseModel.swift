//
//  SuggestionExploreMenuResponseModel.swift
//  Kudu
//
//  Created by Admin on 28/07/22.
//

import Foundation

struct SuggestionExploreMenuResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [MenuSearchResultItem]?
}

struct MenuSearchResultItem: Codable {
    let _id: String?
    let titleEnglish: String?
    let titleArabic: String?
    let isCategory: Bool?
    let isItem: Bool?
    let descriptionEnglish: String?
    let descriptionArabic: String?
    let nameEnglish: String?
    let nameArabic: String?
    let itemImageUrl: String?
    let price: Double?
    let allergicComponent: [AllergicComponent]?
    let isCustomised: Bool?
    let menuImageUrl: String?
    let itemCount: Int?
    var currentCartCountInApp: Int?
    var isLikedInApp: Bool?
    let isAvailable: Bool?
}
