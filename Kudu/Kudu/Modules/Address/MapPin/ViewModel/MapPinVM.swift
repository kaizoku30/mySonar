//
//  MapPinVM.swift
//  Kudu
//
//  Created by Admin on 14/07/22.
//

import Foundation
import SwiftLocation
import MapKit
import CoreLocation
import GoogleMaps

protocol MapPinVMDelegate: AnyObject {
    func currentLocationFetched(cameraPosition: GMSCameraPosition)
    func failedToFetchLocation(reason: String)
    func reverseGeocodingSuccess(trimmedAddress: String, cityStateText: String)
    func reverseGeocodingFailed(reason: String)
    
}

class MapPinVM {
    
    private weak var delegate: MapPinVMDelegate?
    private var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private var initialUserLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var getUserLocation: CLLocationCoordinate2D { initialUserLocation }
    var getCurrentCoordinates: CLLocationCoordinate2D { currentLocation }
    private var prefillData: LocationInfoModel?
    var getPrefillData: LocationInfoModel? { prefillData }
    
    init(delegate: MapPinVMDelegate, coordinates: CLLocationCoordinate2D) {
        self.delegate = delegate
        self.currentLocation = coordinates
        self.initialUserLocation = coordinates
    }
    
    func updateLocation(_ coordinates: CLLocationCoordinate2D) {
        self.currentLocation = coordinates
    }
    
    func fetchInitialPointInMap() {
        let coordinates = initialUserLocation
        let latitude = coordinates.latitude
        let longitude = coordinates.longitude
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        self.delegate?.currentLocationFetched(cameraPosition: camera)
    }
    
    func handleReverseGeocoding(lat: CLLocationDegrees, long: CLLocationDegrees) {
        let reverseGeoCoder = Geocoder.Google(lat: lat, lng: long, APIKey: Constants.GooglePaidAPIKey.apiKey)
        SwiftLocation.geocodeWith(reverseGeoCoder).then({ [weak self] (result) in
            guard let data = result.data else {
                self?.delegate?.reverseGeocodingFailed(reason: LocalizedStrings.MapPin.unableToFetchAddress)
                return }
            if data.isEmpty {
                self?.delegate?.reverseGeocodingFailed(reason: LocalizedStrings.MapPin.unableToFetchAddress)
                return }
            self?.parseReverseGeoCodeData(data[0])
        })
    }
    
    private func parseReverseGeoCodeData(_ object: GeoLocation) {
        self.prefillData = GeoLocation.parseGeoLocationObject(object)
        self.delegate?.reverseGeocodingSuccess(trimmedAddress: self.prefillData?.trimmedAddress ?? "", cityStateText: "\(self.prefillData?.city ?? ""), \(self.prefillData?.state ?? "")")
    }
}

extension GeoLocation {
    static func parseGeoLocationObject(_ object: GeoLocation) -> LocationInfoModel {
        let info = object.info
        let formattedAdddress = (info[.formattedAddress] ?? "") ?? ""
        var city = (info[.locality] ?? "") ?? ""
        if city.isEmpty {
            city = (info[.subAdministrativeArea3] ?? "") ?? ""}
        let state = (info[.administrativeArea] ?? "") ?? ""
        let trimmedAddress = formattedAdddress//applyTrimmingAlgorithm(formattedAdddress, city: city, state: state)
        let coordinates = object.coordinates
        let postalCode = (info[.postalCode] ?? "") ?? ""
        return LocationInfoModel(trimmedAddress: trimmedAddress, city: city, state: state, postalCode: postalCode, latitude: coordinates.latitude, longitude: coordinates.longitude, googleTitle: trimmedAddress, googleSubtitle: "\(city), \(state)")
    }
}
