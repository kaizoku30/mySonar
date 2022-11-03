//
//  HomeRecommendationCollectionViewCell.swift
//  Kudu
//
//  Created by Admin on 07/07/22.
//

import UIKit

class HomeRecommendationCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var objImgView_shimmerView: UIView!
    @IBOutlet private weak var objText: UILabel!
    @IBOutlet private weak var objImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ obj: RecommendationObject) {
        objImgView.backgroundColor = .clear
        objText.text = AppUserDefaults.selectedLanguage() == .en ? obj.item?.first?.nameEnglish ?? "" : obj.item?.first?.nameArabic ?? ""
        objImgView_shimmerView.startShimmering()
        objImgView.setImageKF(imageString: obj.image ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: false, loaderTintColor: .clear, completionHandler: { [weak self] _ in
            mainThread {
                self?.objImgView_shimmerView.isHidden = true
            }
        })
    }
    
    func configureForNoObj() {
        objImgView_shimmerView.startShimmering()
        objImgView_shimmerView.isHidden = false
    }
}
