//
//  CartCouponListCell.swift
//  Kudu
//
//  Created by Admin on 26/09/22.
//

import UIKit

class CartCouponListCell: UITableViewCell {
    @IBOutlet private weak var promoCouponBtn: AppButton!
    @IBOutlet private weak var validTillDateLabel: UILabel!
    @IBOutlet private weak var couponNameLabel: UILabel!
    @IBOutlet private weak var applyButton: AppButton!
    @IBOutlet private weak var savingsLabel: UILabel!
    @IBOutlet private weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet private weak var pointerCollection: UIView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var pointerTableView: UITableView!
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    
    private var expanded = false
    private var index: Int = 0
    private var pointers: [String] = []
    
    var expandPointers: ((Int) -> Void)?
    var applyCoupon: ((Int) -> Void)?
    
    private let inValidColor = AppColors.Cart.couponInvalidColor
    private let validColor = AppColors.Coupon.couponValidLabel
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        if AppUserDefaults.selectedLanguage() == .ar {
            self.descriptionLabel.textAlignment = .right
        }
        pointerTableView.delegate = self
        pointerTableView.dataSource = self
        pointerTableView.separatorStyle = .none
        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandDetails)))
        applyButton.addTarget(self, action: #selector(applyButtonPressed), for: .touchUpInside)
    }
    
    @objc private func applyButtonPressed() {
        if self.applyButton.titleColor(for: .normal) == .white {
            self.applyButton.setTitle("", for: .normal)
            self.loader.isHidden = false
            self.loader.startAnimating()
            self.applyCoupon?(self.index)
        }
    }
    
    @objc private func expandDetails() {
        expandPointers?(self.index)
    }
    
    func configure(_ obj: CouponObject, isExpanded: Bool, index: Int) {
        self.loader.stopAnimating()
        self.index = index
        if self.index == 6 {
            debugPrint("")
        }
        self.expanded = isExpanded
        self.promoCouponBtn.setTitle(obj.couponCode?.first?.couponCode ?? "", for: .normal)
        self.pointers = obj.descriptions?.map({ $0.content ?? "" }) ?? []
        if self.pointers.count > 0 {
            setDescriptionText(english: pointers[0])
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
        if isExpanded {
            setPointerCollection()
        } else {
            collectionHeight.constant = 0
            pointerTableView.isHidden = true
        }
        let couponInvalid = CartUtility.checkCouponValidationError(obj)
        let promoType = PromoOfferType(rawValue: obj.promoData?.offerType ?? "") ?? .discount
        if let couponInvalid = couponInvalid {
            savingsLabel.textColor = inValidColor
            savingsLabel.text = couponInvalid.errorMsg
        } else {
            savingsLabel.textColor = validColor
            if promoType == .item {
                savingsLabel.text = "Get a free item on this order!"
            } else {
                savingsLabel.text = "Save SR \(CartUtility.calculateSavingsAfterCoupon(obj: obj).round(to: 2).removeZerosFromEnd()) on this order!"
            }
        }
        setButton(enabled: couponInvalid.isNil)
        let expiryDate = Date(timeIntervalSince1970: Double(obj.validTo ?? 0)/1000)
        let expiryDateObject = expiryDate//expiryDate.toDate(dateFormat: Date.DateFormat.yyyyMMddTHHmmsssssZ.rawValue)
        let expiryDisplayString = expiryDateObject.toString(dateFormat: Date.DateFormat.ddMMM.rawValue)
        self.validTillDateLabel.text = "Valid till \(expiryDisplayString)"
        self.couponNameLabel.text = AppUserDefaults.selectedLanguage() == .en ? obj.nameEnglish ?? "" : obj.nameArabic ?? ""
        
    }
    
    private func setPointerCollection() {
        var rowHeightSum: CGFloat = 0
        pointers.forEach({
            let height = $0.heightOfText(self.pointerTableView.width - 40, font: AppFonts.mulishRegular.withSize(12))
            rowHeightSum += height + 10
        })
        //let rowsHeight = CGFloat(randomPointerNumber*50)
        let zereothRow = 24.5
        pointerCollection.isHidden = false
        collectionHeight.constant = 24 + rowHeightSum + zereothRow
        pointerTableView.reloadData()
        pointerTableView.isHidden = false
        
    }
    
    private func setDescriptionText(english: String) {
        let regularText = NSMutableAttributedString(string: english)
        let trunString = self.expanded ? " . Hide details" : " . View details"
        let tappableText = NSMutableAttributedString(string: trunString)
        tappableText.addAttributes([.font: AppFonts.mulishBold.withSize(12)], range: NSRange(location: 0, length: trunString.count))
        regularText.append(tappableText)
        self.descriptionLabel.attributedText = regularText
    }
    
    private func setButton(enabled: Bool) {
        applyButton.setTitle("APPLY", for: .normal)
        applyButton.setTitleColor(enabled ? .white : AppColors.unselectedButtonTextColor, for: .normal)
        applyButton.backgroundColor = enabled ? AppColors.kuduThemeYellow : AppColors.unselectedButtonBg
    }
}

extension CartCouponListCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 24
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pointers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PointersHeaderCell")!
            return cell
        }
        
        let cell = tableView.dequeueCell(with: DescriptionPointerCell.self)
        cell.pointerLabel.text = pointers[indexPath.row - 1]
        return cell
    }
}

class DescriptionPointerCell: UITableViewCell {
    @IBOutlet weak var pointerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pointerLabel.font = AppFonts.mulishRegular.withSize(12)
    }
}
