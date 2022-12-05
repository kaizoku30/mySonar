//
//  PaymentMethodView.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit

class PaymentMethodView: UIView {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var codPaymentHeight: NSLayoutConstraint!
    @IBOutlet weak var paymentOptionsTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        paymentOptionsTitle.text = LSCollection.Payments.paymentOptions
    }
    
    func showCODPayment(_ show: Bool) {
        mainThread({
            self.codPaymentHeight.constant = show ? 48 : 0
            self.layoutIfNeeded()
        })
    }
    
    func showError(msg: String) {
        mainThread({
            let appError = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            appError.show(message: msg, view: self)
        })
    }
}
