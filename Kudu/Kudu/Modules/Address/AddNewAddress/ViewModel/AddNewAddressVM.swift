//
//  AddNewAddressVM.swift
//  Kudu
//
//  Created by Admin on 13/07/22.
//

import Foundation

protocol AddNewAddressVMDelegate: AnyObject {
    func saveAddressAPIResponse(responseType: Result<String, Error>)
    func updateAddressInCart(address: MyAddressListItem)
    func doesNotDeliverToThisLocation()
    func noUpdateNeeded()
}

class AddNewAddressVM {
    private weak var delegate: AddNewAddressVMDelegate?
    private var form = AddAddressForm()
    private let webService = APIEndPoints.AddressEndPoints.self
    private var forcedDefault: Bool = false
    private var editObject: MyAddressListItem?
    private var prefillObject: MyAddressListItem?
    private var defaultIdToReplace: String?
    private var storeForCart: StoreDetail?
    private var noDeliveryDataFlow: Bool = false
    var isForcedDefault: Bool { forcedDefault }
    var formData: AddAddressForm { form }
    var getEditObject: MyAddressListItem? { editObject }
    var getPrefillObject: MyAddressListItem? { prefillObject }
    var getDefaultAddressIdToReplace: String? { defaultIdToReplace }
    var getStoreForCart: StoreDetail? { storeForCart }
    
    private var initialEditRequest: AddAddressRequest?
    
    init(_delegate: AddNewAddressVMDelegate, editObject: MyAddressListItem? = nil, forcedDefault: Bool, defaultIdToReplace: String? = nil) {
        self.delegate = _delegate
        self.forcedDefault = forcedDefault
        if forcedDefault {
            updateForm(.isDefault(true))
        }
        self.editObject = editObject
        if editObject.isNotNil {
            self.form.updateWithAddressItem(self.editObject!)
            initialEditRequest = form.convertToRequest()
        }
        self.defaultIdToReplace = defaultIdToReplace
    }
    
    func configurePrefill(_ object: MyAddressListItem, store: StoreDetail) {
        self.prefillObject = object
        self.storeForCart = store
        self.form.updateWithAddressItem(self.prefillObject!)
        if forcedDefault {
            updateForm(.isDefault(true))
        }
    }
    
    func configureForNoDeliveryDataOnCart() {
        noDeliveryDataFlow = true
    }
    
    func updateForm(_ type: AddAddressForm.FormEntry) {
        debugPrint("Form Updated on View Model")
        form.update(type)
    }
    
    func validateForm() -> (validForm: Bool, errorMsg: String?) {
        form.validate()
    }
    
    func saveAddress() {
        if self.editObject.isNotNil {
            self.editAddress()
            return
        }
        guard let request = form.convertToRequest() else { return }
        webService.addAddress(request: request, success: {
            debugPrint($0)
            if (self.prefillObject.isNotNil || self.noDeliveryDataFlow), let address = $0.data {
                self.delegate?.updateAddressInCart(address: address)
                return
            }
            self.delegate?.saveAddressAPIResponse(responseType: .success($0.message ?? ""))
        }, failure: {
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self.delegate?.saveAddressAPIResponse(responseType: .failure(error))
        })
    }
    
    func editAddress() {
        guard let request = form.convertToRequest(), let addressId = self.editObject?.id else { return }
        
        if request == initialEditRequest! {
            debugPrint("SAME REQUEST")
            self.delegate?.noUpdateNeeded()
            return
        }
        
        webService.editAddress(addressId: addressId, request: request, success: {
            debugPrint($0)
            self.delegate?.saveAddressAPIResponse(responseType: .success($0.message ?? ""))
        }, failure: {
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self.delegate?.saveAddressAPIResponse(responseType: .failure(error))
        })
    }
    
    func deleteAddress(id: String) {
        webService.deleteAddress(id: id, success: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.defaultIdToReplace = nil
            strongSelf.delegate?.saveAddressAPIResponse(responseType: .success($0.message ?? ""))
        }, failure: { [weak self] in
            guard let strongSelf = self else { return }
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            strongSelf.delegate?.saveAddressAPIResponse(responseType: .failure(error))
        })
    }
    
    func checkIfAnyStoreNearby(lat: Double, long: Double, validAddress: ((StoreDetail) -> Void)?) {
        StoreUtility.checkIfAnyStoreNearby(lat: lat, long: long, checked: { [weak self] in
            switch $0 {
            case .success(let store):
                self?.storeForCart = store
                validAddress?(store)
            case .failure:
                self?.delegate?.doesNotDeliverToThisLocation()
            }
        })
    }
}
