//
//  MyOrderListView.swift
//  Kudu
//
//  Created by Admin on 10/10/22.
//

import UIKit

class MyOrderListView: UIView {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var noResultView: UIView!
    
    @IBAction private func backButtonPressed(_ sender: Any) {
        self.handleViewActions?(.backButtonPressed)
    }
    var alert: AppPopUpView?
    var handleViewActions: ((ViewAction) -> Void)?
    private lazy var refreshControl = UIRefreshControl()
    
    enum ViewAction {
        case pullToRefreshCalled
        case backButtonPressed
        case reorderTrigger
    }
    
    enum Sections: Int, CaseIterable {
        case activeOrders = 0
        case previousOrders
        case loadingPagination
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addRefreshControl()
        refreshControl.tintColor = AppColors.kuduThemeBlue
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 0
    }
    
    func addRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefreshCalled), for: .valueChanged)
    }
    
    @objc private func pullToRefreshCalled() {
        self.handleViewActions?(.pullToRefreshCalled)
    }
    
    func showNoResult(_ show: Bool) {
        mainThread({
            self.tableView.isHidden = show
        })
    }
    
    func refreshTable() {
        mainThread {
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func refreshIndex(_ index: Int, section: Sections) {
        mainThread({
            self.tableView.reloadRows(at: [IndexPath(row: index, section: section.rawValue)], with: .fade)
        })
    }
    
    func restrictInteraction(_ restrict: Bool) {
        mainThread({
            self.tableView.isUserInteractionEnabled = !restrict
        })
    }
    
    func showError(msg: String) {
        mainThread {
            let apperror = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            apperror.show(message: msg, view: self)
        }
    }
    
    func showCartClearanceAlert() {
        mainThread({
            let count = CartUtility.getItemCount()
            let itemString = count > 1 ? "items" : "item"
            self.alert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 186))
            self.alert?.setTextAlignment(.left)
            self.alert?.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: nil)
            self.alert?.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: .right)
            self.alert?.configure(title: "Replace cart \(itemString)?", message: "Your cart contains \(itemString). Do you want to replace?", leftButtonTitle: "Cancel", rightButtonTitle: "Continue", container: self)
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
