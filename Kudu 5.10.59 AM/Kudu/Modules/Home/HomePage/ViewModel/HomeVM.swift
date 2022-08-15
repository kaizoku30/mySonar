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
    func reverseGeocodingSuccess(trimmedAddress: String)
    func reverseGeocodingFailed(reason: String)
    func generalPromoAPIResponse(responseType: Result<String, Error>)
    func menuListAPIResponse(forSection: HomeVM.SectionType, responseType: Result<String, Error>)
}

class HomeVM {
    
    private weak var delegate: HomeVMDelegate?
    private var currentLocationData: LocationInfoModel?
    private var menuListRequest: MenuListRequest?
    private var selectedSection: SectionType = .delivery
    private let webService = WebServices.HomeEndPoints.self
    private var promoList: [GeneralPromoItem]?
    private var menuList: [MenuCategory]?
    var getCurrentLocationData: LocationInfoModel? { currentLocationData }
    var getSelectedSection: SectionType { selectedSection }
    var getPromoList: [GeneralPromoItem]? { promoList }
    var getMenuList: [MenuCategory]? { menuList }
    
    enum SectionType: String {
        case delivery
        case curbside
        case pickup
    }
    
    init(delegate: HomeVMDelegate) {
        self.delegate = delegate
    }
    
    func setLocation(_ data: LocationInfoModel) {
        self.currentLocationData = data
    }
    
    func updateSection(_ section: SectionType) {
        selectedSection = section
    }
    
    func selectMenuItem(_ index: Int) {
        guard let list = self.menuList else { return }
        if index >= list.count { return }
        let selectedIndex = list.firstIndex(where: { $0.isSelectedInApp ?? false == true }) ?? 0
        self.menuList?[selectedIndex].isSelectedInApp = false
        self.menuList?[index].isSelectedInApp = true
    }
    
    func hitPromoAPI() {
        self.promoList = nil
        webService.getGeneralPromoList(success: { [weak self] (response) in
            self?.promoList = response.data ?? []
            self?.delegate?.generalPromoAPIResponse(responseType: .success(response.message ?? ""))
        }, failure: { [weak self] (error) in
            let error = NSError(code: error.code, localizedDescription: error.msg)
            self?.delegate?.generalPromoAPIResponse(responseType: .failure(error))
        })
    }
    
    func hitMenuAPI() {
        self.menuList = nil
        var lat: Double?
        var long: Double?
        var storeId: String?
        
        if getSelectedSection == .delivery {
            if let latitude = getCurrentLocationData?.latitude, let longitude = getCurrentLocationData?.longitude {
                lat = latitude
                long = longitude
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
            self?.menuList = response.data ?? []
            self?.delegate?.menuListAPIResponse(forSection: section, responseType: .success(response.message ?? ""))
        }, failure: { [weak self] (error) in
            let error = NSError(code: error.code, localizedDescription: error.msg)
            self?.delegate?.menuListAPIResponse(forSection: section, responseType: .failure(error))
        })
    }
    
    func reverseGeoCodeCurrentCoordinates(_ coordinates: CLLocationCoordinate2D) {
        let reverseGeoCoder = Geocoder.Google(lat: coordinates.latitude, lng: coordinates.longitude, APIKey: Constants.GooglePaidAPIKey.apiKey)
        SwiftLocation.geocodeWith(reverseGeoCoder).then({ [weak self] (result) in
            guard let data = result.data else {
                self?.delegate?.reverseGeocodingFailed(reason: LocalizedStrings.Home.unableToFetchAddress)
                return }
            if data.isEmpty {
                self?.delegate?.reverseGeocodingFailed(reason: LocalizedStrings.Home.unableToFetchAddress)
                return }
            self?.parseReverseGeoCodeData(data[0])
        })
    }
    
    private func parseReverseGeoCodeData(_ object: GeoLocation) {
        self.currentLocationData = GeoLocation.parseGeoLocationObject(object)
        DataManager.shared.currentDeliveryLocation = self.currentLocationData
        self.delegate?.reverseGeocodingSuccess(trimmedAddress: self.currentLocationData?.trimmedAddress ?? "")
    }
}
