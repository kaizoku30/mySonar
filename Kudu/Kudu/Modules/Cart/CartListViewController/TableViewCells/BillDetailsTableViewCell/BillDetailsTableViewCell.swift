//
//  BillDetailsTableViewCell.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import UIKit

class BillDetailShimmerCell: UITableViewCell {
    @IBOutlet private weak var shimmerView: UIView!
    @IBOutlet private weak var itemTotalLabel: UILabel!
    @IBOutlet private weak var deliveryChargeView: UIView!
    @IBOutlet private weak var deliveryChargeLabel: UILabel!
    @IBOutlet private weak var vatDisclaimerLabel: UILabel!
    @IBOutlet private weak var totalPayableLabel: UILabel!
    @IBOutlet private weak var shimmerView2: UIView!
    @IBOutlet private weak var shimmerView3: UIView!
    @IBOutlet private weak var billdetailLabel: UILabel!
    @IBOutlet private weak var totalPayableTItleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        totalPayableTItleLabel.text = LSCollection.CartScren.totalPayable
        billdetailLabel.text = LSCollection.CartScren.billDetails
        [shimmerView, shimmerView2, shimmerView3].forEach({
            $0?.startShimmering()
        })
    }
}

struct BillDetails {
    var itemTotal: Double = 0
    var deliveryCharge: Double?
    var vatPercent: String = ""
    var totalPayable: Double = 0
}

class BillDetailsTableViewCell: UITableViewCell {
	@IBOutlet private weak var itemTotalLabel: UILabel!
	@IBOutlet private weak var deliveryChargeView: UIView!
	@IBOutlet private weak var deliveryChargeLabel: UILabel!
	@IBOutlet private weak var vatDisclaimerLabel: UILabel!
	@IBOutlet private weak var totalPayableLabel: UILabel!
    @IBOutlet private weak var promoSeparatorView: UIView!
    @IBOutlet private weak var promoSavingsLabel: UILabel!
    @IBOutlet private weak var promoView: UIView!
    @IBOutlet private weak var billdetailLabel: UILabel!
    @IBOutlet weak var totalPayableTitleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        totalPayableTitleLbl.text = LSCollection.CartScren.totalPayable
        billdetailLabel.text = LSCollection.CartScren.billDetails
		deliveryChargeView.isHidden = false
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
    func configure(bill: BillDetails, couponObject: CouponObject?) {
        itemTotalLabel.text = "SR \(bill.itemTotal.removeZerosFromEnd())"
        var vatString = "(Prices Include X% VAT)"
        vatString = vatString.replace(string: "X", withString: bill.vatPercent)
        vatDisclaimerLabel.text = vatString
        if let deliveryCharge = bill.deliveryCharge {
            deliveryChargeLabel.text = "SR \(deliveryCharge .removeZerosFromEnd())"
            deliveryChargeView.isHidden = false
        } else {
            deliveryChargeLabel.text = ""
            deliveryChargeView.isHidden = true
        }
        var total = bill.totalPayable.removeZerosFromEnd()
        
        if let coupon = couponObject, let promoType = PromoOfferType(rawValue: couponObject?.promoData?.offerType ?? ""), promoType != .item, CartUtility.checkCouponValidationError(coupon).isNil {
            let savings = CartUtility.calculateSavingsAfterCoupon(obj: coupon)
            if savings > 0 {
                promoSeparatorView.isHidden = false
                promoSavingsLabel.text = "SR -\(savings.round(to: 2).removeZerosFromEnd())"
                let totalVal = bill.totalPayable
                total = (totalVal - savings).round(to: 2).removeZerosFromEnd()
                promoView.isHidden = false
            }
        } else {
            promoSeparatorView.isHidden = true
            promoView.isHidden = true
        }
        let totalString = "SR \(total)"
        totalPayableLabel.text = totalString
	}

}
