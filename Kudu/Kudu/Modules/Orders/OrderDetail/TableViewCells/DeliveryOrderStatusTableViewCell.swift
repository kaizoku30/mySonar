//
//  DeliveryOrderStatusTableViewCell.swift
//  Kudu
//
//  Created by Admin on 12/10/22.
//

import UIKit

class DeliveryOrderStatusTableViewCell: UITableViewCell {
    @IBOutlet weak var headerInfoView: UIView!
    @IBOutlet weak var etaLabel: UILabel!
    
    @IBAction func dropDownButtonPressed(_ sender: Any) {
        self.expanded = !self.expanded
        self.configure(expanded: expanded, statusArray: statusArray, orderDelayed: self.orderDelayed, etaTime: self.etaTime)
        self.updateExpandedConfig?(self.expanded)
    }
    
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var latestStatusView: UIView!
    @IBOutlet weak var latestStatusTime: UILabel!
    @IBOutlet weak var latestStatusLabel: UILabel!
    
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
    
    @IBOutlet weak var status5Time: UILabel!
    @IBOutlet weak var status5ImgView: UIImageView!
    @IBOutlet weak var status5Label: UILabel!
    
    private let upArrrow = UIImage(named: "k_orderStatusUpArrow")!
    private let downArrow = UIImage(named: "k_orderStatusDropDown")!
    private let statusAchieved = UIImage(named: "k_statusAchieved")!
    private let statusNotAchieved = UIImage(named: "k_statusNotAchieved")!
    
    private var etaTime: String = ""
    private var orderDelayed = false
    private var expanded = false
    private var statusArray: [OrderTimeWithStatus] = []
    var updateExpandedConfig: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(expanded: Bool, statusArray: [OrderTimeWithStatus], orderDelayed: Bool, etaTime: String) {
        self.statusArray = statusArray
        self.expanded = expanded
        self.orderDelayed = orderDelayed
        self.etaTime = etaTime
        let latestStatus = statusArray.last
        let latestStatusString = latestStatus?.orderStatus ?? ""
        let latestTime = latestStatus?.time ?? 0
        let statusType = DeliveryOrderStatus(rawValue: latestStatusString) ?? .delivered
        etaLabel.textColor = orderDelayed ? UIColor(r: 225, g: 0, b: 0, alpha: 1) : .black.withAlphaComponent(0.6)
        if statusType == .delivered {
            etaLabel.isHidden = true
        } else {
            etaLabel.text = "(\(etaTime))"
            etaLabel.isHidden = false
        }
        dropDownButton.setImage(expanded ? upArrrow : downArrow, for: .normal)
        if !expanded {
            expandedStatusView.isHidden = true
            
            latestStatusTime.text = Date(timeIntervalSince1970: Double(latestTime)/1000).toString(dateFormat: Date.DateFormat.hmmazzz.rawValue)
            latestStatusLabel.text = statusType.title
            latestStatusView.isHidden = false
        } else {
            [status1Time, status2Time, status3Time, status4Time, status5Time].forEach({
                $0.text = ""
            })
            [status1ImgView, status2ImgView, status3ImgView, status4ImgView, status5ImgView].forEach({
                $0.image = statusNotAchieved
            })
            latestStatusView.isHidden = true
            for i in 0..<statusArray.count {
                let deliveryStatusType = DeliveryOrderStatus(rawValue: statusArray[i].orderStatus ?? "") ?? .orderPlaced
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
                case .readyForDelivery:
                    status3Time.text = statusTimeString
                    status3ImgView.image = statusAchieved
                    status3Time.isHidden = false
                case .outForDelivery:
                    status4Time.text = statusTimeString
                    status4ImgView.image = statusAchieved
                    status4Time.isHidden = false
                case .delivered:
                    status5Time.text = statusTimeString
                    status5ImgView.image = statusAchieved
                    status5Time.isHidden = false
                }
            }
            expandedStatusView.isHidden = false
        }
    }
}
