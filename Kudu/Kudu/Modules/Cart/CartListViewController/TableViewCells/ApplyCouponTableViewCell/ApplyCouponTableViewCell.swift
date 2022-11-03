//
//  ApplyCouponTableViewCell.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import UIKit

class ApplyCouponTableViewCell: UITableViewCell {

    @IBOutlet private weak var appliedCouponView: UIView!
    @IBOutlet private weak var applyCouponView: UIView!
    
    // MARK: Applied Coupon View Outlets
    @IBOutlet private weak var appliedCouponMarker: UIImageView!
    @IBOutlet private weak var appliedCouponCode: UILabel!
    @IBOutlet private weak var appliedNotAppliedLabel: UILabel!
    @IBOutlet private weak var couponSavingsTextLabel: UILabel!
    @IBOutlet private weak var savingsLabel: UILabel!
    @IBOutlet private weak var offerNotApplicableLabel: UILabel!
    @IBOutlet private weak var removeChangeButton: AppButton!
    
    private let notApplicableText = "Not Applicable"
    private let applicableText = "applied"
    private let couponsSavingsText = "coupon savings"
    private let inValidColor = AppColors.Cart.couponInvalidColor
    private let validColor = AppColors.Cart.couponAppliedColor
    
    var openCouponVC: (() -> Void)?
    var removeCoupon: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyCouponView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToCouponsVC)))
        removeChangeButton.addTarget(self, action: #selector(removeCouponFromCart), for: .touchUpInside)
        // Initialization code
    }
    
    @objc private func removeCouponFromCart() {
        self.removeCoupon?()
    }
    
    @objc private func goToCouponsVC() {
        self.openCouponVC?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(coupon: CouponObject?, isNotValid: Bool = false) {
        guard let coupon = coupon, let promoType = PromoOfferType(rawValue: coupon.promoData?.offerType ?? "") else {
            applyCouponView.isHidden = false
            return
        }
        let savings = CartUtility.calculateSavingsAfterCoupon(obj: coupon).round(to: 2).removeZerosFromEnd()
        appliedCouponMarker.tintColor = isNotValid ? inValidColor : AppColors.kuduThemeBlue
        appliedCouponCode.text = coupon.couponCode?.first(where: { $0.status ?? "" == "notredeemed"})?.couponCode ?? ""
        appliedCouponCode.tintColor = isNotValid ? inValidColor : validColor
        let offerNotApplicableReason = CartUtility.checkCouponValidationError(coupon)?.errorMsg ?? "Offer doesn't apply on the bill"
        appliedNotAppliedLabel.text = isNotValid ? notApplicableText : applicableText
        appliedNotAppliedLabel.textColor = isNotValid ? inValidColor : .black
        savingsLabel.text = "SR " + "\(savings)"
        couponSavingsTextLabel.text = couponsSavingsText
        savingsLabel.isHidden = isNotValid
        couponSavingsTextLabel.isHidden = isNotValid
        if promoType == .item {
            savingsLabel.text = "Free item"
            couponSavingsTextLabel.text = "added in cart"
        }
        offerNotApplicableLabel.text = offerNotApplicableReason
        offerNotApplicableLabel.adjustsFontSizeToFitWidth = true
        offerNotApplicableLabel.isHidden = !isNotValid
        applyCouponView.isHidden = true
    }

}
