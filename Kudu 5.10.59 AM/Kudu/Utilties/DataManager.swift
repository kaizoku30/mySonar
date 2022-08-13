//
//  DataManger.swift
//  Kudu
//
//  Created by Admin on 02/05/22.
//

import Foundation
import UIKit

final class DataManager {
    
    static let shared = DataManager()
    var noInternetViewAdded: Bool = false
    private var valuesInitialized = false
    
    var loginResponse: LoginUserData? {
        didSet {
            if !valuesInitialized { return }
            debugPrint("Login Response Updated")
            debugPrint("Updated Login Response: \(String(describing: loginResponse))")
            encodeAndSaveObject(loginResponse, key: .loginResponse)
        }
    }
    
    var currentDeliveryLocation: LocationInfoModel? {
        didSet {
            if !valuesInitialized { return }
            encodeAndSaveObject(loginResponse, key: .currentDeliveryAddress)
        }
    }
    
    var currentCurbsideRestaurant: RestaurantInfoModel? {
        didSet {
            if !valuesInitialized { return }
            encodeAndSaveObject(loginResponse, key: .currentCurbsideRestaurant)
        }
    }
    
    var currentPickupRestaurant: RestaurantInfoModel? {
        didSet {
            if !valuesInitialized { return }
            encodeAndSaveObject(loginResponse, key: .currentPickupRestaurant)
        }
    }
    
    private init() {
        
        loginResponse = decodeAndFetch(LoginUserData.self, key: .loginResponse)
        currentDeliveryLocation = decodeAndFetch(LocationInfoModel.self, key: .currentDeliveryAddress)
        currentCurbsideRestaurant = decodeAndFetch(RestaurantInfoModel.self, key: .currentCurbsideRestaurant)
        currentPickupRestaurant = decodeAndFetch(RestaurantInfoModel.self, key: .currentPickupRestaurant)
        valuesInitialized = true
        
    }
    
}

extension DataManager {
    
    func saveToRecentlySearchDeliveryLocation(_ data: LocationInfoModel) {
        var newArray = [data]
        if AppUserDefaults.value(forKey: .recentSearchDeliveryLocation).isNotNil {
            var oldArray = decodeAndFetch([LocationInfoModel].self, key: .recentSearchDeliveryLocation)
            if oldArray.isNil { return }
            if oldArray!.count == 5 { oldArray?.remove(at: 4) }
            newArray.append(contentsOf: oldArray!)
        }
        encodeAndSaveObject(newArray, key: .recentSearchDeliveryLocation)
    }
    
    func fetchRecentSearchesForDeliveryLocation() -> [LocationInfoModel] {
        return decodeAndFetch([LocationInfoModel].self, key: .recentSearchDeliveryLocation) ?? []
    }
}

extension DataManager {
    func saveToRecentlySearchExploreMenu(_ item: MenuSearchResultItem) {
        var newArray = [item]
        if AppUserDefaults.value(forKey: .recentSearchExploreMenu).isNotNil {
            var oldArray = decodeAndFetch([MenuSearchResultItem].self, key: .recentSearchExploreMenu)
            if oldArray.isNil { return }
            if oldArray!.count == 5 { oldArray?.remove(at: 4) }
            newArray.append(contentsOf: oldArray!)
        }
        encodeAndSaveObject(newArray, key: .recentSearchExploreMenu)
    }
    
    func fetchRecentSearchesForExploreMenu() -> [MenuSearchResultItem] {
        decodeAndFetch([MenuSearchResultItem].self, key: .recentSearchExploreMenu) ?? []
    }
}

extension DataManager {
    
    func encodeAndSaveObject<T: Codable>(_ object: T, key: AppUserDefaults.Key) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            AppUserDefaults.save(value: encoded, forKey: key)
        }
    }
    
    func decodeAndFetch<T: Codable>(_ type: T.Type, key: AppUserDefaults.Key) -> T? {
        guard let savedData = AppUserDefaults.value(forKey: key) as? Data else { return nil }
        let decoder = JSONDecoder()
        guard let loadedData = try? decoder.decode(T.self, from: savedData) else { return nil }
        return loadedData
    }
}
