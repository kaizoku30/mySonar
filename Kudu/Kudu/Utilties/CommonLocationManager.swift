//
//  CommonLocationManager.swift
//  Kudu
//
//  Created by Admin on 13/07/22.
//

import Foundation
import SwiftLocation
import CoreLocation

class CommonLocationManager {
	
	static let shared = CommonLocationManager()
	private var currentLocation: CLLocationCoordinate2D?
	
	private init() {
	// Preserving initialisation
	}
	
	static func getLocationOfDevice(foundCoordinates: @escaping ((CLLocationCoordinate2D?) -> Void)) {
		if let location = CommonLocationManager.shared.currentLocation {
			foundCoordinates(location)
			return
		}
		SwiftLocation.gpsLocation(accuracy: .block, timeout: .immediate(2)).then({
			if $0.location.isNotNil {
				foundCoordinates($0.location?.coordinate)
			} else {
				SwiftLocation.gpsLocation(accuracy: .any, timeout: .immediate(2)).then({
					foundCoordinates($0.location?.coordinate)
				})
			}
		})
	}
	
	static func checkIfLocationServicesEnabled() -> Bool {
		return true
        CLLocationManager.locationServicesEnabled()
	}
	
	static func isLocationRequested() -> Bool {
		AppUserDefaults.value(forKey: .locationAccessRequested) as? Bool ?? false
	}
	
	static func requestLocationAccess(_ callBack: @escaping ((CLAuthorizationStatus) -> Void)) {
		SwiftLocation.requestAuthorization(completion: callBack)
	}
	
	static func isAuthorized() -> Bool {
		let locationManager = CLLocationManager()
		if #available(iOS 14.0, *) {
			switch locationManager.authorizationStatus {
			case .authorized, .authorizedAlways, .authorizedWhenInUse :
				return true
			default:
				return false
			}
		} else {
			let status = CLLocationManager.authorizationStatus()
			switch status {
			case .authorized, .authorizedAlways, .authorizedWhenInUse :
				return true
			default:
				return false
			}
		}
	}
}
