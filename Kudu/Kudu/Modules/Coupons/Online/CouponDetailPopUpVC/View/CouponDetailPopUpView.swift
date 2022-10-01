//
//  CouponDetailPopUpView.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import UIKit

class CouponDetailPopUpView: UIView {
    @IBOutlet private weak var validationErrorLabel: UILabel!
    @IBOutlet private weak var redeemButton: AppButton!
    @IBOutlet private weak var tapGestureView: UIView!
    @IBOutlet private weak var safeAreaView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var couponImgView: UIImageView!
    @IBOutlet private weak var couponTitleLabel: UILabel!
    @IBOutlet private weak var offerTypeLabel: UILabel!
    @IBOutlet private weak var offerInfoTitle1: UILabel!
    @IBOutlet private weak var offerInfoSubtitle1: UILabel!
    @IBOutlet private weak var expiryDateLabel: UILabel!
    @IBOutlet private weak var offerInfoTitle2: UILabel!
    @IBOutlet private weak var offerInfoSubtitle2: UILabel!
    @IBOutlet private weak var applicableOnStoresText: UILabel!
    @IBAction private func closeButtonPressed(_ sender: Any) {
        self.handleViewActions?(.dismiss)
    }
    @IBAction private func redeemButtonPressed(_ sender: Any) {
        if self.redeemButton.backgroundColor == AppColors.kuduThemeYellow {
            self.redeemButton.startBtnLoader(color: .white)
            self.handleViewActions?(.redeem)
        }
    }
    var handleViewActions: ((ViewActions) -> Void)?
    
    enum ViewActions {
        case dismiss
        case redeem
        case openStoreList
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        couponImgView.roundTopCorners(cornerRadius: 32)
        tapGestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
        setButtonState(enabled: true)
        applicableOnStoresText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToStoreList)))
    }
    
    @objc private func goToStoreList() {
        self.handleViewActions?(.openStoreList)
    }
    
    private func setAvailableStoreText(allAvailable: Bool) {
        let selectStore = "Applicable on selected stores"
        let allStore = "Applicable on all stores"
        if allAvailable {
            applicableOnStoresText.text = allStore
            //applicableOnStoresText.attributedText = NSAttributedString(string: allStore, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        } else {
            applicableOnStoresText.attributedText = NSAttributedString(string: selectStore, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
    }
    
    @objc private func dismissView() {
        self.handleViewActions?(.dismiss)
    }
    
    func setUI(_ coupon: CouponObject) {
        setAvailableStoreText(allAvailable: (coupon.excludeLocations ?? []).isEmpty
        )
        let language = AppUserDefaults.selectedLanguage()
        let imageString = language == .en ? coupon.imageEnglish ?? "" : coupon.imageArabic ?? ""
        couponImgView.backgroundColor = .white
        couponImgView.setImageKF(imageString: imageString, placeHolderImage: AppImages.MainImages.placeholder16x9, loader: true, loaderTintColor: AppColors.kuduThemeYellow, completionHandler: nil)
        couponTitleLabel.text = language == .en ? coupon.nameEnglish ?? "" : coupon.nameArabic ?? ""
        let promoOfferTypeString = coupon.promoData?.offerType ?? ""
        let promoOfferType = PromoOfferType(rawValue: promoOfferTypeString) ?? .item
        offerTypeLabel.text = promoOfferType.typeName
        let expiryDate = Date(timeIntervalSince1970: Double(coupon.validTo ?? 0)/1000)
        let expiryDateObject = expiryDate//expiryDate.toDate(dateFormat: Date.DateFormat.yyyyMMddTHHmmsssssZ.rawValue)
        let expiryDisplayString = expiryDateObject.toString(dateFormat: Date.DateFormat.MMMdyyyy.rawValue)
        expiryDateLabel.text = expiryDisplayString
        var discountType: DeliveryDiscountType!
        var discountedAmount: Int!
        var discountInPercentage: Int!
        var maximumDiscount: Int!
        var specialDeliveryPrice: Int!
        switch promoOfferType {
        case .discount:
            discountType = DeliveryDiscountType(rawValue: coupon.promoData?.discountType ?? "")
            switch discountType {
            case .fixedDiscount:
                discountedAmount = coupon.promoData?.discountedAmount ?? 0
                offerInfoTitle1.text = "Discount"
                offerInfoSubtitle1.text = "SR \(discountedAmount!)"
                [offerInfoTitle2, offerInfoSubtitle2].forEach({ $0.text = "" })
            case .discountPercentage:
                discountInPercentage = coupon.promoData?.discountInPercentage ?? 0
                maximumDiscount = coupon.promoData?.maximumDiscount ?? 0
                offerInfoTitle1.text = "Discount"
                offerInfoSubtitle1.text = "\(discountInPercentage!)%"
                offerInfoTitle2.text = "Max Discount"
                offerInfoSubtitle2.text = "SR \(maximumDiscount!)"
            case .none:
                break
            }
        case .item:
            offerInfoTitle1.text = "Item"
            offerInfoSubtitle1.text = "Select any one item from the store"
            offerInfoTitle2.text = ""
            offerInfoSubtitle2.text = ""
        case .freeDelivery:
            [offerInfoTitle1, offerInfoTitle2, offerInfoSubtitle1, offerInfoSubtitle2].forEach({ $0.text = "" })
        case .discountedDelivery:
            specialDeliveryPrice = coupon.promoData?.specialDeliveryPrice ?? 0
            offerInfoTitle1.text = "Discount"
            offerInfoSubtitle1.text = "\(specialDeliveryPrice!)%"
            offerInfoTitle2.text = ""
            offerInfoSubtitle2.text = ""
        }
        let couponValidationError = CartUtility.checkCouponValidationError(coupon)
        validationErrorLabel.text = ""
        if let someError = couponValidationError, someError == .timeBounds {
            setButtonState(enabled: false)
            validationErrorLabel.text = couponValidationError?.errorMsg ?? ""
        } else {
            setButtonState(enabled: true)
            validationErrorLabel.text = ""
        }
    }
}

extension CouponDetailPopUpView {
    private func setButtonState(enabled: Bool) {
        mainThread {
            self.redeemButton.backgroundColor = enabled ? AppColors.kuduThemeYellow : AppColors.unselectedButtonBg
            self.redeemButton.setTitleColor(enabled ? .white : AppColors.unselectedButtonTextColor, for: .normal)
        }
    }
    
    func showError(msg: String, completionBlock: (() -> Void)?) {
        mainThread {
            self.redeemButton.stopBtnLoader(titleColor: .white)
            let error = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            error.show(message: msg, view: self, completionBlock: completionBlock)
        }
    }
}
