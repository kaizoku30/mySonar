//
//  AddAddressRequest.swift
//  Kudu
//
//  Created by Admin on 14/07/22.
//

import Foundation

struct AddAddressRequest {
    let addressLabel: WebServices.AddressLabelType
    let otherAddressLabel: String?
    let name: String
    let stateName: String
    let cityName: String
    let phoneNumber: String?
    let countryCode: String = "966"
    let zipCode: String
    let buildingName: String
    let landmark: String?
    let isDefault: Bool
    let latitude: Double
    let longitude: Double
    
    func getRequestJson() -> [String: Any] {
        let key = Constants.APIKeys.self
        var json: [String: Any] = [key.addressLabel.rawValue: addressLabel.rawValue,
                                   key.name.rawValue: name,
                                   key.stateName.rawValue: stateName,
                                   key.cityName.rawValue: cityName,
                                   key.countryCode.rawValue: countryCode,
                                   key.zipCode.rawValue: zipCode,
                                   key.buildingName.rawValue: buildingName,
                                   key.isDefault.rawValue: isDefault,
                                   key.latitude.rawValue: latitude,
                                   key.longitude.rawValue: longitude]
        if let otherAddressLabel = otherAddressLabel, otherAddressLabel.isEmpty == false {
            json[key.otherAddressLabel.rawValue] = otherAddressLabel
        }
        if let phoneNumber = phoneNumber, phoneNumber.isEmpty == false {
            json[key.phoneNumber.rawValue] = phoneNumber
        }
        
        if let landmark = landmark, landmark.isEmpty == false {
            json[key.landmark.rawValue] = landmark
        }
        return json
    }
}
