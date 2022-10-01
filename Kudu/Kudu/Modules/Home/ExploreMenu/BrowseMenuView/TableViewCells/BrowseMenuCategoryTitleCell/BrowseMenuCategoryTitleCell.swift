//
//  BrowseMenuCategoryTitleCell.swift
//  Kudu
//
//  Created by Admin on 12/08/22.
//

import UIKit

class BrowseMenuCategoryTitleCell: UITableViewCell {
    @IBOutlet private weak var categoryTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(_ name: String) {
        categoryTitleLabel.text = name
    }
    
}
