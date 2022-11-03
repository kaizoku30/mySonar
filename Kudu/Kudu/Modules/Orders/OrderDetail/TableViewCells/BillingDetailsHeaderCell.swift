//
//  BillingDetailsHeaderCell.swift
//  Kudu
//
//  Created by Admin on 13/10/22.
//

import UIKit

class BillingDetailsHeaderCell: UITableViewCell {
    @IBOutlet weak var billingDetailsLabel: UILabel!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBAction func dropDownButtonPressed(_ sender: Any) {
        self.expanded = !self.expanded
        self.updateExpandedConfig?(self.expanded)
    }
    
    private let upArrrow = UIImage(named: "k_orderStatusUpArrow")!
    private let downArrow = UIImage(named: "k_orderStatusDropDown")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.roundTopCorners(cornerRadius: 4)
    }
    
    var updateExpandedConfig: ((Bool) -> Void)?
    private var expanded = false
    
    func configure(expanded: Bool) {
        self.expanded = expanded
        dropDownButton.setImage(expanded ? upArrrow : downArrow, for: .normal)
    }
}
