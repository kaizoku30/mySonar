//
//  GuestProfileActionCell.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit

class GuestProfileActionCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}
