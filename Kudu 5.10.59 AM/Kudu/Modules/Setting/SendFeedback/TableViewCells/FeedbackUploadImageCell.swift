//
//  FeedbackUploadImageCell.swift
//  Kudu
//
//  Created by Admin on 22/07/22.
//

import UIKit
import NVActivityIndicatorView

class FeedbackUploadImageCell: UITableViewCell {

    @IBOutlet weak var cellImgView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        label.text = LocalizedStrings.Setting.uploadPhoto
        cellImgView.cornerRadius = 4
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
