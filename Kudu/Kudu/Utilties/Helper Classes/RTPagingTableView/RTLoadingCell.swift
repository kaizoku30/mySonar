//
//  RTLoadingCell.swift
//  Created by Admin on 27/01/22.
//

import UIKit

class RTLoadingCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func animateLoader(_ customColor: UIColor) {
        activityIndicator.color = customColor
        mainThread { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }
    
}
