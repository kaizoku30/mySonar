//
//  MyOffersVM.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import Foundation

class MyOffersVM {
    private var coupons: [CouponObject] = []
    var getCoupons: [CouponObject] { coupons }
    
    func fetchCoupons(fetched: @escaping (() -> Void)) {
        APIEndPoints.CouponEndPoints.getOnlineCouponListing(serviceType: DataManager.shared.currentServiceType, success: { [weak self] in
            self?.coupons = $0.data ?? []
            fetched()
        }, failure: { [weak self] _ in
          debugPrint("failed")
            self?.coupons = []
            fetched()
        })
    }
}
