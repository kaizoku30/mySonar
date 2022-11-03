//
//  CategoryResultTableViewCell.swift
//  Kudu
//
//  Created by Admin on 28/07/22.
//

import UIKit

class ExploreSearchCategoryResultCell: UITableViewCell {
    @IBOutlet weak var categoryImgView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categoryItemCountsLabel: UILabel!
    
    @IBOutlet weak var mainContentContainerView: UIView!
    var performOperation: ((MenuSearchResultItem) -> Void)?
    
    private var item: MenuSearchResultItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performRouting)))
    }
    
    @objc private func performRouting() {
        if let item = item {
            self.performOperation?(item)
        }
    }
    
    func configure(_ category: MenuSearchResultItem) {
        item = category
        let title = AppUserDefaults.selectedLanguage() == .en ? category.titleEnglish : category.titleArabic
        categoryNameLabel.text = title ?? ""
        categoryItemCountsLabel.text = "\(category.itemCount ?? 0) Items"
        categoryImgView.setImageKF(imageString: category.menuImageUrl ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: false, loaderTintColor: .clear, completionHandler: nil)
        grayScaleContent(available: TimeRange.checkIfCategoryAllowedTimeWise(category: category))
        self.isUserInteractionEnabled = TimeRange.checkIfCategoryAllowedTimeWise(category: category)
    }
    
    private func grayScaleContent(available: Bool) {
//        addButton.backgroundColor = available ? AppColors.kuduThemeBlue : AppColors.ExploreMenuScreen.addButtonUnavailable
//        addButton.setTitleColor(available ? .white : AppColors.ExploreMenuScreen.addButtonUnavailableTextColor, for: .normal)
//        addButton.titleLabel?.lineBreakMode = .byWordWrapping
//        addButton.setFont(available ? AppFonts.mulishMedium.withSize(14) : AppFonts.mulishMedium.withSize(10))
//        addButton.titleLabel?.textAlignment = .center
//        addButton.setTitle(available ? LocalizedStrings.ExploreMenu.addButton : "Not\nAvailable", for: .normal)
        self.categoryImgView.image = available ? self.categoryImgView.image : self.categoryImgView.image?.grayscale()
        self.mainContentContainerView.backgroundColor = available ? AppColors.white : AppColors.black.withAlphaComponent(0.025)
        self.mainContentContainerView.cornerRadius = 4
//        self.gradientImageView.image = available ? AppImages.ExploreMenu.cellGradient : self.gradientImageView.image?.grayscale()
    }
    
}
