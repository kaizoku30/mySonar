//
//  FavouriteRequest.swift
//  Kudu
//
//  Created by Admin on 25/08/22.
//

import Foundation

struct FavouriteRequest {
    let itemId: String
    let hashId: String
    let menuId: String
    let itemSdmId: Int
    let isFavourite: Bool
    let servicesAvailable: APIEndPoints.ServicesType
    let modGroups: [ModGroup]?
    
    func getRequestJson() -> [String: Any] {
        let key = Constants.APIKeys.self
        var json: [String: Any] = [key.itemId.rawValue: itemId,
                                   key.hashId.rawValue: hashId,
                                   key.menuId.rawValue: menuId,
                                   key.itemSdmId.rawValue: itemSdmId,
                                   key.isFavourite.rawValue: isFavourite,
                                   key.servicesAvailable.rawValue: servicesAvailable.rawValue]
        if let modGroups = modGroups, !modGroups.isEmpty {
            json[Constants.APIKeys.modGroups.rawValue] = ModGroup.getRequestJSON(modGroups: modGroups)
        }
        return json
    }
}
