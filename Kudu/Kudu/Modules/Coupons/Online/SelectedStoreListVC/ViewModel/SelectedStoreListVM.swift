//
//  SelectedStoreListVM.swift
//  Kudu
//
//  Created by Admin on 27/09/22.
//

import Foundation

class SelectedStoreListVM {
    private var pageNo: Int = 0
    private var stores: [StoreMinDetail] = []
    private var exclusions: [String] = []
    private var total: Int = 0
    var getPageNo: Int { pageNo }
    var getStores: [StoreMinDetail] { stores }
    var getTotal: Int { total }
    
    func configure(exclusions: [String]) {
        self.exclusions = exclusions
    }
    
    func emptyStores() {
        self.stores = []
    }
    
    func fetchStores(pageNo: Int, searchKey: String, fetched: @escaping ((Result<Bool, Error>) -> Void)) {
        APIEndPoints.CouponEndPoints.getAllStoresFilteredBy(excludedStores: self.exclusions, pageNo: pageNo, searchKey: searchKey, success: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.pageNo = $0.data?.pageNo ?? 0
            if strongSelf.pageNo == 1 {
                strongSelf.stores = $0.data?.data ?? []
            } else {
                strongSelf.stores.append(contentsOf: $0.data?.data ?? [])
            }
            strongSelf.total = $0.data?.total ?? 0
            fetched(.success(true))
        }, failure: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.pageNo = 0
            strongSelf.stores = []
            strongSelf.total = 0
            fetched(.failure(NSError(code: $0.code, localizedDescription: $0.msg)))
        })
    }
}
