//
//  CartUtility+GlobalOperations.swift
//  Kudu
//
//  Created by Admin on 03/10/22.
//

import Foundation

extension CartUtility {
    
    static func addItemToCart(addToCartReq: AddCartItemRequest, menuItem: MenuItem, completion: ((Result<Bool, Error>) -> Void)? = nil) {
        
        APIEndPoints.CartEndPoints.addItemToCart(req: addToCartReq, success: { (response) in
            guard let cartItem = response.data else { return }
            debugPrint(response)
            var copy = cartItem
            copy.itemDetails = menuItem
            CartUtility.addItemToCart(copy)
            //CartUtility.mapObjectWithPlaceholder(copy)
            completion?(.success(true))
        }, failure: { (error) in
            debugPrint(error.msg)
            completion?(.failure(NSError(localizedDescription: error.msg)))
        })
    }
    
    static func updateCartCount(menuItem: MenuItem, hashId: String, isIncrement: Bool, quantity: Int, completion: ((Result<Bool, Error>) -> Void)? = nil) {
        guard let itemId = menuItem._id else { return }
        let updateCartReq = UpdateCartCountRequest(isIncrement: isIncrement, itemId: itemId, quantity: 1, hashId: hashId)
        APIEndPoints.CartEndPoints.incrementDecrementCartCount(req: updateCartReq, success: { (response) in
            CartUtility.updateCartCount(hashId, isIncrement: isIncrement)
            debugPrint(response)
            completion?(.success(true))
        }, failure: { (error) in
            debugPrint(error.msg)
            completion?(.failure(NSError(localizedDescription: error.msg)))
        })
    }
    
    static func removeItemFromCart(menuItem: MenuItem, hashId: String, completion: ((Result<Bool, Error>) -> Void)? = nil) {
        guard let itemId = menuItem._id else { return }
        let removeCartReq = RemoveItemFromCartRequest(itemId: itemId, hashId: hashId)
        APIEndPoints.CartEndPoints.removeItemFromCart(req: removeCartReq, success: { (response) in
            debugPrint(response)
            CartUtility.removeItemFromCart(hashId)
            completion?(.success(true))
        }, failure: { (error) in
            debugPrint(error.msg)
            completion?(.failure(NSError(localizedDescription: error.msg)))
        })
    }
}
