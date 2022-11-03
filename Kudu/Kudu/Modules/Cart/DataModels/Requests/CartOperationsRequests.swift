//
//  AddCartItemRequest.swift
//  Kudu
//
//  Created by Admin on 15/09/22.
//

import Foundation

struct AddCartItemRequest {
	let itemId: String
	let menuId: String
	let hashId: String
	let storeId: String?
	let itemSdmId: Int
	let quantity: Int
	let servicesAvailable: APIEndPoints.ServicesType
	let modGroups: [ModGroup]?
    var offerdItem: Bool = false
    
	func getRequestJson() -> [String: Any] {
		let key = Constants.APIKeys.self
		var json: [String: Any] = [key.itemId.rawValue: itemId,
								   key.menuId.rawValue: menuId,
								   key.hashId.rawValue: hashId,
								   key.itemSdmId.rawValue: itemSdmId,
								   key.quantity.rawValue: quantity,
								   key.servicesAvailable.rawValue: servicesAvailable.rawValue,
                                   key.offerdItem.rawValue: offerdItem]
        if let storeId = storeId, !storeId.isEmpty {
			json[key.storeId.rawValue] = storeId
		}
		if let modGroups = modGroups {
			json[key.modGroups.rawValue] = ModGroup.getRequestJSON(modGroups: modGroups)
		}
		return json
	}
    
    func createPlaceholderCartObject(itemDetails: MenuItem) -> CartListObject {
        let object = CartListObject(_id: nil, itemId: self.itemId, menuId: self.menuId, hashId: self.hashId, isCustomised: itemDetails.isCustomised, quantity: 1, servicesAvailable: self.servicesAvailable.rawValue, itemSdmId: self.itemSdmId, storeId: self.storeId, modGroups: self.modGroups, offerdItem: self.offerdItem, itemDetails: itemDetails)
        return object
    }
	
}

struct UpdateCartCountRequest {
	let isIncrement: Bool
	let itemId: String
	let quantity: Int
	let hashId: String
	
	func getRequestJson() -> [String: Any] {
		let key = Constants.APIKeys.self
		let json: [String: Any] = [key.itemId.rawValue: itemId,
								   key.isIncrement.rawValue: isIncrement,
								   key.quantity.rawValue: quantity,
								   key.hashId.rawValue: hashId]
		return json
	}
}

struct RemoveItemFromCartRequest {
	let itemId: String
	let quantity: Int = 1
	let hashId: String
    var offeredItem: Bool = false
    
	func getRequestJson() -> [String: Any] {
		let key = Constants.APIKeys.self
		let json: [String: Any] = [key.itemId.rawValue: itemId,
								   key.quantity.rawValue: quantity,
								   key.hashId.rawValue: hashId,
                                   key.offerdItem.rawValue: offeredItem]
		return json
	}
}
