//
//  MyAddressVM.swift
//  Kudu
//
//  Created by Admin on 14/07/22.
//

import Foundation

protocol MyAddressVMDelegate: AnyObject {
    func addressAPIResponse(responseType: Result<String, Error>)
    func deleteAddressAPIResponse(responseType: Result<String, Error>)
    func doesNotDeliverToThisLocation()
}

class MyAddressVM {
    private weak var delegate: MyAddressVMDelegate?
    private let webService = APIEndPoints.AddressEndPoints.self
    var getList: [MyAddressListItem] { otherAddresses }
    var getDefaultAddress: MyAddressListItem? { defaultAddress }
    private var defaultAddress: MyAddressListItem?
    private var otherAddresses: [MyAddressListItem] = []
    private var pickingAddressForCart = false
    var isCartFlow: Bool { pickingAddressForCart }
    private var storeForCart: StoreDetail?
    var getStoreForCart: StoreDetail? { storeForCart }
    
    init(_delegate: MyAddressVMDelegate) {
        self.delegate = _delegate
    }
    
    func configureForCartFlow() {
        pickingAddressForCart = true
    }
    
    func getAddressList() {
        webService.getAddressList(success: { [weak self] in
            let list = $0.data
            self?.defaultAddress = (list?.filter({ ($0.isDefault ?? false) == true }))?.first
            self?.otherAddresses = (list?.filter({ ($0.isDefault ?? false) == false })) ?? []
            self?.delegate?.addressAPIResponse(responseType: .success($0.message ?? ""))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.addressAPIResponse(responseType: .failure(error))
        })
    }
    
    func deleteAddress(id: String) {
        webService.deleteAddress(id: id, success: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.deleteAddressAPIResponse(responseType: .success($0.message ?? ""))
        }, failure: { [weak self] in
            guard let strongSelf = self else { return }
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            strongSelf.delegate?.deleteAddressAPIResponse(responseType: .failure(error))
        })
    }
    
    func checkIfAnyStoreNearby(lat: Double, long: Double, validAddress: ((StoreDetail) -> Void)?) {
        StoreUtility.checkIfAnyStoreNearby(lat: lat, long: long, checked: {
            switch $0 {
            case .success(let store):
                self.storeForCart = store
                validAddress?(store)
            case .failure:
                self.delegate?.doesNotDeliverToThisLocation()
            }
        })
    }
    
}
