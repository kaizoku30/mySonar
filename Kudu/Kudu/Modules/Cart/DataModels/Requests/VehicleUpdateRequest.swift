//
//  VehicleUpdateRequest.swift
//  Kudu
//
//  Created by Admin on 21/09/22.
//

import Foundation

struct VehicleUpdateRequest {
    let vehicleName: String
    let vehicleNumber: String
    let colorCode: String
    
    func getRequestJSON() -> [String: Any] {
        return [Constants.APIKeys.vehicleName.rawValue: self.vehicleName,
                Constants.APIKeys.vehicleNumber.rawValue: self.vehicleNumber,
                Constants.APIKeys.colorCode.rawValue: self.colorCode]
    }
}
