//
//  HomeVM.swift
//  Kudu
//
//  Created by Admin on 20/07/22.
//

import Foundation
import CoreLocation
import SwiftLocation

protocol HomeVMDelegate: AnyObject {
    func reverseGeocodingSuccess(trimmedAddress: String, isMyAddress: Bool)
    func reverseGeocodingFailed(reason: String)
    func bannerAPIResponse(responseType: Result<String, Error>)
	func menuListAPIResponse(forSection: APIEndPoints.ServicesType, responseType: Result<String, Error>)
	func doesNotDeliverToThisLocation()
    func recommendationsAPIResponse(responseType: Result<Bool, Error>)
}

class HomeVM {
    
    private weak var delegate: HomeVMDelegate?
    private var currentLocationData: LocationInfoModel?
    private var menuListRequest: MenuListRequest?
    private var selectedSection: APIEndPoints.ServicesType = .delivery
    private let webService = APIEndPoints.HomeEndPoints.self
    private var bannerItems: [BannerItem]?
    private var recommendationList: [RecommendationObject]?
    private var menuList: [MenuCategory]?
    var getCurrentLocationData: LocationInfoModel? { currentLocationData }
    var getSelectedSection: APIEndPoints.ServicesType { selectedSection }
    var getBannerItems: [BannerItem]? { bannerItems }
    var getMenuList: [MenuCategory]? { menuList }
    var getRecommendationList: [RecommendationObject]? { recommendationList }
    
	enum LocationState {
		case servicesDisabled
		case permissionDenied
		case fetchCurrentLocation
		case requestLocationAccess
		case locationAlreadyPresent
	}
	
    init(delegate: HomeVMDelegate) {
        self.delegate = delegate
    }
    
    func setLocation(_ data: LocationInfoModel) {
        self.currentLocationData = data
    }
    
    func updateSection(_ section: APIEndPoints.ServicesType) {
        selectedSection = section
    }
    
    func hitPromoAPI() {
        self.bannerItems = nil
        webService.getBanners(serviceType: self.selectedSection, success: { [weak self] (response) in
            self?.bannerItems = response.data ?? []
            self?.delegate?.bannerAPIResponse(responseType: .success(response.message ?? ""))
        }, failure: { [weak self] (error) in
            let error = NSError(code: error.code, localizedDescription: error.msg)
            self?.delegate?.bannerAPIResponse(responseType: .failure(error))
        })
    }
    
    func hitRecommendationAPI() {
        self.recommendationList = nil
        webService.getRecommendations(serviceType: getSelectedSection, success: { [weak self] (response) in
            self?.recommendationList = response.data ?? []
            self?.delegate?.recommendationsAPIResponse(responseType: .success(true))
        }, failure: { [weak self] (error) in
            self?.delegate?.recommendationsAPIResponse(responseType: .failure(NSError(code: error.code, localizedDescription: error.msg)))
        })
    }
    
    func hitMenuAPI() {
        self.menuList = nil
        var lat: Double?
        var long: Double?
        var storeId: String?
        
        if getSelectedSection == .delivery {
			if let latitude = getCurrentLocationData?.latitude, let longitude = getCurrentLocationData?.longitude, let asscStoreId = getCurrentLocationData?.associatedStore?._id {
                lat = latitude
                long = longitude
				storeId = asscStoreId
            }
        } else if getSelectedSection == .curbside {
            let item = DataManager.shared.currentCurbsideRestaurant
            if let latitude = item?.latitude, let longitude = item?.longitude, item.isNotNil {
                lat = latitude
                long = longitude
                storeId = item?.storeId ?? ""
            }
        } else {
            let item = DataManager.shared.currentPickupRestaurant
            if let latitude = item?.latitude, let longitude = item?.longitude, item.isNotNil {
                lat = latitude
                long = longitude
                storeId = item?.storeId ?? ""
            }
        }
        let section = getSelectedSection
        webService.getMenuList(request: MenuListRequest(servicesType: section, lat: lat, long: long, storeId: storeId), success: { [weak self] (response) in
            let filterList = (response.data ?? [])
            self?.menuList = TimeRange.filterArrayOfCategories(categories: filterList)
            self?.delegate?.menuListAPIResponse(forSection: section, responseType: .success(response.message ?? ""))
        }, failure: { [weak self] (error) in
            let error = NSError(code: error.code, localizedDescription: error.msg)
            self?.delegate?.menuListAPIResponse(forSection: section, responseType: .failure(error))
        })
    }
    
	func reverseGeoCodeCurrentCoordinates(_ coordinates: CLLocationCoordinate2D, prefillData: LocationInfoModel?) {
		webService.getStoreDetailsForDelivery(lat: coordinates.latitude, long: coordinates.longitude, servicesType: selectedSection, success: { [weak self] (storeDetails) in
			if let prefillData = prefillData {
				self?.currentLocationData = prefillData
				var copy = prefillData
				copy.associatedStore = storeDetails.data
				DataManager.shared.currentDeliveryLocation = copy
                self?.syncCartConfiguration(storeId: storeDetails.data?._id ?? "")
                self?.delegate?.reverseGeocodingSuccess(trimmedAddress: prefillData.trimmedAddress, isMyAddress: prefillData.associatedMyAddress?.addressLabel.isNotNil ?? false)
			} else {
				let reverseGeoCoder = Geocoder.Google(lat: coordinates.latitude, lng: coordinates.longitude, APIKey: Constants.GooglePaidAPIKey.apiKey)
				SwiftLocation.geocodeWith(reverseGeoCoder).then({ [weak self] (result) in
					guard let data = result.data else {
						self?.delegate?.reverseGeocodingFailed(reason: LocalizedStrings.Home.unableToFetchAddress)
						return }
					if data.isEmpty {
						self?.delegate?.reverseGeocodingFailed(reason: LocalizedStrings.Home.unableToFetchAddress)
						return }
                    self?.syncCartConfiguration(storeId: storeDetails.data?._id ?? "")
					self?.parseReverseGeoCodeData(data[0], associatedStore: storeDetails.data)
				})
			}
		}, failure: { [weak self] _ in
			self?.delegate?.doesNotDeliverToThisLocation()
		})
    }
    
    func syncCartConfiguration(storeId: String) {
        CartUtility.getCartConfig(storeId: storeId, fetched: {
            DataManager.shared.currentCartConfig = $0
        })
    }
    
	private func parseReverseGeoCodeData(_ object: GeoLocation, associatedStore: StoreDetail?) {
		var copy = GeoLocation.parseGeoLocationObject(object)
		copy.associatedStore = associatedStore
		DataManager.shared.currentDeliveryLocation = copy
		self.currentLocationData = copy
        self.delegate?.reverseGeocodingSuccess(trimmedAddress: self.currentLocationData?.trimmedAddress ?? "", isMyAddress: false)
    }
	
	func handleLocationState() -> LocationState {
		let savedLocation = DataManager.shared.currentDeliveryLocation
		if savedLocation.isNil {
			if CommonLocationManager.checkIfLocationServicesEnabled() == false {
				return .servicesDisabled
			} else {
				if CommonLocationManager.isLocationRequested() {
					if CommonLocationManager.isAuthorized() == false {
						return .permissionDenied
					} else {
						return .fetchCurrentLocation
					}
				} else {
					return .requestLocationAccess
				}
			}
		} else {
			return .locationAlreadyPresent
		}
	}
	
}
