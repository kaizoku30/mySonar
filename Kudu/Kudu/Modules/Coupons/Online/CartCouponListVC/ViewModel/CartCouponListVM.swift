//
//  CartCouponViewModel.swift
//  Kudu
//
//  Created by Admin on 26/09/22.
//

import Foundation

final class CartCouponListVM {
    private var coupons: [CouponObject] = []
    private var serviceType: APIEndPoints.ServicesType = .delivery
    var getCoupons: [CouponObject] { coupons }
    private var appliedCoupon: CouponObject?
    var getAppliedCoupon: CouponObject? { appliedCoupon }
    
    func configure(serviceType: APIEndPoints.ServicesType) {
        self.serviceType = serviceType
    }
    
    func updateAppliedCoupon(_ obj: CouponObject, completion: @escaping (((Result<Bool, Error>) -> Void))) {
        CartUtility.applyCouponToCart(obj, completionHandler: { [weak self] in
            if $0 {
                self?.appliedCoupon = obj
                completion(.success(true))
            } else {
                self?.appliedCoupon = nil
                completion(.failure(NSError(localizedDescription: "Could not apply coupon. Some error occurred")))
            }
        })
    }
    
    func fetchCoupons(fetched: @escaping () -> Void) {
        APIEndPoints.CouponEndPoints.getOnlineCouponListing(serviceType: self.serviceType, success: { [weak self] in
            self?.coupons = $0.data ?? []
            fetched()
        }, failure: { [weak self] _ in
            self?.coupons = []
            fetched()
        })
    }
    
    func fetchCouponDetail(code: String, fetched: @escaping (Result <Bool, Error>) -> Void) {
        APIEndPoints.CouponEndPoints.getCouponDetail(withCouponCode: code, success: { [weak self] in
            guard let coupon = $0.data?.data, coupon._id.isNotNil else {
                let error = NSError(code: 0, localizedDescription: "Coupon not found")
                fetched(.failure(error))
                return
            }
            let couponInvalid = CartUtility.checkCouponValidationError(coupon)
            if couponInvalid.isNil {
                self?.appliedCoupon = coupon
                CartUtility.applyCouponToCart(coupon, completionHandler: {
                    if $0 {
                        fetched(.success(true))
                    } else {
                        self?.appliedCoupon = nil
                        fetched(.failure(NSError(code: 0, localizedDescription: "Could not apply coupon. Some error occurred")))
                    }
                })
                
            } else {
                self?.appliedCoupon = nil
                let error = NSError(code: 0, localizedDescription: couponInvalid?.errorMsg ?? "")
                fetched(.failure(error))
            }
            
        }, failure: { [weak self] in
            self?.appliedCoupon = nil
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            fetched(.failure(error))
        })
    }
}
