//
//  VersionCheckResponse.swift
//  Kudu
//
//  Created by Admin on 03/11/22.
//

import Foundation

struct VersionCheckResponse: Codable {
    let message: String?
    let statusCode: Int?
    let data: VersionCheckData?
}

struct VersionCheckData: Codable {
    let updateType: String?
    let _id: String?
    let currentVersion: String?
    let name: String?
    let description: String?
    let platform: String?
    
    enum UpdateAlertType: String {
        case NORMAL = "1"
        case FORCEFULLY = "2"
    }
    
    func getUpdateType() -> UpdateAlertType {
        UpdateAlertType(rawValue: updateType ?? "") ?? .NORMAL
    }
}
