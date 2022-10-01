//
//  GoogleAutoCompleteVM.swift
//  Kudu
//
//  Created by Admin on 15/07/22.
//

import Foundation
import SwiftLocation

protocol GoogleAutoCompleteVMDelegate: AnyObject {
    func autoCompleteAPIResponse(responseType: Result<String, Error>)
    func detailAPIResponse(responseType: Result<String, Error>)
    func myAddressListResponse(responseType: Result<String, Error>)
}

class GoogleAutoCompleteVM {
    weak var delegate: GoogleAutoCompleteVMDelegate?
    var getList: AutocompleteRequest.ProducedData { listMatches }
    var getPrefillData: LocationInfoModel? { prefillData }
    var getFlow: FlowType { flow }
    var isFetchingAddressList: Bool { fetchingAddressList }
    var getMyAddressList: [MyAddressListItem] { myAddressList }
    var getRecentlySearchAddress: [LocationInfoModel] { DataManager.shared.fetchRecentSearchesForDeliveryLocation() }
    private var fetchingAddressList: Bool = false
    private var myAddressList: [MyAddressListItem] = []
    private var detailMatch: GeoLocation?
    private var listMatches: AutocompleteRequest.ProducedData = []
    private var prefillData: LocationInfoModel?
    private var flow: FlowType = .myAddress
    
    enum FlowType {
        case myAddress
        case setDeliveryLocation
    }
    
    init(delegate: GoogleAutoCompleteVMDelegate, flow: FlowType = .myAddress, prefillData: LocationInfoModel? = nil) {
        self.delegate = delegate
        self.flow = flow
        self.prefillData = prefillData
    }
    
    func hitGoogleAutocomplete(_ textQuery: String) {
        let service = Autocomplete.Google(partialMatches: textQuery)
        service.APIKey = Constants.GooglePaidAPIKey.apiKey
        service.countries = ["in", "sa"]
        SwiftLocation.autocompleteWith(service).then({ [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let data):
                strongSelf.listMatches = data
                strongSelf.delegate?.autoCompleteAPIResponse(responseType: .success(""))
            case .failure(let error):
                strongSelf.listMatches = []
                strongSelf.delegate?.autoCompleteAPIResponse(responseType: .failure(error))
            }
        })
    }
    
    func hitDetailAPI(partialMatch: PartialAddressMatch) {
        guard let detailService = Autocomplete.Google(detailsFor: partialMatch) else {
            return
        }
        let reverseGeoCodeID = partialMatch.id
        detailService.APIKey = Constants.GooglePaidAPIKey.apiKey
        detailService.operation = .addressDetail(reverseGeoCodeID)
        SwiftLocation.autocompleteWith(detailService).then({ [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let data):
                guard let detailMatch = data[0].place else {
                    return
                }
                strongSelf.detailMatch = detailMatch
                strongSelf.parseReverseGeoCodeData(detailMatch, title: partialMatch.title, subtitle: partialMatch.subtitle)
            case .failure(let error):
                strongSelf.detailMatch = nil
                strongSelf.delegate?.detailAPIResponse(responseType: .failure(error))
            }
        })
    }
    
    func clearData() {
        self.listMatches = []
    }
    
    private func parseReverseGeoCodeData(_ object: GeoLocation, title: String, subtitle: String) {
        self.prefillData = GeoLocation.parseGeoLocationObject(object)
        self.prefillData?.googleTitle = title
        self.prefillData?.googleSubtitle = subtitle
        self.delegate?.detailAPIResponse(responseType: .success(""))
    }
}

extension GoogleAutoCompleteVM {
    func getAddressList() {
        
        if AppUserDefaults.value(forKey: .loginResponse).isNil {
            self.fetchingAddressList = false
            self.myAddressList = []
            self.delegate?.myAddressListResponse(responseType: .success(""))
            return
        }
        
        fetchingAddressList = true
        APIEndPoints.AddressEndPoints.getAddressList(success: { [weak self] in
            self?.fetchingAddressList = false
			self?.myAddressList = ($0.data ?? []).sorted(by: { (first, _) in first.isDefault ?? false == true })
            self?.delegate?.myAddressListResponse(responseType: .success($0.message ?? ""))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.myAddressListResponse(responseType: .failure(error))
        })
    }
}
