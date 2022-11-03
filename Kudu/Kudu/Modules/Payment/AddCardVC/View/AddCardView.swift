//
//  AddCardView.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit

class AddCardView: UIView {
    @IBAction private func backButtonPressed(_ sender: Any) {
        handleViewActions?(.backButtonPressed)
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    
    enum ViewActions {
        case backButtonPressed
    }
    
    enum Rows: Int, CaseIterable {
        case cardNumber = 0
        case expiryCvv
        case name
        case email
        case saveCard
        case payButton
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    
    func refreshRow(row: Rows) {
        mainThread({
            self.tableView.reloadData()
        })
    }
    
    func showError(msg: String) {
        mainThread({
            let appErrorToast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            appErrorToast.show(message: msg, view: self)
        })
    }
}
