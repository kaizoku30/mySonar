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
}
