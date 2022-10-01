//
//  OurStoreVM.swift
//  Kudu
//
//  Created by Admin on 16/08/22.
//

import Foundation
import CoreLocation

protocol OurStoreVMDelegate: AnyObject {
    func ourStoreAPIResponse(responseType: Result<String, Error>)
}

class OurStoreVM {
    private weak var delegate: OurStoreVMDelegate!
    private var location: CLLocationCoordinate2D?
    private let webservice = APIEndPoints.HomeEndPoints.self
    private var restaurants: [RestaurantListItem] = []
    var getRestaurants: [RestaurantListItem] { restaurants }
    var getLocation: CLLocationCoordinate2D? { location }
    
    init(delegate: OurStoreVMDelegate) {
        self.delegate = delegate
    }
    
    func updateCurrentLocation(_ location: CLLocationCoordinate2D) {
        self.location = location
        self.fetchRestaurants(searchKey: "")
    }
    
    func clearData() {
        self.restaurants = []
    }
    
    func fetchRestaurants(searchKey: String) {
        guard let lat = DataManager.shared.currentRelevantLatLong.lat, let long = DataManager.shared.currentRelevantLatLong.long else { return }
        webservice.ourStoreListing(searchKey: searchKey, latitude: lat, longitude: long, success: { [weak self] in
            self?.restaurants = $0.data?.list ?? []
            self?.delegate.ourStoreAPIResponse(responseType: .success($0.message ?? ""))
        }, failure: { [weak self] in
            self?.restaurants = []
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.ourStoreAPIResponse(responseType: .failure(error))
        })
    }
}
