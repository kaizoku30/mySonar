//
//  DrinkTypeCollectionViewCell.swift
//  Kudu
//
//  Created by Admin on 10/08/22.
//

import UIKit

class DrinkSizeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var drinkSizeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
//        layer.borderColor = AppColors.ExploreMenuScreen.beforeSeletionBorderColor.cgColor
//        self.drinkSizeLabel.textColor = AppColors.ExploreMenuScreen.beforeSelectionTextColor
        layer.borderColor = AppColors.ExploreMenuScreen.unselectedDrinkSizeBorderColor.cgColor
        drinkSizeLabel.textColor = AppColors.ExploreMenuScreen.unselectedDrinkSizeTextColor
        layer.backgroundColor = AppColors.ExploreMenuScreen.unselectedDrinksizeBackgroundColor.cgColor

    }
}
