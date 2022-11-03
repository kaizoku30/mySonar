//
//  ActiveOrderDeliveryCell.swift
//  Kudu
//
//  Created by Admin on 10/10/22.
//

import UIKit

class ActiveOrderDeliveryCell: UITableViewCell {
    @IBOutlet weak var orderIDLabel: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalBillLabel: UILabel!
    
    @IBOutlet weak var status1ImgView: UIImageView!
    @IBOutlet weak var firstConnectorView: UIImageView!
    @IBOutlet weak var status2ImgView: UIImageView!
    @IBOutlet weak var secondConnectorView: UIImageView!
    @IBOutlet weak var status3ImgView: UIImageView!
    @IBOutlet weak var thirdConnectorView: UIImageView!
    @IBOutlet weak var status4ImgView: UIImageView!
    @IBOutlet weak var fourthConnectorView: UIImageView!
    @IBOutlet weak var status5ImgView: UIImageView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    
    @IBOutlet weak var ETALabel: UILabel!
    @IBOutlet weak var ETAView: UIView!
    
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var scheduleView: UIView!
    
    private let unselectedTextColor = UIColor(r: 91, g: 90, b: 90, alpha: 0.5)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.dataSource = self
        tableView.delegate = self
        [label1, label2, label3, label4, label5].forEach({ $0?.textColor = unselectedTextColor })
        [status1ImgView, firstConnectorView, status2ImgView, secondConnectorView, status3ImgView, thirdConnectorView, status4ImgView, fourthConnectorView, status5ImgView].forEach({
            self.toggleImg(false, imgView: $0)
        })
    }
    
    private var orderRef: OrderListItem!
    
    func configure(_ order: OrderListItem) {
        orderRef = order
        if let scheduleTime = order.getScheduledDateTime() {
            scheduleView.isHidden = false
            scheduleLabel.text = scheduleTime
            ETAView.isHidden = true
        } else {
            ETAView.isHidden = false
            scheduleView.isHidden = true
            if order.checkIfOrderDelayed() {
                ETALabel.text = order.calculateETA()
                ETALabel.textColor = UIColor(r: 225, g: 0, b: 0, alpha: 1)
            } else {
                ETALabel.text = order.calculateETA()
                ETALabel.textColor = .black
            }
        }
        orderIDLabel.text = "Order ID : \(order.orderId ?? "")"
        let itemCount = orderRef.items?.count ?? 0
        let itemString = itemCount == 1 ? "item" : "items"
        itemCountLabel.text = "| \(itemCount) \(itemString)"
        let total = order.totalAmount ?? 0.0
        totalBillLabel.text = "SR \(total.round(to: 2).removeZerosFromEnd())"
        setTableHeight()
        let deliveryStatus = order.getOrderStatus() as! DeliveryOrderStatus
        handleStatus(deliveryStatus)
    }
    
    private func setTableHeight() {
        var rowHeightSum: CGFloat = 0
        let items = orderRef.items ?? []
        items.forEach({
            let name = AppUserDefaults.selectedLanguage() == .en ? $0.itemDetails?.nameEnglish ?? "" : $0.itemDetails?.nameArabic ?? ""
            let height = name.heightOfText(self.tableView.width - 32, font: AppFonts.mulishRegular.withSize(12))
            rowHeightSum += height + 12
        })
        tableHeight.constant = rowHeightSum
        tableView.reloadData()
    }
    
    private func handleStatus(_ status: DeliveryOrderStatus) {
        switch status {
        case .orderPlaced:
            toggleImg(true, imgView: status1ImgView)
            toggleLabel(true, label: label1)
        case .inKitchen:
            [status1ImgView, firstConnectorView, status2ImgView].forEach({
                self.toggleImg(true, imgView: $0)
            })
            [label1, label2].forEach({
                self.toggleLabel(true, label: $0)
            })
        case .readyForDelivery:
            [status1ImgView, firstConnectorView, status2ImgView, secondConnectorView, status3ImgView].forEach({
                self.toggleImg(true, imgView: $0)
            })
            [label1, label2, label3].forEach({
                self.toggleLabel(true, label: $0)
            })
        case .outForDelivery:
            [status1ImgView, firstConnectorView, status2ImgView, secondConnectorView, status3ImgView, thirdConnectorView, status4ImgView].forEach({
                self.toggleImg(true, imgView: $0)
            })
            [label1, label2, label3, label4].forEach({
                self.toggleLabel(true, label: $0)
            })
        case .delivered:
            [status1ImgView, firstConnectorView, status2ImgView, secondConnectorView, status3ImgView, thirdConnectorView, status4ImgView, fourthConnectorView, status5ImgView].forEach({
                self.toggleImg(true, imgView: $0)
            })
            [label1, label2, label3, label4, label5].forEach({
                self.toggleLabel(true, label: $0)
            })
        }
    }
    
    private func toggleImg(_ enabled: Bool, imgView: UIImageView) {
        imgView.alpha = enabled ? 1 : 0.6
    }
    
    private func toggleLabel(_ enabled: Bool, label: UILabel) {
        label.textColor = enabled ? .black : unselectedTextColor
    }
}

extension ActiveOrderDeliveryCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orderRef.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: BillItemTableViewCell.self)
        if let item = orderRef.items?[indexPath.row] {
            cell.configure(item)
        }
        return cell
    }
}
