//
//  PayButtonTVCell.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit

class PayButtonTVCell: UITableViewCell {
    @IBOutlet private weak var priceButton: AppButton!
    
    @IBAction func priceButtonPressed(_ sender: Any) {
        priceButton.startBtnLoader(color: .white)
        priceButtonPressed?()
    }
    
    var priceButtonPressed: (() -> Void)?
    
    func setPrice(_ price: Double) {
        self.priceButton.stopBtnLoader(titleColor: .white)
        self.priceButton.setTitle("\(LSCollection.Payments.paySR) \(price.round(to: 2).removeZerosFromEnd())", for: .normal)
    }
}
