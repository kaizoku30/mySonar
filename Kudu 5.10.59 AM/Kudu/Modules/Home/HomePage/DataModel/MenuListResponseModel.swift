//
//  MenuListResponse.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import Foundation

struct MenuListResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [MenuCategory]?
}

struct MenuCategory: Codable {
    let titleEnglish: String?
    let _id: String?
    let menuImageUrl: String?
    let titleArabic: String?
    let itemCount: Int?
    var isSelectedInApp: Bool?
}

/*
 "titleEnglish" : "Combos",
 "_id" : "62d11b464f2f4d229cf3b473",
 "menuImageUrl" : "https:\/\/s3.eu-west-1.amazonaws.com\/solo.uploads\/15930436815ef3eae107dd9_phpxsXWu1",
 "titleArabic" : "وجبات الساندوتش",
 "itemCount" : 11,
 "id" : "62d11b464f2f4d229cf3b473"
 */
