//
//  NotificationView.swift
//  Kudu
//
//  Created by Admin on 01/08/22.
//

import UIKit

class NotificationView: UIView {
    
    @IBOutlet weak var noNotificaitonLbl: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet private weak var noResultView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var notificationTitle: UILabel!
    @IBAction private func backButtonPressed(_ sender: Any) {
       // Implementation Pending
        self.dismiss?()
    }
    
    @IBAction private func clearAllPressed(_ sender: Any) {
        if tableView.numberOfRows(inSection: 0) != 0 {
            showConfirmation()
        }
    }
    
    var dismiss: (() -> Void)?
    var clearAll: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        noNotificaitonLbl.text = LSCollection.CartScren.noNotificationYet
        notificationTitle.text = LSCollection.CartScren.notificationsTitle
        tableViewSetUp()
    }
    
    private func tableViewSetUp() {
        tableView.separatorStyle = .none
        tableView.registerCell(with: NotificationListingTableViewCell.self)
        clearButton.isHidden = false
    }
    
    func refreshTable() {
        mainThread {
            self.tableView.reloadData()
        }
    }
    
    func showNoResult() {
        mainThread {
            self.clearButton.isHidden = true
            self.noResultView.isHidden = false
            self.bringSubviewToFront(self.noResultView)
        }
    }
    
    private func showConfirmation() {
        let popUpAlert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 0))
        popUpAlert.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: .left)
        popUpAlert.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: nil)
        popUpAlert.configure(message: "Are you sure you want to clear all the notifications?", leftButtonTitle: LSCollection.MyAddress.delete, rightButtonTitle: LSCollection.MyAddress.cancel, container: self, setMessageAsTitle: true)
        popUpAlert.handleAction = { [weak self] in
            if $0 == .right { return }
            self?.clearAll?()
        }
    }
    
    func showDeleteSingleConfirmation(success: @escaping (() -> Void)) {
        let popUpAlert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 0))
        popUpAlert.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: .left)
        popUpAlert.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: nil)
        popUpAlert.configure(message: "Are you sure you want to delete notification?", leftButtonTitle: LSCollection.MyAddress.delete, rightButtonTitle: LSCollection.MyAddress.cancel, container: self, setMessageAsTitle: true)
        popUpAlert.handleAction = {
            if $0 == .right { return }
            success()
        }
    }
}
