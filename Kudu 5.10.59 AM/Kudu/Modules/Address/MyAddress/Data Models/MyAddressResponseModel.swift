//
//  MyAddressResponseModel.swift
//  Kudu
//
//  Created by Admin on 14/07/22.
//

import Foundation

struct MyAddressResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [MyAddressListItem]?
}

struct MyAddressListItem: Codable {
    var phoneNumber: String?
    var landmark: String?
    var id: String?
    var cityName: String?
    var countryCode: String?
    var isDefault: Bool?
    var stateName: String?
    var buildingName: String?
    var location: LocationData?
    var userId: String?
    var otherAddressLabel: String?
    var addressLabel: String?
    var zipCode: String?
    var status: String?
    var name: String?
    
    func convertToRequest() -> AddAddressRequest {
        let item = self
        let addressLabelEntered = WebServices.AddressLabelType(rawValue: item.addressLabel ?? "") ?? .HOME
        let name = item.name ?? ""
        let stateName = item.stateName ?? ""
        let cityName = item.cityName ?? ""
        let zipCode = item.zipCode ?? ""
        let buildingName = item.buildingName ?? ""
        let isDefault = item.isDefault ?? false
        let latitude = item.location?.latitude ?? 0.0
        let longitude = item.location?.longitude ?? 0.0
        var otherAddressLabel: String?
        if let otherAddressValue = item.otherAddressLabel, otherAddressValue.isEmpty == false {
            otherAddressLabel = otherAddressValue
        } else {
            otherAddressLabel = nil
        }
        var phoneNumber: String?
        if let phoneNumberValue = item.phoneNumber, phoneNumberValue.isEmpty == false {
            phoneNumber = phoneNumberValue
        } else {
            phoneNumber = nil
        }
        var landmark: String?
        if let landmarkValue = item.landmark, landmarkValue.isEmpty == false {
            landmark = landmarkValue
        } else {
            landmark = nil
        }
        return AddAddressRequest(addressLabel: addressLabelEntered, otherAddressLabel: otherAddressLabel, name: name, stateName: stateName, cityName: cityName, phoneNumber: phoneNumber, zipCode: zipCode, buildingName: buildingName, landmark: landmark, isDefault: isDefault, latitude: latitude, longitude: longitude)
    }
}

struct LocationData: Codable {
    var latitude: Double?
    var type: String?
    var longitude: Double?
}
