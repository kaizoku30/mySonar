//
//  CartOperationResponse.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import Foundation

struct CartOperationResponseModel: Codable {
	let message: String?
	let statusCode: Int?
	let data: CartListObject?
}
