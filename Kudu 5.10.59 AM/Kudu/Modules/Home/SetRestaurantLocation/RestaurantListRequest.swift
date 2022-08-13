//
//  RestaurantListRequest.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import Foundation

struct RestaurantListRequest {
    let searchKey: String?
    let latitude: Double
    let longitude: Double
    let type: HomeVM.SectionType
}
