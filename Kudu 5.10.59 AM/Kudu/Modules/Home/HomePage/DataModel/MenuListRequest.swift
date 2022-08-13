//
//  MenuListRequest.swift
//  Kudu
//
//  Created by Admin on 24/07/22.
//

import Foundation

struct MenuListRequest {
    let servicesType: HomeVM.SectionType
    let lat: Double?
    let long: Double?
    let storeId: String?
}
