//
//  FeedbackUploadedImageCell.swift
//  Kudu
//
//  Created by Admin on 22/07/22.
//

import UIKit
import NVActivityIndicatorView

class FeedbackUploadedImageCell: UITableViewCell {
    @IBOutlet weak var uploadedImg: UIImageView!
    @IBOutlet weak var deleteButton: AppButton!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var attachedPhotosLbl: UILabel!
    var deletePressed: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        attachedPhotosLbl.text = LocalizedStrings.Setting.attachedPhotos
        self.cornerRadius = 4
        deleteButton.handleBtnTap = { [weak self] in
            self?.deletePressed?()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(img: UIImage, isUploading: Bool) {
        uploadedImg.contentMode = .scaleAspectFill
        uploadedImg.image = img
        if isUploading {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }

}
