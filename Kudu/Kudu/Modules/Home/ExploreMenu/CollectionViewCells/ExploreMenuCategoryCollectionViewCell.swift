//
//  ExploreMenuItemCollectionViewCell.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import UIKit

class ExploreMenuCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var itemImgView: UIImageView!
    @IBOutlet private weak var itemLabel: UILabel!
    @IBOutlet private weak var selectedView: UIView!
    @IBOutlet private weak var shimmerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedView.isHidden = true
		shimmerView.isHidden = true
		shimmerView.stopShimmering()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
	
	func shimmer() {
		shimmerView.isHidden = false
		shimmerView.startShimmering()
		itemLabel.isHidden = true
	}
    
    func configure(item: MenuCategory, selected: Bool) {
        let selectedLanguage = AppUserDefaults.selectedLanguage()
        itemLabel.text = selectedLanguage == .en ? (item.titleEnglish ?? "") : (item.titleArabic ?? "")
        itemLabel.textColor = selected ? AppColors.kuduThemeBlue : AppColors.ExploreMenuScreen.disabledText
        selectedView.isHidden = !selected
		itemImgView.setImageKF(imageString: item.menuImageUrl ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: true, loaderTintColor: AppColors.kuduThemeYellow, completionHandler: nil)
		itemLabel.isHidden = false
    }
}
