//
//  DrinkTypeCollectionViewCell.swift
//  Kudu
//
//  Created by Admin on 10/08/22.
//

import UIKit

class DrinkTypeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var drinkTypeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.borderColor = AppColors.ExploreMenuScreen.unselectedDrinkTypeBorderColor.cgColor
        layer.backgroundColor = AppColors.ExploreMenuScreen.unselectedDrinksizeBackgroundColor.cgColor
        
    }

}
