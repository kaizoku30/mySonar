//
//  SupportDetailsResponse.swift
//  Kudu
//
//  Created by Admin on 22/07/22.
//

import Foundation
/*
 "_id": "62b30027aec7df517104f6a2",
         "contactNumber": "3242342123",
         "email": "admin_kudu@yopmail.com"
 */

struct SupportDetailsResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: SupportDetailsData?
}

struct SupportDetailsData: Codable {
    let _id: String?
    let contactNumber: String?
    let email: String?
}
