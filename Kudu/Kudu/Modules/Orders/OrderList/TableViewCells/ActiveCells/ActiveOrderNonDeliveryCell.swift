//
//  ActiveOrderNonDeliveryCell.swift
//  Kudu
//
//  Created by Admin on 10/10/22.
//

import UIKit

enum ArrivalStatus: String {
    case willArive = "1"
    case arrivedAtStore = "2"
    case storeAcknowledged = "3"
    
    var title: String {
        switch self {
        case .willArive:
            return "I've Arrived"
        case .arrivedAtStore:
            return "Arrived at store"
        case .storeAcknowledged:
            return "Store Acknowledged"
        }
    }
}

class ActiveOrderNonDeliveryCell: UITableViewCell {
    @IBOutlet weak var orderIDLabel: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalBillLabel: UILabel!
    
    @IBOutlet weak var status1ImgView: UIImageView!
    @IBOutlet weak var firstConnectorView: UIImageView!
    @IBOutlet weak var firstConnectorSecondHalfView: UIImageView!
    @IBOutlet weak var status2ImgView: UIImageView!
    @IBOutlet weak var secondConnectorView: UIImageView!
    @IBOutlet weak var secondConnectorSecondHalfView: UIImageView!
    @IBOutlet weak var status3ImgView: UIImageView!
    @IBOutlet weak var thirdConnectorView: UIImageView!
    @IBOutlet weak var fourthConnectorView: UIImageView!
    @IBOutlet weak var status4ImgView: UIImageView!
    @IBOutlet weak var kuduTriangle: UIImageView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    @IBOutlet weak var ETALabel: UILabel!
    @IBOutlet weak var ETAView: UIView!
    
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var scheduleView: UIView!
    
    @IBOutlet weak var mapRedirectionButton: UIStackView!
    @IBOutlet weak var pickUpCurbsideLabel: UILabel!
    
    @IBOutlet weak var iHaveArrivedInfoView: UIStackView!
    @IBOutlet weak var iHaveArrivedButton: UIButton!
    @IBOutlet weak var ihaveArrivedStack: UIStackView!
    @IBOutlet weak var itemWillBeHandedOverToYou: UILabel!
    
    private let unselectedTextColor = UIColor(r: 91, g: 90, b: 90, alpha: 0.5)
    
    var markAsArrived: ((Int) -> Void)?
    var triggerMapRedirect: ((Int) -> Void)?
    var cellIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.dataSource = self
        tableView.delegate = self
        itemWillBeHandedOverToYou.isHidden = true
        [label1, label2, label3, label4].forEach({ $0?.textColor = unselectedTextColor })
        [status1ImgView, firstConnectorView, firstConnectorSecondHalfView, status2ImgView, secondConnectorView, secondConnectorSecondHalfView, status3ImgView, thirdConnectorView, status4ImgView, fourthConnectorView].forEach({
            self.toggleImg(false, imgView: $0)
        })
        kuduTriangle.isHidden = true
        mapRedirectionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(redirectToMap)))
        iHaveArrivedButton.addTarget(self, action: #selector(markArrival), for: .touchUpInside)
    }
    
    @objc private func markArrival() {
        self.markAsArrived?(self.cellIndex)
    }
    
    @objc private func redirectToMap() {
        triggerMapRedirect?(self.cellIndex)
    }
    
    private var orderRef: OrderListItem!
    
    func configure(_ order: OrderListItem) {
        orderRef = order
        let arrivalInfo: (isArrived: Bool, arrivalStatus: String) = (order.isArrived ?? false, order.arrivedStatus ?? "")
        let type = APIEndPoints.ServicesType(rawValue: order.servicesAvailable ?? "")
        let deliveryStatus = CurbsidePickupOrderStatus(rawValue: order.orderStatus ?? "") ?? .collected
        let scheduleTime = order.getScheduledDateTime()
        pickUpCurbsideLabel.text = type == .pickup ? "Pickup" : "Curbside"
        let isArrived = arrivalInfo.isArrived
        let arrivalStatus = ArrivalStatus(rawValue: arrivalInfo.arrivalStatus) ?? .willArive
        ihaveArrivedStack.isHidden = type == .pickup
        iHaveArrivedInfoView.alpha = (type == .pickup || (isArrived || arrivalStatus != .willArive) == true) ? 0 : 1
        if type != .pickup {
            iHaveArrivedButton.backgroundColor = isArrived || arrivalStatus != .willArive ? AppColors.unselectedButtonBg : AppColors.kuduThemeYellow
            iHaveArrivedButton.setTitleColor(isArrived || arrivalStatus != .willArive ? AppColors.unselectedButtonTextColor : .white, for: .normal)
            iHaveArrivedButton.setTitle(arrivalStatus.title, for: .normal)
        }
//        if let scheduleTime {
//            scheduleView.isHidden = false
//            scheduleLabel.text = scheduleTime
//            ETAView.isHidden = true
//        } else {
//            ETAView.isHidden = false
//            scheduleView.isHidden = true
//            if order.checkIfOrderDelayed() {
//                ETALabel.text = order.calculateETA()
//                ETALabel.textColor = UIColor(r: 225, g: 0, b: 0, alpha: 1)
//            } else {
//                ETALabel.text = order.calculateETA()
//                ETALabel.textColor = .black
//            }
//        }
        orderIDLabel.text = "Order ID : \(order.orderId ?? "")"
        orderIDLabel.adjustsFontSizeToFitWidth = true
        let itemCount = orderRef.items?.count ?? 0
        let itemString = itemCount == 1 ? "item" : "items"
        itemCountLabel.text = "| \(itemCount) \(itemString)"
        let total = order.totalAmount ?? 0.0
        totalBillLabel.text = "SR \(total.round(to: 2).removeZerosFromEnd())"
        setTableHeight()
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
        if rowHeightSum < 54 {
            rowHeightSum = 54
        }
        tableHeight.constant = rowHeightSum
        tableView.reloadData()
    }
    
    private func handleStatus(_ status: CurbsidePickupOrderStatus) {
        switch status {
        case .orderPlaced:
            toggleImg(true, imgView: status1ImgView)
            toggleLabel(true, label: label1)
        case .inKitchen:
            [status1ImgView, firstConnectorView, firstConnectorSecondHalfView, status2ImgView].forEach({
                self.toggleImg(true, imgView: $0)
            })
            [label1, label2].forEach({
                self.toggleLabel(true, label: $0)
            })
        case .readytoPickup:
            [status1ImgView, firstConnectorView, firstConnectorSecondHalfView, status2ImgView, secondConnectorView, secondConnectorSecondHalfView, status3ImgView, thirdConnectorView].forEach({
                self.toggleImg(true, imgView: $0)
            })
            [label1, label2, label3].forEach({
                self.toggleLabel(true, label: $0)
            })
            self.kuduTriangle.isHidden = false
            self.itemWillBeHandedOverToYou.isHidden = false
        case .collected:
            itemWillBeHandedOverToYou.isHidden = true
            self.kuduTriangle.isHidden = true
            [status1ImgView, firstConnectorView, firstConnectorSecondHalfView, status2ImgView, secondConnectorView, secondConnectorSecondHalfView, status3ImgView, thirdConnectorView, status4ImgView, fourthConnectorView].forEach({
                self.toggleImg(true, imgView: $0)
            })
            [label1, label2, label3, label4].forEach({
                self.toggleLabel(true, label: $0)
            })
        case .cancelled:
            break
        }
    }
    
    private func toggleImg(_ enabled: Bool, imgView: UIImageView) {
        imgView.alpha = enabled ? 1 : 0.6
    }
    
    private func toggleLabel(_ enabled: Bool, label: UILabel) {
        label.textColor = enabled ? .black : unselectedTextColor
    }
}

extension ActiveOrderNonDeliveryCell: UITableViewDelegate, UITableViewDataSource {
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
