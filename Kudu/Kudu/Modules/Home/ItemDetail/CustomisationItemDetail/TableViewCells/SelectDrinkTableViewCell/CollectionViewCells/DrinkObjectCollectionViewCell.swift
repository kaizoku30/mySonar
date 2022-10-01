//
//  DrinkObjectCollectionViewCell.swift
//  Kudu
//
//  Created by Admin on 24/08/22.
//

import UIKit
import Kingfisher

class DrinkObjectCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var drinkImgView: UIImageView!
    @IBOutlet private weak var yellowGradientOverlay: UIView!
    @IBOutlet private weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(imgUrl: String, selectedState: Bool) {
        drinkImgView.setImageKF(imageString: imgUrl, placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: true, loaderTintColor: .lightGray, completionHandler: nil)
        containerView.borderWidth = selectedState ? 1.5 : 1
        let colorRef = AppColors.ExploreMenuScreen.self
        containerView.borderColor = selectedState ? colorRef.selectedDrinkTypeBorderColor : colorRef.unselectedDrinkTypeBorderColor
        yellowGradientOverlay.backgroundColor = AppColors.kuduThemeYellow.withAlphaComponent(0.08)
        yellowGradientOverlay.isHidden = !selectedState
    }
}
