//
//  NotificationVC.swift
//  Kudu
//
//  Created by Admin on 01/08/22.
//

import UIKit

class NotificationVC: UIViewController {
    @IBOutlet var baseView: NotificationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueCell(with: NotificationListingTableViewCell.self)
        cell.selectionStyle = .none
        cell.notificationTitle.text = allNotification[indexPath.row].notificationTitle
        cell.notificationDate.text = allNotification[indexPath.row].notificationDate
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotification.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.automaticHeight
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            tableView.beginUpdates()
            allNotification.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            completionHandler(true)
        }
        deleteAction.image = UIImage(named: "k_deleteImage")
        deleteAction.backgroundColor = UIColor(named: "deleteButtonColor")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
