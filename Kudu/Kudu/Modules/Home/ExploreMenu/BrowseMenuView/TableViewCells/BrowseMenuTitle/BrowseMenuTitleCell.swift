//
//  BrowseMenuTitleCell.swift
//  Kudu
//
//  Created by Admin on 12/08/22.
//

import UIKit

class BrowseMenuTitleCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        titleLabel.text = LSCollection.BrowseMenu.browseMenu
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
