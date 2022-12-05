//
//  File.swift
//  Kudu
//
//  Created by Admin on 11/10/22.
//

import UIKit

class OrderInfoTableViewCell: UITableViewCell {
    @IBAction private func callRestButtonPressed(_ sender: Any) {
        callRestaurant?()
    }
    @IBOutlet private weak var callRestView: UIView!
    @IBOutlet private weak var orderIDLabel: UILabel! //Order ID :
    @IBOutlet private weak var rateOrderButton: UIButton!
    @IBOutlet private weak var iHaveArrivedButton: AppButton!
    @IBOutlet private weak var mapRedirectionStack: UIStackView!
    @IBOutlet private weak var pickupCurbsideLabel: UILabel!
    
    var ihaveArrived: (() -> Void)?
    var triggerRateOrder: (() -> Void)?
    var triggerMapRedirect: (() -> Void)?
    var callRestaurant: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rateOrderButton.setTitle(LSCollection.Orders.rateOrderBtn, for: .normal)
        iHaveArrivedButton.addTarget(self, action: #selector(ihaveArrivedPressed), for: .touchUpInside)
        iHaveArrivedButton.isUserInteractionEnabled = false
        rateOrderButton.addTarget(self, action: #selector(rateOrderButtonPressed), for: .touchUpInside)
       // mapRedirectionStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mapRedirect)))
    }
    
    @objc private func mapRedirect() {
        triggerMapRedirect?()
    }
    
    @objc private func rateOrderButtonPressed() {
        triggerRateOrder?()
    }
    
    @objc private func ihaveArrivedPressed() {
        iHaveArrivedButton.startBtnLoader(color: .white, small: true)
        ihaveArrived?()
    }
    
    func configure(orderId: String, serviceType: APIEndPoints.ServicesType, arrivalInfo: (hasArrived: Bool, arrivalStatus: String), orderStatus: String, rating: RatingModel?) {
        if serviceType == .delivery {
            let deliveryStatus = DeliveryOrderStatus(rawValue: orderStatus ) ?? .outForDelivery
            callRestView.isHidden = deliveryStatus != .orderPlaced
        }
        let curbsideStatus = CurbsidePickupOrderStatus(rawValue: orderStatus) ?? .orderPlaced
       // mapRedirectionStack.isHidden = true//serviceType == .delivery || curbsideStatus == .cancelled || curbsideStatus == .collected
      //  pickupCurbsideLabel.text = serviceType == .curbside ? "Curbside" : "Pickup"
        orderIDLabel.text = "Order ID : \(orderId)"
        if serviceType == .curbside {
            let isArrived = arrivalInfo.hasArrived
            let arrivalStatus = ArrivalStatus(rawValue: arrivalInfo.arrivalStatus) ?? .willArive
            if isArrived || arrivalStatus != .willArive {
                iHaveArrivedButton.stopBtnLoader(titleColor: AppColors.unselectedButtonTextColor)
            }
            iHaveArrivedButton.isUserInteractionEnabled = (isArrived || arrivalStatus != .willArive) == false
            let curbsideStatus = CurbsidePickupOrderStatus(rawValue: orderStatus) ?? .collected
            iHaveArrivedButton.isHidden = curbsideStatus == .collected || curbsideStatus == .cancelled
            rateOrderButton.isHidden = !(curbsideStatus == .collected)
            iHaveArrivedButton.backgroundColor = isArrived || arrivalStatus != .willArive ? AppColors.unselectedButtonBg : AppColors.kuduThemeYellow
            iHaveArrivedButton.setTitleColor(isArrived || arrivalStatus != .willArive ? AppColors.unselectedButtonTextColor : .white, for: .normal)
            iHaveArrivedButton.setTitle(arrivalStatus.title, for: .normal)
        } else {
            iHaveArrivedButton.isHidden = true
            if serviceType == .pickup {
                let pickupStatus = CurbsidePickupOrderStatus(rawValue: orderStatus) ?? .collected
                rateOrderButton.isHidden = !(pickupStatus == .collected)
            } else {
                let status = DeliveryOrderStatus(rawValue: orderStatus) ?? .delivered
                rateOrderButton.isHidden = !(status == .delivered)
            }
        }
        if let desc = rating?.description, !desc.isEmpty {
            rateOrderButton.isHidden = true
        }
    }
}

class OrderIdCell: UITableViewCell {
    @IBOutlet private weak var orderIdLabel: UILabel!
    
    func configure(orderId: String) {
        orderIdLabel.text = "Order ID : \(orderId)"
    }
}
