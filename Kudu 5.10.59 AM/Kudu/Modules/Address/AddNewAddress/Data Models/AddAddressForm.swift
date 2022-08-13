//
//  AddAddressForm.swift
//  Kudu
//
//  Created by Admin on 14/07/22.
//

import Foundation

struct AddAddressForm {
    var addressLabel: WebServices.AddressLabelType = .HOME
    var otherAddressLabel: String?
    var name: String?
    var stateName: String?
    var cityName: String?
    var phoneNumber: String?
    var zipCode: String?
    var buildingName: String?
    var landmark: String?
    var isDefault = false
    var latitude: Double?
    var longitude: Double?
    
    enum FormEntry {
        case name(String)
        case phoneNumber(String?)
        case addressLabel(WebServices.AddressLabelType)
        case otherAddressLabel(String?)
        case stateName(String)
        case cityName(String)
        case zipCode(String)
        case buildingName(String)
        case landmark(String?)
        case isDefault(Bool)
        case latitude(Double)
        case longitude(Double)
    }
    
    mutating func update(_ type: FormEntry) {
        switch type {
        case .name(let string):
            self.name = string
        case .phoneNumber(let optional):
            self.phoneNumber = optional
        case .addressLabel(let type):
            self.addressLabel = type
        case .otherAddressLabel(let optional):
            self.otherAddressLabel = optional
        case .stateName(let string):
            self.stateName = string
        case .cityName(let string):
            self.cityName = string
        case .zipCode(let string):
            self.zipCode = string
        case .buildingName(let string):
            self.buildingName = string
        case .landmark(let optional):
            self.landmark = optional
        case .isDefault(let bool):
            self.isDefault = bool
        case .latitude(let double):
            self.latitude = double
        case .longitude(let double):
            self.longitude = double
        }
    }
    
    func validate() -> (validForm: Bool, errorMsg: String?) {
        
        guard let name = name, !name.isEmpty else {
            return (false, LocalizedStrings.AddNewAddress.pleaseEnterName)
        }
        if latitude.isNil || longitude.isNil {
            return (false, LocalizedStrings.AddNewAddress.pleaseAddLocation)
        }
        guard let stateName = stateName, !stateName.isEmpty else {
            return (false, LocalizedStrings.AddNewAddress.pleaseEnterState)
        }
        guard let cityName = cityName, !cityName.isEmpty else {
            return (false, LocalizedStrings.AddNewAddress.pleaseEnterCity)
        }
        guard let zipCode = zipCode, !zipCode.isEmpty else {
            return (false, LocalizedStrings.AddNewAddress.pleaseEnterZipcode)
        }
        guard let buildingName = buildingName, !buildingName.isEmpty else {
            return (false, LocalizedStrings.AddNewAddress.pleaseEnterBuildingName)
        }
        if addressLabel == .OTHER {
            guard let otherAddressLabel = otherAddressLabel, !otherAddressLabel.isEmpty else {
                return (false, LocalizedStrings.AddNewAddress.pleaseEnterAddressLabel)
            }
        }
        return (true, nil)
    }
    
    func convertToRequest() -> AddAddressRequest? {
        guard let name = name, let stateName = stateName, let cityName = cityName, let zipCode = zipCode, let buildingName = buildingName, let latitue = latitude, let longitude = longitude else {
            return nil
        }
        let otherAddressLabel: String? = addressLabel == .OTHER ? otherAddressLabel : nil
        return AddAddressRequest(addressLabel: addressLabel, otherAddressLabel: otherAddressLabel, name: name, stateName: stateName, cityName: cityName, phoneNumber: phoneNumber, zipCode: zipCode, buildingName: buildingName, landmark: landmark, isDefault: isDefault, latitude: latitue, longitude: longitude)
        
    }
    
    mutating func updateWithAddressItem(_ item: MyAddressListItem) {
        self.update(.name(item.name ?? ""))
        self.update(.phoneNumber(item.phoneNumber))
        self.update(.addressLabel(WebServices.AddressLabelType(rawValue: item.addressLabel ?? "") ?? .HOME))
        self.update(.otherAddressLabel(item.otherAddressLabel))
        self.update(.stateName(item.stateName ?? ""))
        self.update(.cityName(item.cityName ?? ""))
        self.update(.zipCode(item.zipCode ?? ""))
        self.update(.buildingName(item.buildingName ?? ""))
        self.update(.landmark(item.landmark ?? ""))
        self.update(.isDefault(item.isDefault ?? false))
        self.update(.latitude(item.location?.latitude ?? 0.0))
        self.update(.longitude(item.location?.longitude ?? 0.0))
    }
    
}
