//
//  MyOffersView.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import UIKit

class MyOffersView: UIView {
    @IBOutlet private weak var tableView: UITableView!
    
    @IBAction func backButtonPress(_ sender: Any) {
        dismissPressed?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpTableView()
    }
    
    var dismissPressed: (() -> Void)?
    
    private func setUpTableView() {
        tableView.registerCell(with: MyOffersTableViewCell.self)
    }
    
    func refreshTable() {
        mainThread {
            self.tableView.reloadData()
        }
    }
}
