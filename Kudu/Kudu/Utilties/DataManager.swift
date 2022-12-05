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
    
    private init() {
        loginResponse = decodeAndFetch(LoginUserData.self, key: .loginResponse)
        currentDeliveryLocation = decodeAndFetch(LocationInfoModel.self, key: .currentDeliveryAddress)
        currentCurbsideRestaurant = decodeAndFetch(RestaurantInfoModel.self, key: .currentCurbsideRestaurant)
        currentPickupRestaurant = decodeAndFetch(RestaurantInfoModel.self, key: .currentPickupRestaurant)
        currentCartConfig = decodeAndFetch(CartConfig.self, key: .cartConfig)
        valuesInitialized = true
    }

    // MARK: Properties/Configs
    private var showingToast: Bool = false
    private var noInternetViewAdded: Bool = false
    private var launchedFromNotification = false
    private var valuesInitialized = false
    private var fcmToken: String = "123"
    private var showNotificationBell = false
    
    var loginResponse: LoginUserData? {
        didSet {
            if !valuesInitialized { return }
            encodeAndSaveObject(loginResponse, key: .loginResponse)
        }
    }
    
    var currentDeliveryLocation: LocationInfoModel? {
        didSet {
            if !valuesInitialized { return }
            encodeAndSaveObject(currentDeliveryLocation, key: .currentDeliveryAddress)
        }
    }
    
    var currentCurbsideRestaurant: RestaurantInfoModel? {
        didSet {
            if !valuesInitialized { return }
            encodeAndSaveObject(currentCurbsideRestaurant, key: .currentCurbsideRestaurant)
        }
    }
    
    var currentPickupRestaurant: RestaurantInfoModel? {
        didSet {
            if !valuesInitialized { return }
            encodeAndSaveObject(currentPickupRestaurant, key: .currentPickupRestaurant)
        }
    }
    
    var currentCartConfig: CartConfig? {
        didSet {
            if !valuesInitialized { return }
            encodeAndSaveObject(currentCartConfig, key: .cartConfig)
        }
    }
    
    var currentServiceType: APIEndPoints.ServicesType = .delivery
    
    var currentStoreId: String {
        switch self.currentServiceType {
        case .delivery:
            return self.currentDeliveryLocation?.associatedStore?._id ?? ""
        case .curbside:
            return self.currentCurbsideRestaurant?.storeId ?? ""
        case .pickup:
            return self.currentPickupRestaurant?.storeId ?? ""
        }
    }
    
    var currentRelevantLatLong: (lat: Double?, long: Double?) {
        switch self.currentServiceType {
        case .delivery:
            let lat = self.currentDeliveryLocation?.latitude
            let long = self.currentDeliveryLocation?.longitude
            return (lat, long)
        case .curbside:
            let lat = self.currentCurbsideRestaurant?.latitude
            let long = self.currentCurbsideRestaurant?.longitude
            return (lat, long)
        case .pickup:
            let lat = self.currentPickupRestaurant?.latitude
            let long = self.currentPickupRestaurant?.longitude
            return (lat, long)
        }
    }
}

extension DataManager {
    // MARK: Getters
    var fetchToken: String {
        fcmToken
    }
    
    var isUserLoggedIn: Bool {
        let loginData = self.decodeAndFetch(LoginUserData.self, key: .loginResponse)
        return loginData.isNotNil
    }
    
    var isShowingToast: Bool {
        showingToast
    }
    
    var isLaunchedFromNotification: Bool {
        launchedFromNotification
    }
    
    var isNoInternetViewAdded: Bool {
        noInternetViewAdded
    }
    
    var fetchNotificationStatus: Bool {
        showNotificationBell
    }
}

extension DataManager {
    // MARK: Setters
    func setfcmToken(token: String) {
        self.fcmToken = token
    }
    
    func setNotificationBellStatus(_ status: Bool) {
        showNotificationBell = status
    }
    
    func setLaunchedFromNotification(_ status: Bool) {
        launchedFromNotification = status
    }
    
    func setnoInternetViewAdded(_ status: Bool) {
        noInternetViewAdded = status
    }
    
    func setShowingToast(_ status: Bool) {
        showingToast = status
    }
}

extension DataManager {
    // MARK: Recently Searched Delivery Locations
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
    // MARK: HashID Favourite Management
    static func saveHashIDtoFavourites(_ hashId: String) {
        var newArray = [hashId]
        if AppUserDefaults.value(forKey: .hashIdsForFavourites).isNotNil {
            let oldArray = AppUserDefaults.value(forKey: .hashIdsForFavourites) as? [String] ?? []
            newArray.append(contentsOf: oldArray)
        }
        AppUserDefaults.save(value: newArray, forKey: .hashIdsForFavourites)
    }
    
    static func removeHashIdFromFavourites(_ hashId: String) {
        if let array = AppUserDefaults.value(forKey: .hashIdsForFavourites) as? [String] {
            var oldArray = array
            guard let firstIndex = oldArray.firstIndex(where: { $0 == hashId }) else { return }
            oldArray.remove(at: firstIndex)
            AppUserDefaults.save(value: oldArray, forKey: .hashIdsForFavourites)
        }
    }
    
    static func fetchHashIDsFromFavourites() -> [String] {
        return AppUserDefaults.value(forKey: .hashIdsForFavourites) as? [String] ?? []
    }
    
    static func syncHashIDs(completion: (() -> Void)? = nil) {
        APIEndPoints.HomeEndPoints.syncHashIDsForFavourites(success: { (response) in
            AppUserDefaults.save(value: response.data ?? [], forKey: .hashIdsForFavourites)
            completion?()
        }, failure: { _ in
            completion?()
        })
    }
}

extension DataManager {
    // MARK: Recently Searched Explore Menu
    func saveToRecentlySearchExploreMenu(_ item: MenuSearchResultItem) {
        var newArray = [item]
        if AppUserDefaults.value(forKey: .recentSearchExploreMenu).isNotNil {
            var oldArray = decodeAndFetch([MenuSearchResultItem].self, key: .recentSearchExploreMenu)
            if oldArray.isNil { return }
            if oldArray!.contains(where: { $0._id ?? "" == item._id ?? "" }) { return }
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
    // MARK: Encoding/Decoding Functions
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
	
	static func encodeAndSaveObject<T: Codable>(_ object: T, key: AppUserDefaults.Key) {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(object) {
			AppUserDefaults.save(value: encoded, forKey: key)
		}
	}
	
	static func decodeAndFetch<T: Codable>(_ type: T.Type, key: AppUserDefaults.Key) -> T? {
		guard let savedData = AppUserDefaults.value(forKey: key) as? Data else { return nil }
		let decoder = JSONDecoder()
		guard let loadedData = try? decoder.decode(T.self, from: savedData) else { return nil }
		return loadedData
	}
}
