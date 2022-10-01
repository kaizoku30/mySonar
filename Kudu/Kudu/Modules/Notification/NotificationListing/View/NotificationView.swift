//
//  NotificationView.swift
//  Kudu
//
//  Created by Admin on 01/08/22.
//

import UIKit

class NotificationView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notificationTitle: UILabel!
    @IBAction private func backButtonPressed(_ sender: Any) {
       // Implementation Pending
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableViewSetUp()
    }
    
    private func tableViewSetUp() {
        tableView.separatorStyle = .none
        tableView.registerCell(with: NotificationListingTableViewCell.self)
    }
}
