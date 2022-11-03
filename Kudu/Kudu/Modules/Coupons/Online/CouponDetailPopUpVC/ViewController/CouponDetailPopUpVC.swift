//
//  CouponDetailPopUpVC.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import UIKit

class CouponDetailPopUpVC: BaseVC {

    @IBOutlet private weak var baseView: CouponDetailPopUpView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tblViewHeight: NSLayoutConstraint!
   
    let viewModel = CouponDetailPopUpVM()
    var controllerType: MyOffersVCType = .myoffer
    var redeemTime: Int = 0
    private var viewSet = false
    var dimissPopUp: ((CouponObject?) -> Void)?
    private var inStoreRedeemed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.baseView.minutes = self.redeemTime
        self.baseView.delegate = self
        tblView.roundTopCorners(cornerRadius: 32)
        tblView.showsVerticalScrollIndicator = false
        tblView.backgroundColor = .white
        self.setHeight()
        self.tblView.scrollToBottom()
        baseView.handleViewActions = { [weak self] in
            guard let strongSelf = self else { return }
            if $0 == .dismiss {
                if strongSelf.controllerType == .promo {
                    if strongSelf.inStoreRedeemed == false {
                        self?.dimissPopUp?(nil)
                        return
                    }
                    strongSelf.baseView.showInStoreDismissConfirmation {
                        strongSelf.baseView.timer?.invalidate()
                        strongSelf.dimissPopUp?(nil)
                    }
                } else {
                    strongSelf.dimissPopUp?(nil)
                }
            }
            if $0 == .redeem {
                if strongSelf.controllerType == .myoffer {
                    strongSelf.redeemCoupon()
                } else {
                    let redeemableCoupon = self?.viewModel.getCoupon.couponCode?.first(where: { $0.status ?? "" == "notredeemed"})
                    self?.baseView.updateQRImage(couponCode: redeemableCoupon?.couponCode ?? "")
                    strongSelf.hitRedeemCoupon()
                }
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
    
    func setHeight() {
        if let headerView = tblView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            headerFrame.size.height = height
            let fixedHeight = self.view.frame.height - 150
            if height > fixedHeight {
                self.tblViewHeight.constant = fixedHeight
            } else {
                self.tblViewHeight.constant = height
            }
            headerView.frame = headerFrame
            tblView.tableHeaderView = headerView
            self.view.layoutSubviews()
            print(height)
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
    
    private func hitRedeemCoupon() {
        guard let redeemableCoupon = self.viewModel.getCoupon.couponCode?.first(where: { $0.status ?? "" == "notredeemed"}) else {
            self.baseView.showError(msg: "Could not Redeem Coupon", completionBlock: { [weak self] in
                self?.isShowingToast = false
            })
            return
        }
        self.baseView.redeemButton.startBtnLoader(color: .white)
        self.viewModel.hitRedeemCoupon(couponId: self.viewModel.getCoupon._id ?? "", promoId: self.viewModel.getCoupon.promoData?._id ?? "", couponCode: redeemableCoupon.couponCode ?? "") {
            
            mainThread({
                self.inStoreRedeemed = true
                self.baseView.redeemButton.stopBtnLoader(titleColor: .white)
                NotificationCenter.postNotificationForObservers(.updateOffers)
                self.baseView.qrCodeView.isHidden = false
                self.baseView.showQRStartTimer()
                self.setHeight()
                self.tblView.scrollToBottom()
            })
            
        } error: { [weak self] (error) in
            guard let `self` = self else { return }
            mainThread {
                self.baseView.showError(msg: "Could not Redeem Coupon", completionBlock: { [weak self] in
                    self?.isShowingToast = false
                })
                if error == 400 {
                    self.refreshCouponData()
                }
            }
        }
        
    }
    
    private func refreshCouponData() {
        NotificationCenter.postNotificationForObservers(.updateOffers)
        viewModel.fetchCouponDetail(fetched: { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .success:
                mainThread {
                    self?.setHeight()
                    self?.tblView.scrollToBottom()
                    self?.baseView.setUI(strongSelf.viewModel.getCoupon)
                    self?.tblView.reloadData()
                    strongSelf.baseView.redeemButton.stopBtnLoader(titleColor: .white)
                    strongSelf.baseView.setButtonState(enabled: true)
                }
            case .failure:
                strongSelf.baseView.showError(msg: "Could not Redeem Coupon", completionBlock: { [weak self] in
                    self?.isShowingToast = false
                    strongSelf.baseView.redeemButton.stopBtnLoader(titleColor: .white)
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

extension CouponDetailPopUpVC: CouponDetailPopUpViewDelegate {
    func setTableHeight() {
        self.setHeight()
        self.baseView.validationErrorLabel.text = LocalizedStrings.CouponDetail.couponAlreadyRedeemed.localize()
    }
}
