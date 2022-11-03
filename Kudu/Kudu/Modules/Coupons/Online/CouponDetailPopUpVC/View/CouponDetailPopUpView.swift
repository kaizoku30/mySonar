//
//  CouponDetailPopUpView.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import UIKit

protocol CouponDetailPopUpViewDelegate: AnyObject {
    func setTableHeight()
}

class CouponDetailPopUpView: UIView {
    
    @IBOutlet weak var safeAreaHeight: NSLayoutConstraint!
    @IBOutlet weak var validationLabelView: UIView!
    @IBOutlet weak var bottomActionView: UIView!
    @IBOutlet weak var lblCouponCode: UILabel!
    @IBOutlet weak var couponCodeView: UIView!
    @IBOutlet weak var qrCodeView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var validationErrorLabel: UILabel!
    @IBOutlet weak var redeemButton: AppButton!
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
        //self.stopTimer()
        self.handleViewActions?(.dismiss)
    }
    @IBAction private func redeemButtonPressed(_ sender: Any) {
        if self.redeemButton.backgroundColor == AppColors.kuduThemeYellow {
            self.redeemButton.startBtnLoader(color: .white)
            self.handleViewActions?(.redeem)
        }
    }
    weak var delegate: CouponDetailPopUpViewDelegate?
    var timer: Timer?
    private var counter: Int = 0
    var minutes: Int = 0
    private var timeRefForBackground: Date = Date()
    var handleViewActions: ((ViewActions) -> Void)?
    
    enum ViewActions {
        case dismiss
        case redeem
        case openStoreList
    }
    
    func showInStoreDismissConfirmation(dismiss: @escaping (() -> Void)) {
        mainThread {
            let popUpAlert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 0))
            popUpAlert.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: .left)
            popUpAlert.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: nil)
            popUpAlert.configure(title: "Alert", message: "Your coupon will be marked as redeemed if you close this window. Make sure to get it scanned at the store before you close or before the time gets lapsed.", leftButtonTitle: "Confirm", rightButtonTitle: LocalizedStrings.MyAddress.cancel, container: self, setMessageAsTitle: false)
            popUpAlert.handleAction = {
                if $0 == .right { return }
                dismiss()
            }
        }
    }
    
    func showQRStartTimer() {
        mainThread({
            self.safeAreaHeight.constant = 0
            self.layoutIfNeeded()
            self.bottomActionView.isHidden = true
            self.counter = self.minutes * 60
            self.redeemButton.stopBtnLoader(titleColor: AppColors.white)
            self.redeemButton.isHidden = true
            // MARK: Remove extra whitespace at the bottom
            self.startTimer()
            self.setButtonState(enabled: false)
            self.validationLabelView.isHidden = true
        })
    }
    
    func updateQRImage(couponCode: String) {
        mainThread({
            self.qrImageView.image = CommonFunctions.generateQRCode(from: couponCode)
            self.lblCouponCode.text = couponCode
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.couponCodeView.dashBorder()
        qrCodeView.isHidden = true
        couponImgView.roundTopCorners(cornerRadius: 32)
        tapGestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
        setButtonState(enabled: true)
        applicableOnStoresText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToStoreList)))
        NotificationCenter.default.addObserver(self, selector: #selector(enteredForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(movedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
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
        //self.stopTimer()
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
        couponTitleLabel.semanticContentAttribute = AppUserDefaults.selectedLanguage() == .en ? .forceLeftToRight : .forceRightToLeft
        offerInfoSubtitle1.semanticContentAttribute = AppUserDefaults.selectedLanguage() == .en ? .forceLeftToRight : .forceRightToLeft
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
            validationErrorLabel.isHidden = false
            validationErrorLabel.text = couponValidationError?.errorMsg ?? ""
        } else {
            setButtonState(enabled: true)
            validationErrorLabel.text = ""
            validationErrorLabel.isHidden = true
        }
    }
}

extension CouponDetailPopUpView {
     func setButtonState(enabled: Bool) {
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

extension CouponDetailPopUpView {
    // MARK: Handling Background/Foreground Mgmt
    @objc func movedToBackground() {
        debugPrint("Moved to background at \(Date().toString(dateFormat: Date.DateFormat.hmmazzz.rawValue))")
        timeRefForBackground = Date()
        //self.stopTimer()
    }
    
    @objc func enteredForeground() {
        debugPrint("Entered foreground at \(Date().toString(dateFormat: Date.DateFormat.hmmazzz.rawValue))")
        let timeElapsed = Date().secondsFrom(timeRefForBackground)
        if counter - timeElapsed > 0 {
            counter -= timeElapsed
            //self.startTimer()
        } else {
            counter = 0
            self.stopTimer()
        }
    }
    
    func startTimer() {
        self.timer?.invalidate()
        self.timerLabel.text = "\(self.getTime())"
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.counter != 0 {
                strongSelf.counter -= 1
                debugPrint("Counter : \(strongSelf.counter)")
                //strongSelf.minutes = strongSelf.counter/60
                strongSelf.timerLabel.text = "\(strongSelf.getTime())"
            } else {
                strongSelf.stopTimer()
            }
        })
        self.timer?.fire()
    }
    
    private func getTime() -> String {
        if counter < 10 {
            return "0:0\(counter)"
        } else if counter < 60 {
            return "0:\(counter)"
        } else {
            let minuteMark = counter/60
            let seconds = counter%60
            if seconds == 0 {
                return "\(minuteMark):00"
            } else if seconds < 10 {
                return "\(minuteMark):0\(seconds)"
            } else {
                return "\(minuteMark):\(seconds)"
            }
        }
    }
    
    func stopTimer() {
        self.safeAreaHeight.constant = 34
        self.layoutIfNeeded()
        self.bottomActionView.isHidden = false
        self.redeemButton.isHidden = false
        self.validationLabelView.isHidden = false
        self.validationErrorLabel.isHidden = false
        self.validationErrorLabel.text = "This coupon is already redeemed"
        self.qrCodeView.isHidden = true
        self.delegate?.setTableHeight()
        self.timer?.invalidate()
        
    }
}
