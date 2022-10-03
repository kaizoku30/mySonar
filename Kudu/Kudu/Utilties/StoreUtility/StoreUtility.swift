//
//  StoreUtility.swift
//  Kudu
//
//  Created by Admin on 03/10/22.
//

import Foundation

final class StoreUtility {
    static func checkIfAnyStoreNearby(lat: Double, long: Double, checked: @escaping (Result<StoreDetail, Error>) -> Void) {
        APIEndPoints.HomeEndPoints.getStoreDetailsForDelivery(lat: lat, long: long, servicesType: .delivery, success: {
            guard let store = $0.data else {
                checked(.failure(NSError(localizedDescription: "Could not find any store nearby")))
                return }
            checked(.success(store))
        }, failure: {
            checked(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
}
