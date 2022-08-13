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
    
    private var isImageLoading: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedView.isHidden = true
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainThread({ [weak self] in
            guard let `self` = self else { return }
            if self.isImageLoading {
                self.shimmerView.isHidden = false
                self.shimmerView.layoutIfNeeded()
                self.shimmerView.startShimmering()
            }
        })
    }
    
    func configure(item: MenuCategory) {
        let selectedLanguage = AppUserDefaults.selectedLanguage()
        itemLabel.text = selectedLanguage == .en ? (item.titleEnglish ?? "") : (item.titleArabic ?? "")
        itemLabel.textColor = (item.isSelectedInApp ?? false) ? AppColors.kuduThemeBlue : AppColors.ExploreMenuScreen.disabledText
        selectedView.isHidden = !(item.isSelectedInApp ?? false)
        itemImgView.setImageKF(imageString: item.menuImageUrl ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: false, loaderTintColor: .clear, completionHandler: { _ in
            mainThread { [weak self] in
                self?.isImageLoading = false
                self?.shimmerView.isHidden = true
                self?.shimmerView.stopShimmering()
            }
        })
    }
}
