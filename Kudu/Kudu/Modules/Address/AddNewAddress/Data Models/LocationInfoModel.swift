//
//  PrefillDataModel.swift
//  Kudu
//
//  Created by Admin on 15/07/22.
//

import Foundation

struct LocationInfoModel: Codable {
    let trimmedAddress: String
    let city: String
    let state: String
    let postalCode: String
    let latitude: Double
    let longitude: Double
    var googleTitle: String?
    var googleSubtitle: String?
	var associatedStore: StoreDetail?
    var associatedMyAddress: MyAddressListItem?
}
