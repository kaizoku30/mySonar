//
//  HomeOfferDealCollectionViewCell.swift
//  Kudu
//
//  Created by Admin on 07/07/22.
//

import UIKit

class HomeOfferDealCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var shimmer_imageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(item: GeneralPromoItem?) {
        imageView.isHidden = true
        shimmer_imageView.startShimmering()
        guard let item = item else {
            return
        }
        imageView.setImageKF(imageString: item.bannerUrl ?? "", placeHolderImage: AppImages.Home.footerImg, loader: false, loaderTintColor: .clear, completionHandler: { [weak self] _ in
            self?.imageView.isHidden = false
            self?.shimmer_imageView.stopShimmering()
        })
        
    }
    
    func configureForInStorePromos() {
        imageView.isHidden = false
        imageView.stopShimmering()
        imageView.image = UIImage(named: "k_promo_tempPlaceholder")
        imageView.contentMode = .scaleAspectFill
    }

}
