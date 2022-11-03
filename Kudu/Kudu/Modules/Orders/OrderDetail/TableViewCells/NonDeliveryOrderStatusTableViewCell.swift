//
//  NonDeliveryOrderStatusTableViewCell.swift
//  Kudu
//
//  Created by Admin on 12/10/22.
//

import UIKit

class NonDeliveryOrderStatusTableViewCell: UITableViewCell {
    @IBOutlet weak var headerInfoView: UIView!
    @IBOutlet weak var etaLabel: UILabel!
    
    @IBAction func dropDownButtonPressed(_ sender: Any) {
        self.expanded = !self.expanded
        self.configure(expanded: expanded, statusArrayInc: statusArray, orderDelayed: self.orderDelayed, etaTime: self.etaTime, cancelledOrder: self.cancelledOrder)
        self.updateExpandedConfig?(self.expanded)
    }
    
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var latestStatusView: UIView!
    @IBOutlet weak var latestStatusTime: UILabel!
    @IBOutlet weak var latestStatusLabel: UILabel!
    @IBOutlet weak var latestStatusImgView: UIImageView!
    
    @IBOutlet weak var expandedStatusView: UIView!
    
    @IBOutlet weak var status1Time: UILabel!
    @IBOutlet weak var status1ImgView: UIImageView!
    @IBOutlet weak var status1Label: UILabel!
    
    @IBOutlet weak var status2Time: UILabel!
    @IBOutlet weak var status2ImgView: UIImageView!
    @IBOutlet weak var status2Label: UILabel!
    
    @IBOutlet weak var status3Time: UILabel!
    @IBOutlet weak var status3ImgView: UIImageView!
    @IBOutlet weak var status3Label: UILabel!
    
    @IBOutlet weak var status4Time: UILabel!
    @IBOutlet weak var status4ImgView: UIImageView!
    @IBOutlet weak var status4Label: UILabel!
    
    @IBOutlet weak var itemWillBeHandedOverToYou: UILabel!
    
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var cancelTime: UILabel!
    @IBOutlet weak var cancelView: UIView!
    
    @IBOutlet weak var nonCancelStatusesView: UIView!
    
    @IBOutlet weak var itemWillBeHandedContainer: UIView!
    @IBOutlet weak var itemWillBeHandedContainerHeight: NSLayoutConstraint!
    
    private let upArrrow = UIImage(named: "k_orderStatusUpArrow")!
    private let downArrow = UIImage(named: "k_orderStatusDropDown")!
    private let statusAchieved = UIImage(named: "k_statusAchieved")!
    private let statusNotAchieved = UIImage(named: "k_statusNotAchieved")!
    
    private var etaTime: String = ""
    private var orderDelayed = false
    private var expanded = false
    private var cancelledOrder = false
    private var statusArray: [OrderTimeWithStatus] = []
    var updateExpandedConfig: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemWillBeHandedContainerHeight.constant = 0
        cancelView.isHidden = true
        nonCancelStatusesView.isHidden = true
        itemWillBeHandedOverToYou.isHidden = true
    }
    
    func configure(expanded: Bool, statusArrayInc: [OrderTimeWithStatus], orderDelayed: Bool, etaTime: String, cancelledOrder: Bool) {
        self.cancelledOrder = cancelledOrder
        self.statusArray = statusArrayInc
        self.expanded = expanded
        self.orderDelayed = orderDelayed
        self.etaTime = etaTime
        dropDownButton.setImage(expanded ? upArrrow : downArrow, for: .normal)
        let latestStatus = statusArray.last
        let latestStatusString = latestStatus?.orderStatus ?? ""
        let latestTime = latestStatus?.time ?? 0
        let latestTimeStamp = Date(timeIntervalSince1970: Double(latestTime)/1000).toString(dateFormat: Date.DateFormat.hmmazzz.rawValue)
        var statusType = CurbsidePickupOrderStatus(rawValue: latestStatusString) ?? .collected
        if cancelledOrder {
            statusType = .cancelled
            statusArray.append(OrderTimeWithStatus(orderStatus: CurbsidePickupOrderStatus.cancelled.rawValue, time: latestTime))
        }
        etaLabel.textColor = orderDelayed ? UIColor(r: 225, g: 0, b: 0, alpha: 1) : .black.withAlphaComponent(0.6)
        if statusType == .collected || statusType == .cancelled {
            etaLabel.isHidden = true
        } else {
            etaLabel.text = "(\(etaTime))"
            etaLabel.isHidden = false
        }
        if !expanded {
            expandedStatusView.isHidden = true
            latestStatusTime.text = latestTimeStamp
            if statusType == .cancelled {
                latestStatusImgView.image = AppImages.Orders.cancelCircle
            }
            latestStatusLabel.text = statusType.title
            latestStatusView.isHidden = false
        } else {
            latestStatusView.isHidden = true
            if statusType == .cancelled {
                let deliveryStatusType = CurbsidePickupOrderStatus.orderPlaced
                let statusObject = statusArray[safe: 0]
                let statusTime = statusObject?.time ?? 0
                let statusTimeString = Date(timeIntervalSince1970: Double(statusTime)/1000).toString(dateFormat: Date.DateFormat.hmmazzz.rawValue)
                status1Time.text = statusTimeString
                status1Time.isHidden = false
                status1ImgView.image = statusAchieved
                cancelTime.text = latestTimeStamp
                cancelView.isHidden = false
                nonCancelStatusesView.isHidden = true
                expandedStatusView.isHidden = false
                return
            } else {
                cancelView.isHidden = true
            }
            [status1Time, status2Time, status3Time, status4Time].forEach({
                $0.text = ""
            })
            [status1ImgView, status2ImgView, status3ImgView, status4ImgView].forEach({
                $0.image = statusNotAchieved
            })
//            if statusType != .collected || statusType != .cancelled {
//                itemWillBeHandedContainerHeight.constant = 0
//            } else {
//                itemWillBeHandedContainerHeight.constant = 28
//            }
            itemWillBeHandedContainerHeight.constant = 28
            itemWillBeHandedOverToYou.isHidden = false
            for i in 0..<statusArray.count {
                let deliveryStatusType = CurbsidePickupOrderStatus(rawValue: statusArray[i].orderStatus ?? "") ?? .orderPlaced
                let statusObject = statusArray[i]
                let statusTime = statusObject.time ?? 0
                let statusTimeString = Date(timeIntervalSince1970: Double(statusTime)/1000).toString(dateFormat: Date.DateFormat.hmmazzz.rawValue)
                switch deliveryStatusType {
                case .orderPlaced:
                    status1Time.text = statusTimeString
                    status1Time.isHidden = false
                    status1ImgView.image = statusAchieved
                case .inKitchen:
                    status2Time.text = statusTimeString
                    status2ImgView.image = statusAchieved
                    status2Time.isHidden = false
                case .readytoPickup:
                    status3Time.text = statusTimeString
                    status3ImgView.image = statusAchieved
                    status3Time.isHidden = false
                    itemWillBeHandedOverToYou.isHidden = false
                case .collected:
                    itemWillBeHandedOverToYou.isHidden = false
                    status4Time.text = statusTimeString
                    status4ImgView.image = statusAchieved
                    status4Time.isHidden = false
                default:
                    break
                }
            }
            nonCancelStatusesView.isHidden = false
            expandedStatusView.isHidden = false
        }
    }
}
