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
    var timeForRedemption: Int = 0
    
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
    
    func fetchPromo(fetched: @escaping (() -> Void)) {
        APIEndPoints.CouponEndPoints.getInStoreCouponList(storeId: DataManager.shared.currentStoreId == "" || DataManager.shared.currentServiceType == .delivery ? nil : DataManager.shared.currentStoreId, success: { [weak self] in
            self?.coupons = $0.data ?? []
            APIEndPoints.CartEndPoints.getCartConfig(storeId: nil, success: { [weak self] in
                self?.timeForRedemption = $0.data?.redeemTimer ?? 0
                fetched()
            }, failure: { [weak self] _ in
                self?.coupons = []
                fetched()
            })
        }, failure: { [weak self] _ in
          debugPrint("failed")
            self?.coupons = []
            fetched()
        })
    }
}
