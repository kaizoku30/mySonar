//
//  CartUtility+CartDebugger.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import Foundation

struct CartDebugger {
    enum PrintLog {
        case cartInitialised(cartCount: Int)
        case cartSyncedWithServer(updatedCount: Int)
        case cartCleared(onServer: Bool)
        case itemAddedToCart(onServer: Bool, itemName: String, hashId: String)
        case itemUpdatedInCart(onServer: Bool, itemName: String, hashId: String, updatedCount: Int)
        case itemRemovedFromCart(onServer: Bool, itemName: String, hashId: String)
        case itemMappedWithPlaceholder(itemName: String, hashId: String)
        
        var log: String {
            switch self {
            case .cartInitialised(let cartCount):
                return "Local cart count \(cartCount)"
            case .cartSyncedWithServer(let updatedCount):
                return "Updated cart count \(updatedCount)"
            case .cartCleared(let onServer):
                return "Cart cleared \(!onServer ? "Locally" : "On Server")"
            case .itemAddedToCart(let onServer, let itemName, let hashId):
                return "\(itemName) with hashId : \(hashId), added to cart \(!onServer ? "Locally" : "On Server")"
            case .itemUpdatedInCart(let onServer, let itemName, let hashId, let updatedCount):
                return "\(itemName) with hashId : \(hashId), updated in cart (NEW COUNT = \(updatedCount)) \(!onServer ? "Locally" : "On Server")"
            case .itemRemovedFromCart(let onServer, let itemName, let hashId):
                return "\(itemName) with hashId : \(hashId), removed from cart \(!onServer ? "Locally" : "On Server")"
            case .itemMappedWithPlaceholder(let itemName, let hashId):
                return "\(itemName) has been mapped with object of hash id : \(hashId) in Local Cart"
            }
        }
    }
    
    static func log(_ type: PrintLog) {
        //let log = "CART DEBUGGER LOG : ////////////"
        //debugPrint(log)
        debugPrint("CART DEBUGGER : ===> " + type.log)
    }
}
