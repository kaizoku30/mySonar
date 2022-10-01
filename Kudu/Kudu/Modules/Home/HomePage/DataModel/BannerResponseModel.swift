//
//  BannerResponseModel.swift
//  Kudu
//
//  Created by Admin on 24/07/22.
//

import Foundation

struct BannerResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [BannerItem]?
}

struct BannerItem: Codable {
    let _id: String?
    let typeOfRedirection: String?
    let imageArUrl: String?
    let titleArabic: String?
    let titleEnglish: String?
    let servicesAvailable: String?
    let categoryId: String?
    let imageEnUrl: String?
    let itemId: String?
    let url: String?
}
