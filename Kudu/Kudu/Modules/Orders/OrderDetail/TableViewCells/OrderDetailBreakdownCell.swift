//
//  OrderDetailBreakdownCell.swift
//  Kudu
//
//  Created by Admin on 13/10/22.
//

import UIKit

class OrderDetailBreakdownCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var pickupDeliverToLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    
    func configure(payment: String = "Complete", orderId: String, phoneNumber: String, serviceType: APIEndPoints.ServicesType, address: String, orderStatus: String) {
        paymentLabel.text = payment
        orderIdLabel.text = orderId
        phoneNumberLabel.text = "+91-" + phoneNumber
        addressLabel.text = address
        if serviceType == .delivery {
            let deliveryStatus = DeliveryOrderStatus(rawValue: orderStatus) ?? .delivered
            pickupDeliverToLabel.text = deliveryStatus == .delivered ? "Delivered To" : "Deliver To"
        } else {
            pickupDeliverToLabel.text = "PickUp From"
        }
    }
}
