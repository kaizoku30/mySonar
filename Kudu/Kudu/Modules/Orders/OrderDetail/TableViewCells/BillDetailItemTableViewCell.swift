//
//  BillDetailItemTableViewCell.swift
//  Kudu
//
//  Created by Admin on 13/10/22.
//

import UIKit

class BillDetailItemTableViewCell: UITableViewCell {
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    func configure(quantity: Int, nameEnglish: String, nameArabic: String, price: Double) {
        itemCountLabel.text = "\(quantity) x"
        let lang = AppUserDefaults.selectedLanguage()
        itemNameLabel.text = lang == .en ? nameEnglish : nameArabic
        itemPriceLabel.text = "SR \(price.round(to: 2).removeZerosFromEnd())"
    }
}

class BillDetailBreakdownCell: UITableViewCell {
    @IBOutlet weak var promoView: UIView!
    @IBOutlet weak var deliveryCharge: UILabel!
    @IBOutlet weak var deliveryChargeView: UIView!
    @IBOutlet weak var promoDiscount: UILabel!
    @IBOutlet weak var itemTotalLabel: UILabel!
    
    func configure(deliveryChargeAmount: Double, discount: Double, itemTotal: Double) {
        itemTotalLabel.text = "SR \(itemTotal.round(to: 2).removeZerosFromEnd())"
        promoView.isHidden = discount == 0.0
        deliveryChargeView.isHidden = deliveryChargeAmount == 0.0
        deliveryCharge.text = "SR \(deliveryChargeAmount.round(to: 2).removeZerosFromEnd())"
        promoDiscount.text = "SR -\(discount.round(to: 2).removeZerosFromEnd())"
    }
}

class TotalPayableCell: UITableViewCell {
    @IBOutlet weak var vatLabel: UILabel! // (Prices Include X% VAT)
    @IBOutlet weak var totalPrice: UILabel!
    
    func configure(vat: String = "", totalAmount: Double) {
        vatLabel.isHidden = false
        vatLabel.text = "(Prices Include \(vat)% VAT)"
        totalPrice.text = "SR \(totalAmount.round(to: 2).removeZerosFromEnd())"
    }
}
