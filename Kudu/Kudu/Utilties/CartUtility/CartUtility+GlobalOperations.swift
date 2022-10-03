//
//  CartUtility+GlobalOperations.swift
//  Kudu
//
//  Created by Admin on 03/10/22.
//

import Foundation

extension CartUtility {
    static func updateCartCount(menuItem: MenuItem, hashId: String, isIncrement: Bool, quantity: Int) {
        guard let itemId = menuItem._id else { return }
        let updateCartReq = UpdateCartCountRequest(isIncrement: isIncrement, itemId: itemId, quantity: 1, hashId: hashId)
        CartUtility.updateCartCount(hashId, isIncrement: isIncrement)
        APIEndPoints.CartEndPoints.incrementDecrementCartCount(req: updateCartReq, success: { (response) in
            debugPrint(response)
        }, failure: { (error) in
            CartUtility.updateCartCount(hashId, isIncrement: !isIncrement)
            debugPrint(error.msg)
        })
    }
}
