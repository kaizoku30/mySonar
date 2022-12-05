//
//  PreviousOrderCell.swift
//  Kudu
//
//  Created by Admin on 10/10/22.
//

import UIKit

class BillItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    func configure(_ item: CartListObject) {
        let quantity = item.quantity ?? 0
        itemNameLabel.text = AppUserDefaults.selectedLanguage() == .en ? item.itemDetails?.nameEnglish ?? "" : item.itemDetails?.nameArabic ?? ""
        quantityLabel.text = "\(quantity) x"
    }
}

class PreviousOrderCell: UITableViewCell {
    @IBOutlet private weak var boxImgView: UIImageView!
    @IBOutlet private weak var deliveredPickedUpLabel: UILabel!
    @IBOutlet private weak var orderIdLabel: UILabel!
    @IBOutlet private weak var reorderButton: UIButton!
    @IBOutlet private weak var rateOrderButton: UIButton!
    @IBOutlet private weak var tableContainerHeight: NSLayoutConstraint! //28
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var dateTimeLabel: UILabel!
    @IBOutlet private weak var numberOfItemsLabel: UILabel!
    @IBOutlet private weak var totalPriceLabel: UILabel!
    @IBOutlet private weak var cancellationStackView: UIStackView!
    
    @IBOutlet private weak var ratingView: UIView!
    @IBOutlet private weak var starCountLabel: UILabel!
    @IBOutlet private weak var ratingDescLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reorderButton.setTitle(LSCollection.Orders.reorderBtn, for: .normal)
        rateOrderButton.setTitle(LSCollection.Orders.rateOrderBtn, for: .normal)
        tableView.dataSource = self
        tableView.delegate = self
        rateOrderButton.addTarget(self, action: #selector(rateOrderButtonPressed), for: .touchUpInside)
        reorderButton.addTarget(self, action: #selector(reordeButtonPressed), for: .touchUpInside)
    }
    
    @objc private func reordeButtonPressed() {
        reOrder?(orderRef._id ?? "")
    }
    
    @objc private func rateOrderButtonPressed() {
        rateOrder?(orderRef._id ?? "")
    }
    
    private var orderRef: OrderListItem!
    var rateOrder: ((String) -> Void)?
    var reOrder: ((String) -> Void)?
    
    func configure(_ order: OrderListItem) {
        orderRef = order
        if let description = order.rating?.description, !description.isEmpty {
            rateOrderButton.backgroundColor = AppColors.unselectedButtonBg
            rateOrderButton.setTitleColor(AppColors.unselectedButtonTextColor, for: .normal)
            starCountLabel.text = order.rating?.rate?.round(to: 1).removeZerosFromEnd() ?? ""
            ratingDescLabel.text = order.rating?.description ?? ""
            ratingView.isHidden = false
        } else {
            ratingView.isHidden = true
            rateOrderButton.backgroundColor = AppColors.kuduThemeYellow
            rateOrderButton.setTitleColor(AppColors.white, for: .normal)
        }
        let serviceType = APIEndPoints.ServicesType(rawValue: order.servicesAvailable ?? "") ?? .delivery
        deliveredPickedUpLabel.text = serviceType == .delivery ? LSCollection.Orders.deliveredStatus : "Picked Up"
        let orderDate = Date(timeIntervalSince1970: TimeInterval(Double(order.created ?? 0)/1000))
        let timeString = orderDate.toString(dateFormat: Date.DateFormat.dMMMYYYYatHHmma.rawValue)
        dateTimeLabel.text = timeString
        orderIdLabel.text = "Order ID : \(order.orderId ?? "")"
        let itemCount = orderRef.items?.count ?? 0
        let itemString = itemCount == 1 ? "item" : "items"
        numberOfItemsLabel.text = "| \(itemCount) \(itemString)"
        let total = order.totalAmount ?? 0.0
        totalPriceLabel.text = "SR \(total.round(to: 2).removeZerosFromEnd())"
        setTableHeight()
        if serviceType == .delivery {
            boxImgView.image = AppImages.Orders.successOrderListImg
            deliveredPickedUpLabel.textColor = .black
        } else {
            let status = CurbsidePickupOrderStatus(rawValue: order.orderStatus ?? "") ?? .collected
            let imgRef = AppImages.Orders.self
            boxImgView.image = status == .cancelled ? imgRef.cancelOrderListImg : imgRef.successOrderListImg
            if status == .cancelled {
                deliveredPickedUpLabel.text = "Cancelled"
                deliveredPickedUpLabel.textColor = UIColor(r: 225, g: 0, b: 0, alpha: 1)
                cancellationStackView.isHidden = false
            } else {
                cancellationStackView.isHidden = true
                deliveredPickedUpLabel.textColor = .black
            }
        }
    }
    
    private func setTableHeight() {
        var rowHeightSum: CGFloat = 0
        let items = orderRef.items ?? []
        items.forEach({
            let name = AppUserDefaults.selectedLanguage() == .en ? $0.itemDetails?.nameEnglish ?? "" : $0.itemDetails?.nameArabic ?? ""
            let height = name.heightOfText(self.tableView.width - 32, font: AppFonts.mulishRegular.withSize(12))
            rowHeightSum += height + 12
        })
        tableContainerHeight.constant = rowHeightSum
        tableView.reloadData()
    }
}

extension PreviousOrderCell: UITableViewDataSource, UITableViewDelegate {
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
