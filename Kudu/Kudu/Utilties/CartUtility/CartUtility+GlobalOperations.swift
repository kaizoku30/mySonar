//
//  CartUtility+GlobalOperations.swift
//  Kudu
//
//  Created by Admin on 03/10/22.
//

import Foundation

extension CartUtility {
    
    static func addItemToCart(addToCartReq: AddCartItemRequest, menuItem: MenuItem) {
        CartUtility.addItemToCart(addToCartReq.createPlaceholderCartObject(itemDetails: menuItem))
        APIEndPoints.CartEndPoints.addItemToCart(req: addToCartReq, success: { (response) in
            guard let cartItem = response.data else { return }
            debugPrint(response)
            var copy = cartItem
            copy.itemDetails = menuItem
            CartUtility.mapObjectWithPlaceholder(copy)
        }, failure: { (error) in
            debugPrint(error.msg)
        })
    }
    
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
    
    static func removeItemFromCart(menuItem: MenuItem, hashId: String) {
        guard let itemId = menuItem._id else { return }
        let removeCartReq = RemoveItemFromCartRequest(itemId: itemId, hashId: hashId)
        CartUtility.removeItemFromCart(hashId)
        APIEndPoints.CartEndPoints.removeItemFromCart(req: removeCartReq, success: { (response) in
            debugPrint(response)
        }, failure: { (error) in
            debugPrint(error.msg)
        })
    }
}
