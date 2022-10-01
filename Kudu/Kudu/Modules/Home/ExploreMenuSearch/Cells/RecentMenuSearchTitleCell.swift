//
//  RecentMenuSearchTitleCell.swift
//  Kudu
//
//  Created by Admin on 28/07/22.
//

import UIKit

class RecentMenuSearchTitleCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        titleLabel.text = "Recent Searches"
    }
}
