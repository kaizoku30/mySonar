//
//  AppUserDefaults.swift
//  Kudu
//
//  Created by Admin on 02/05/22.
//

import Foundation
import SwiftyJSON
import SwiftLocation
import GoogleSignIn
import FBSDKLoginKit

class AppUserDefaults {
    
    static func value(forKey key: Key) -> Any? {
        guard let value = UserDefaults.standard.object(forKey: key.rawValue) else {
            return nil
        }
        return value
    }
    
    static func value(forUniqueKey key: String) -> Any? {
        guard let value = UserDefaults.standard.object(forKey: key) else {
            return nil
        }
        return value
    }
    
    static func save(value: Any, forKey key: Key) {
        
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func saveWithUniqueKey(value: Any, forKey key: String) {
        
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func removeValue(forKey key: Key) {
        
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func removeValue(forUniqueKey key: String) {
        
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func removeAllValues() {
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        UserDefaults.standard.synchronize()
    }
    
    static func removeGuestUserData() {
        DataManager.shared.currentCartConfig = nil
    }
    
    static func removeUserData() {
        let fbLoginManager = LoginManager()
        fbLoginManager.logOut()
        GIDSignIn.sharedInstance.signOut()
        AppUserDefaults.removeValue(forKey: .cart)
        AppUserDefaults.removeValue(forKey: .hashIdsForFavourites)
        AppUserDefaults.removeValue(forKey: .recentSearchDeliveryLocation)
        AppUserDefaults.removeValue(forKey: .recentSearchExploreMenu)
        AppUserDefaults.removeValue(forKey: .currentDeliveryAddress)
        AppUserDefaults.removeValue(forKey: .currentCurbsideRestaurant)
        AppUserDefaults.removeValue(forKey: .currentPickupRestaurant)
        AppUserDefaults.removeValue(forKey: .loginResponse)
        AppUserDefaults.removeValue(forKey: .cartConfig)
        DataManager.shared.loginResponse = nil
        DataManager.shared.currentDeliveryLocation = nil
        DataManager.shared.currentPickupRestaurant = nil
        DataManager.shared.currentCurbsideRestaurant = nil
        DataManager.shared.currentCartConfig = nil
    }
}

extension AppUserDefaults {

    static func selectedLanguage() -> Language {
        let rawVal = AppUserDefaults.value(forKey: .selectedLanguage) as? String ?? ""
        return rawVal == Language.en.rawValue ? .en : .ar
    }
}

extension AppUserDefaults {
    
    enum Key: String {
        case selectedLanguage
        case loginResponse
        case cameraPermissionAsked
        case galleryPermissionAsked
        case recentSearchDeliveryLocation
        case recentSearchExploreMenu
        case locationAccessRequested
        case currentDeliveryAddress
        case currentCurbsideRestaurant
        case currentPickupRestaurant
        case hashIdsForFavourites
		case cart
        case cartConfig
        case recentlySkippedVersion
    }
    
    enum Language: String {
        case en
        case ar
    }
    
}
