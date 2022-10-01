//
//  YouMayAlsoLikeResponseModel.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import Foundation

struct YouMayAlsoLikeResponseModel: Codable {
	let message: String?
	let statusCode: Int?
	let data: [YouMayAlsoLikeObject]?
}

struct YouMayAlsoLikeObject: Codable {
	let itemId: Int?
	let _id: String?
	let image: String?
	let itemDetails: MenuItem?
    var fetchingDetailsToAdd: Bool?
}
