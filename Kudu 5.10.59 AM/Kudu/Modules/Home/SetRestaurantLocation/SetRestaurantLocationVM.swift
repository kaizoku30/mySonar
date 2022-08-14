//
//  SetRestaurantLocationVM.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit
import CoreLocation

protocol SetRestaurantLocationVMDelegate: AnyObject {
    func suggestionsAPIResponse(responseType: Result<String, Error>)
    func listingAPIResponse(responseType: Result<String, Error>)
}

class SetRestaurantLocationVM {
    
    weak var delegate: SetRestaurantLocationVMDelegate?
    var getSuggestions: [RestaurantListItem] { suggestions }
    var getFlow: HomeVM.SectionType { flow }
    var getList: [RestaurantListItem] { list }
    var getLocation: CLLocationCoordinate2D { location }
    private var list: [RestaurantListItem] = []
    private var suggestions: [RestaurantListItem] = []
    private var flow: HomeVM.SectionType = .pickup
    private let webService = WebServices.HomeEndPoints.self
    private var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    init(delegate: SetRestaurantLocationVMDelegate, flow: HomeVM.SectionType = .pickup) {
        self.delegate = delegate
        self.flow = flow
    }
    
    func clearData() {
        self.list = []
        self.suggestions = []
    }
    
    func updateLocation(_ location: CLLocationCoordinate2D) {
        self.location = location
    }
    
    func fetchSuggestions(text: String) {
        self.suggestions = []
        webService.getRestaurantSuggestions(request: RestaurantListRequest(searchKey: text, latitude: location.latitude, longitude: location.longitude, type: flow), success: { [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.suggestions = response.data ?? []
            strongSelf.delegate?.suggestionsAPIResponse(responseType: .success(response.message ?? ""))
            
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.suggestionsAPIResponse(responseType: .failure(error))
        })
    }
    
    func fetchResults(text: String) {
        self.list = []
        webService.getRestaurantListing(request: RestaurantListRequest(searchKey: text, latitude: location.latitude, longitude: location.longitude, type: flow), success: { [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.list = (response.data?.list) ?? []
            strongSelf.delegate?.listingAPIResponse(responseType: .success(response.message ?? ""))
            
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.listingAPIResponse(responseType: .failure(error))
        })
    }
}
