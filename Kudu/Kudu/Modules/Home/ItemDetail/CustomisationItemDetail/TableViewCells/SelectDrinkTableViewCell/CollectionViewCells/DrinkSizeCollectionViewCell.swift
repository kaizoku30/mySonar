//
//  DrinkTypeCollectionViewCell.swift
//  Kudu
//
//  Created by Admin on 10/08/22.
//

import UIKit

class DrinkSizeCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var drinkSizeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(drinkSize: DrinkSize, selectedState: Bool) {
        drinkSizeLabel.text = drinkSize.title
        if selectedState {
            self.layer.borderColor = AppColors.ExploreMenuScreen.selectedDrinkSize.cgColor
            self.drinkSizeLabel.textColor = AppColors.ExploreMenuScreen.selectedDrinkSize
            self.layer.backgroundColor = AppColors.ExploreMenuScreen.selectedDrinkSizeBackgroundColor.cgColor
        } else {
            layer.borderColor = AppColors.ExploreMenuScreen.unselectedDrinkSizeBorderColor.cgColor
            drinkSizeLabel.textColor = AppColors.ExploreMenuScreen.unselectedDrinkSizeTextColor
            layer.backgroundColor = AppColors.ExploreMenuScreen.unselectedDrinksizeBackgroundColor.cgColor
        }
    }
}
