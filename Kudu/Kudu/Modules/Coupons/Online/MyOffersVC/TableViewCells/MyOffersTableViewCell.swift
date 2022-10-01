//
//  MyOffersTableViewCell.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import UIKit

class MyOffersTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var offerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }
    
    func configure(img: String) {
        offerImageView.setImageKF(imageString: img, placeHolderImage: AppImages.MainImages.placeholder16x9, loader: true, loaderTintColor: AppColors.kuduThemeYellow, completionHandler: nil)
    }
    
}
