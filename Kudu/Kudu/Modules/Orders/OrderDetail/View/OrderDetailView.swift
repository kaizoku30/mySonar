//
//  OrderDetailView.swift
//  Kudu
//
//  Created by Admin on 11/10/22.
//

import UIKit
import NVActivityIndicatorView

class OrderDetailView: UIView {
    
    @IBOutlet weak var reorderButton: AppButton!
    
    @IBAction func supportButtonPressed(_ sender: Any) {
        handleViewActions?(.supportButtonPressed)
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        handleViewActions?(.backButtonPressed)
    }
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak private var loaderView: UIView!
    @IBOutlet weak private var cancelOrderButton: AppButton!
    
    @IBAction func reorderButtonPressed(_ sender: Any) {
        if CartUtility.fetchCartLocally().isEmpty {
            self.handleViewActions?(.reorderTrigger)
        } else {
            self.showCartClearanceAlert()
        }
    }
    
    @IBAction func cancelOrderButtonPressed(_ sender: Any) {
        cancelOrderButton.startBtnLoader(color: AppColors.kuduThemeBlue)
        handleViewActions?(.cancelOrder)
    }
    
    @IBOutlet weak var reorderView: UIView!
    @IBOutlet weak var cancelOrderView: UIView!
    @IBOutlet weak var orderDetailLbl: UILabel!
    
    enum Sections: Int, CaseIterable {
        case OrderInfo = 0
        case OrderStatus
        case BillingDetails
        case OrderDetails
        case Rating
    }
    enum ViewActions {
        case pullToRefreshCalled
        case backButtonPressed
        case cancelOrder
        case supportButtonPressed
        case rateOrderPressed
        case reorderTrigger
    }
    var handleViewActions: ((ViewActions) -> Void)?
    var alert: AppPopUpView?
    private var refreshControl = UIRefreshControl()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reorderButton.setTitle(LSCollection.Orders.reorderBtn, for: .normal)
        orderDetailLbl.text = LSCollection.Orders.orderDetails
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 0
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func showCancelOrder(show: Bool) {
        mainThread({
            self.cancelOrderView.isHidden = !show
        })
    }
    
    func showReorder(show: Bool) {
        mainThread({
            self.reorderView.isHidden = !show
        })
    }
    
    func addRefreshControl() {
        tableView.bounces = true
        tableView.alwaysBounceVertical = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefreshCalled), for: .valueChanged)
       // tableView.addSubview(refreshControl)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func pullToRefreshCalled() {
        self.handleViewActions?(.pullToRefreshCalled)
    }
    
    func showLoader(show: Bool) {
        mainThread({
            if show {
                //self.activityIndicator.startAnimating()
                self.bringSubviewToFront(self.loaderView)
                self.tableView.isHidden = true
                self.loaderView.isHidden = false
                self.activityIndicator.startAnimating()
            } else {
                //self.sendSubviewToBack(self.loaderView)
                self.activityIndicator.stopAnimating()
                self.loaderView.isHidden = true
                self.tableView.isHidden = false
            }
        })
    }
    
    func refreshTableView() {
        mainThread({
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    func changeHeightWithoutReload() {
        mainThread({
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        })
    }
    
    func showError(msg: String) {
        mainThread({
            let appError = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            appError.show(message: msg, view: self)
        })
    }
    
    private func showCartClearanceAlert() {
        mainThread({
            let count = CartUtility.getItemCount()
            let itemString = count > 1 ? "items" : "item"
            self.alert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 186))
            self.alert?.setTextAlignment(.left)
            self.alert?.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: nil)
            self.alert?.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: .right)
            self.alert?.configure(title: "Replace cart \(itemString)?", message: "Your cart contains \(itemString). Do you want to replace?", leftButtonTitle: LSCollection.SignUp.cancel, rightButtonTitle: LSCollection.SignUp.continueText, container: self)
            self.alert?.handleAction = { [weak self] in
                if $0 == .right {
                    self?.handleViewActions?(.reorderTrigger)
                }
            }
        })
    }
    
    func removePopup() {
        mainThread({
            self.alert?.removeFromContainer()
        })
    }
}
