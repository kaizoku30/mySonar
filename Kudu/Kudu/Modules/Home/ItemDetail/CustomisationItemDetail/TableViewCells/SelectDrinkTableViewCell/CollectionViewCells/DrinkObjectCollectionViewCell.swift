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
    @IBOutlet private weak var priceView: UIView!
    @IBOutlet private weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private let unselectedColor = UIColor(r: 173, g: 175, b: 178, alpha: 0.4)
    
    func configure(imgUrl: String, selectedState: Bool, price: Double) {
        drinkImgView.borderWidth = 0
        self.borderWidth = 1.5
        self.cornerRadius = 5
        self.borderColor = selectedState ? .clear : unselectedColor
        priceView.backgroundColor = selectedState ? AppColors.kuduThemeYellow : unselectedColor
        priceLabel.textColor = selectedState ? .white : .black
        priceLabel.text = "+SR \(price.round(to: 2).removeZerosFromEnd())"
        priceView.isHidden = price == 0
        drinkImgView.setImageKF(imageString: imgUrl, placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: true, loaderTintColor: .lightGray, completionHandler: nil)
        containerView.borderWidth = selectedState ? 1.5 : 1
        let colorRef = AppColors.ExploreMenuScreen.self
        containerView.borderColor = selectedState ? colorRef.selectedDrinkTypeBorderColor : colorRef.unselectedDrinkTypeBorderColor
        yellowGradientOverlay.backgroundColor = AppColors.kuduThemeYellow.withAlphaComponent(0.08)
        yellowGradientOverlay.isHidden = !selectedState
    }
}
