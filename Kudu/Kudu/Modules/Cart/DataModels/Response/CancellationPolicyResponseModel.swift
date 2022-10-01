//
//  CancellationPolicyResponseModel.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import Foundation
//description

struct CancellationPolicyResponseModel: Codable {
	let message: String?
	let statusCode: Int?
	let data: CancellationPolicyObject?
}

struct CancellationPolicyObject: Codable {
	let description: String?
}
