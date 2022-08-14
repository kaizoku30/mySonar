//
//  AddNewAddressVM.swift
//  Kudu
//
//  Created by Admin on 13/07/22.
//

import Foundation

protocol AddNewAddressVMDelegate: AnyObject {
    func saveAddressAPIResponse(responseType: Result<String, Error>)
}

class AddNewAddressVM {
    private weak var delegate: AddNewAddressVMDelegate?
    private var form = AddAddressForm()
    private let webService = WebServices.AddressEndPoints.self
    private var forcedDefault: Bool = false
    private var editObject: MyAddressListItem?
    private var defaultIdToReplace: String?
    var isForcedDefault: Bool { forcedDefault }
    var formData: AddAddressForm { form }
    var getEditObject: MyAddressListItem? { editObject }
    var getDefaultAddressIdToReplace: String? { defaultIdToReplace }
    
    init(_delegate: AddNewAddressVMDelegate, editObject: MyAddressListItem? = nil, forcedDefault: Bool, defaultIdToReplace: String? = nil) {
        self.delegate = _delegate
        self.forcedDefault = forcedDefault
        if forcedDefault {
            updateForm(.isDefault(true))
        }
        self.editObject = editObject
        if editObject.isNotNil {
            self.form.updateWithAddressItem(self.editObject!)
        }
        self.defaultIdToReplace = defaultIdToReplace
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
            self.delegate?.saveAddressAPIResponse(responseType: .success($0.message ?? ""))
        }, failure: {
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self.delegate?.saveAddressAPIResponse(responseType: .failure(error))
        })
    }
    
    func editAddress() {
        guard let request = form.convertToRequest(), let addressId = self.editObject?.id else { return }
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
}
