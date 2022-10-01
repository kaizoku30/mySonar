//
//  AddAddressResponseModel.swift
//  Kudu
//
//  Created by Admin on 19/09/22.
//

import Foundation

struct AddAddressResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: MyAddressListItem?
}
