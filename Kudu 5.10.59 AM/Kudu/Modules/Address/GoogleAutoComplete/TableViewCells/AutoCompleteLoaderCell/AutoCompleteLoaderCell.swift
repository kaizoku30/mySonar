//
//  AutoCompleteLoaderCell.swift
//  Kudu
//
//  Created by Admin on 15/07/22.
//

import UIKit
import NVActivityIndicatorView

class AutoCompleteLoaderCell: UITableViewCell {
    @IBOutlet private weak var loader: NVActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        loader.startAnimating()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
