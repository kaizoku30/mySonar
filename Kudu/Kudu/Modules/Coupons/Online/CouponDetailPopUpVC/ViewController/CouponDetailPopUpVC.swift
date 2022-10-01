//
//  CouponDetailPopUpVC.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import UIKit

class CouponDetailPopUpVC: BaseVC {
    @IBOutlet private weak var baseView: CouponDetailPopUpView!
    let viewModel = CouponDetailPopUpVM()
    private var viewSet = false
    var dimissPopUp: ((CouponObject?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.handleViewActions = { [weak self] in
            guard let strongSelf = self else { return }
            if $0 == .dismiss {
                strongSelf.dimissPopUp?(nil)
            }
            if $0 == .redeem {
                strongSelf.redeemCoupon()
            }
            if $0 == .openStoreList {
                let coupon = strongSelf.viewModel.getCoupon
                if let excludeLocations = coupon.excludeLocations, excludeLocations.isEmpty == false {
                    strongSelf.goToStoresList(excluding: excludeLocations)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !viewSet {
            baseView.setUI(viewModel.getCoupon)
            viewSet = true
        }
    }
}

extension CouponDetailPopUpVC {
    private func redeemCoupon() {
        CartUtility.applyCouponToCart(self.viewModel.getCoupon, completionHandler: { [weak self] in
            guard let strongSelf = self else { return }
            if $0 {
                // MARK: QUEUE NAVIGATION FROM HERE TO AN ITEM OR A CATEGORY
                guard let coupon = self?.viewModel.getCoupon else { return }
                self?.dimissPopUp?(coupon)
            } else {
                if strongSelf.isShowingToast {
                    return
                }
                strongSelf.isShowingToast = true
                strongSelf.baseView.showError(msg: "Could not apply coupon", completionBlock: { [weak self] in
                    self?.isShowingToast = false
                })
            }
        })
    }
}

extension CouponDetailPopUpVC {
    private func goToStoresList(excluding: [String]) {
        let vc = SelectedStoreListVC.instantiate(fromAppStoryboard: .Coupon)
        vc.viewModel.configure(exclusions: excluding)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}
