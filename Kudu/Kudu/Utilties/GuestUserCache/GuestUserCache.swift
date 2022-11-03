//
//  GuestUserCache.swift
//  Kudu
//
//  Created by Admin on 27/10/22.
//

import UIKit

final class GuestUserCache {
    static let shared = GuestUserCache()
    private init() { }
    
    enum ActionType {
        case favourite(req: FavouriteRequest)
        case addToCart(req: AddCartItemRequest) //Make sure to check if item already exists
    }
    
    private var queuedAction: ActionType?
    
    func clearCache() {
        queuedAction = nil
    }
    
    func queueAction(_ action: ActionType) {
        self.queuedAction = action
    }
    
    func getAction() -> ActionType? {
        queuedAction
    }
    
    func addGuestUserFavourite(favouriteReq: FavouriteRequest, added: @escaping (Result<Bool, Error>) -> Void) {
        APIEndPoints.HomeEndPoints.syncHashIDsForFavourites(success: { (response) in
            let hashIds = response.data ?? []
            AppUserDefaults.save(value: response.data ?? [], forKey: .hashIdsForFavourites)
            if hashIds.contains(where: { $0 == favouriteReq.hashId }) {
                //HashId Already Exists --> Proceed with Routing
                added(.success(true))
            } else {
                DataManager.saveHashIDtoFavourites(favouriteReq.hashId)
                APIEndPoints.HomeEndPoints.hitFavouriteAPI(request: favouriteReq, success: { _ in
                    added(.success(true))
                }, failure: { (error) in
                    added(.failure(NSError(localizedDescription: error.msg)))
                })
            }
        }, failure: { (error) in
            added(.failure(NSError(localizedDescription: error.msg)))
        })
    }
    
    func addGuestCartObject(addCartReq: AddCartItemRequest, added: @escaping (Result<Bool, Error>) -> Void) {
        CartUtility.syncCart {
            let currentItems = CartUtility.fetchCart()
            if currentItems.contains(where: { $0.hashId ?? "" == addCartReq.hashId}) {
                //Update Count
                let updateCartReq = UpdateCartCountRequest(isIncrement: true, itemId: addCartReq.itemId, quantity: 1, hashId: addCartReq.hashId)
                APIEndPoints.CartEndPoints.incrementDecrementCartCount(req: updateCartReq, success: { (response) in
                    debugPrint(response)
                    added(.success(true))
                }, failure: { (error) in
                    debugPrint(error.msg)
                    added(.failure(NSError(localizedDescription: error.msg)))
                })
            } else {
                //Add Item
                // First fetch item details
                APIEndPoints.HomeEndPoints.getItemDetail(itemId: addCartReq.itemId, success: { (item) in
                    //Now add to item
                    guard let menuItem = item.data?.first else {
                        added(.failure(NSError(localizedDescription: "Could not add to cart")))
                        return
                    }
                    CartUtility.addItemToCart(addToCartReq: addCartReq, menuItem: menuItem, completion: {
                        switch $0 {
                        case .success:
                            added(.success(true))
                        case .failure(let error):
                            added(.failure(error))
                        }
                    })
                }, failure: { (error) in
                    added(.failure(NSError(localizedDescription: error.msg)))
                })
            }
        }
    }
}
