//
//  FeedbackUploadImageCell.swift
//  Kudu
//
//  Created by Admin on 22/07/22.
//

import UIKit
import NVActivityIndicatorView

class FeedbackUploadImageCell: UITableViewCell {

	@IBOutlet private weak var uploadingButtonView: UIView!
	@IBOutlet private weak var cellImgView: UIImageView!
    @IBOutlet private weak var label: UILabel!
    
	var showAlert: (() -> Void)?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        label.text = LocalizedStrings.Setting.uploadPhoto
        cellImgView.cornerRadius = 4
		uploadingButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openAlert)))
        // Initialization code
    }
	
	@objc private func openAlert() {
		showAlert?()
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
