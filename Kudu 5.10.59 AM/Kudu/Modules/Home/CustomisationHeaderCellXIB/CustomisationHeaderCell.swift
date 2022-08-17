//
//  CustomisationHeaderCell.swift
//  Kudu
//
//  Created by Admin on 09/08/22.
//

import UIKit

class CustomisationHeaderCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var requiredBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font = AppFonts.mulishBold.withSize(14)
        subTitleLabel.font = AppFonts.mulishRegular.withSize(12)
        requiredBtn.setFont(AppFonts.mulishSemiBold.withSize(10))
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
