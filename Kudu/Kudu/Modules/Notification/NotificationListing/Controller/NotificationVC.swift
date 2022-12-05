//
//  NotificationVC.swift
//  Kudu
//
//  Created by Admin on 01/08/22.
//

import UIKit

class NotificationVC: BaseVC {
    
    @IBOutlet var baseView: NotificationView!
    private var viewModel: NotificationVM = NotificationVM()
    private var isLoading: Bool = false
    private var isFetchingData: Bool = true
    private var pagenumber: Int = 1
    private var limit: Int = 10
    private var indexForDeletion: Int?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
        self.baseView.refreshTable()
        self.baseView.clearButton.isHidden = true
        self.viewModel.fetchNotifications(page: 1, limit: 10)
        baseView.dismiss = { [weak self] in
            self?.pop()
        }
        baseView.clearAll = { [weak self] in
            self?.viewModel.deleteAllNotifications { _ in
                self?.viewModel.allNotifications = []
                self?.baseView.refreshTable()
                self?.baseView.showNoResult()
            }
            
        }
    }
}

extension NotificationVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFetchingData {
            return 1
        }
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isFetchingData {
            let cell = tableView.dequeueCell(with: NotificationShimmerCell.self)
            return cell
        }
        
        if indexPath.section == 0 {
            if indexPath.row == indexForDeletion ?? -1 {
                let cell = tableView.dequeueCell(with: NotificationShimmerCell.self)
                return cell
            }
            let cell =  tableView.dequeueCell(with: NotificationListingTableViewCell.self)
            let data = self.viewModel.allNotifications[indexPath.row]
            cell.configureCell(indexPath: indexPath, data: data)
            return cell
        } else {
            let cell = tableView.dequeueCell(with: NotificationShimmerCell.self)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFetchingData {
            return 10
        }
        if section == 0 {
            return self.viewModel.allNotifications.count
        } else {
            return self.viewModel.allNotifications.count < self.viewModel.total ? 1 : 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.automaticHeight
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if isFetchingData {
            return nil
        }
        
        if indexPath.section == 0 && isLoading == false {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
                self?.baseView.showDeleteSingleConfirmation {
                    self?.indexForDeletion = indexPath.row
                    self?.baseView.tableView.isUserInteractionEnabled = false
                    self?.baseView.refreshTable()
                    self?.viewModel.deleteNotification(id: self?.viewModel.allNotifications[indexPath.row]._id ?? "", indexPath: indexPath) { _ in
                        self?.indexForDeletion = nil
                        self?.viewModel.allNotifications.remove(at: indexPath.row)
                        self?.baseView.refreshTable()
//                        tableView.beginUpdates()
//                        tableView.deleteRows(at: [indexPath], with: .none)
//                        tableView.endUpdates()
                        if tableView.numberOfRows(inSection: 0) == 0 {
                            self?.baseView.showNoResult()
                        }
                        self?.baseView.tableView.isUserInteractionEnabled = true
                        completionHandler(true)
                    }
                }
            }
            deleteAction.image = UIImage(named: "k_deleteImage")
            deleteAction.backgroundColor = UIColor(named: "deleteButtonColor")
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 && isLoading == false && isFetchingData == false && viewModel.allNotifications.count < viewModel.total && !viewModel.allNotifications.isEmpty {
            debugPrint("Hit Pagination")
            self.pagenumber += 1
            self.isLoading = true
            self.viewModel.fetchNotifications(page: self.pagenumber, limit: self.limit)
        }
    }
}

extension NotificationVC: NotificationVMDlegate {
    
    func deleteNotification(message: String, indexPath: IndexPath) {
        
    }
    
    func error(message: String) {
        
    }
    
    func updateList(list: [NotificationList]) {
        DataManager.shared.setNotificationBellStatus(false)
        self.isLoading = false
        self.isFetchingData = false
        if self.viewModel.allNotifications.isEmpty {
            self.baseView.showNoResult()
        } else {
            self.baseView.clearButton.isHidden = false
        }
        self.baseView.refreshTable()
    }
}
