//
//  CouponDetailPopUpVM.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import Foundation

class CouponDetailPopUpVM {
    
    private var coupon: CouponObject!
    var getCoupon: CouponObject { coupon }
    
    func configure(coupon: CouponObject) {
        self.coupon = coupon
    }
    
    func hitRedeemCoupon(couponId: String, promoId: String, couponCode: String, fetched: @escaping (() -> Void), error: @escaping ((Int) -> Void)) {
        APIEndPoints.CouponEndPoints.redeemInStoreCoupon(couponId: couponId, promoId: promoId, couponCode: couponCode) { _ in
            fetched()
        } failure: { (errorObj) in
            error(errorObj.code)
        }
    }
    
    func fetchCouponDetail(fetched: @escaping (Result<Bool, Error>) -> Void) {
        APIEndPoints.CouponEndPoints.getInStoreCouponDetails(id: coupon._id ?? "", success: { [weak self] in
            guard let updated = $0.data?.first else {
                fetched(.failure(NSError(localizedDescription: "Could not fetch coupon details.")))
                return
            }
            self?.coupon = updated
            fetched(.success(true))
        }, failure: {
            fetched(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
}
