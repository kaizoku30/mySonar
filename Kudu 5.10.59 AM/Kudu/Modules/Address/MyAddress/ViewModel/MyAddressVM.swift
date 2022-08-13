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
}

class MyAddressVM {
    private weak var delegate: MyAddressVMDelegate?
    private let webService = WebServices.AddressEndPoints.self
    var getList: [MyAddressListItem] { otherAddresses }
    var getDefaultAddress: MyAddressListItem? { defaultAddress }
    private var defaultAddress: MyAddressListItem?
    private var otherAddresses: [MyAddressListItem] = []
    init(_delegate: MyAddressVMDelegate) {
        self.delegate = _delegate
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
            guard let `self` = self else { return }
            self.delegate?.deleteAddressAPIResponse(responseType: .success($0.message ?? ""))
        }, failure: { [weak self] in
            guard let `self` = self else { return }
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self.delegate?.deleteAddressAPIResponse(responseType: .failure(error))
        })
    }
    
}
