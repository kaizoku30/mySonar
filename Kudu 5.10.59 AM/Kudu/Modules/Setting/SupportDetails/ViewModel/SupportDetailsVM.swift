//
//  SupportDetailsVM.swift
//  Kudu
//
//  Created by Admin on 23/07/22.
//

import Foundation

protocol SupportDetailsVMDelegate: AnyObject {
    func supportDetailsAPIResponse(responseType: Result<String, Error>)
}

class SupportDetailsVM {
    
    var getDetailData: SupportDetailsData? { detailData }
    private var detailData: SupportDetailsData?
    weak var delegate: SupportDetailsVMDelegate?
    
    func getDetails() {
        WebServices.SettingsEndPoints.supportDetails(success: { [weak self] in
            let data = $0.data
            self?.detailData = data
            self?.delegate?.supportDetailsAPIResponse(responseType: .success($0.message ?? ""))
        }, failure: { [weak self] (error) in
            let error = NSError(code: error.code, localizedDescription: error.msg)
            self?.delegate?.supportDetailsAPIResponse(responseType: .failure(error))
        })
    }
}
