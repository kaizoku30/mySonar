//
//  MyOffersView.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import UIKit

class MyOffersView: UIView {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noResultView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction private func backButtonPress(_ sender: Any) {
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
    
    func showNoResult() {
        mainThread {
            self.noResultView.isHidden = false
            self.bringSubviewToFront(self.noResultView)
        }
    }
}
