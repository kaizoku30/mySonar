//
//  CartCountNotifier.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import Foundation

struct CartCountNotifier {
    let isIncrement: Bool
    let itemId: String
    let menuId: String
    let hashId: String
    let serviceType: APIEndPoints.ServicesType
    let modGroups: [ModGroup]?
    
    static func getFromUserInfo(_ hashObj: [AnyHashable: Any]) -> CartCountNotifier {
        CartCountNotifier(isIncrement: hashObj["isIncrement"] as? Bool ?? false, itemId: hashObj["itemId"] as? String ?? "", menuId: hashObj["menuId"] as? String ?? "", hashId: hashObj["hashId"] as? String ?? "", serviceType: APIEndPoints.ServicesType(rawValue: hashObj["serviceType"] as? String ?? "") ?? .delivery, modGroups: hashObj["modGroups"] as? [ModGroup] ?? nil)
    }
    
    var getUserInfoFormat: [AnyHashable: Any] {
        var params: [AnyHashable: Any] = [:]
        params["isIncrement"] = self.isIncrement
        params["itemId"] = self.itemId
        params["menuId"] = self.menuId
        params["hashId"] = self.hashId
        params["serviceType"] = self.serviceType.rawValue
        if let modGroups = modGroups, modGroups.isEmpty == false {
            params["modGroups"] = modGroups
        }
        return params
    }
}
