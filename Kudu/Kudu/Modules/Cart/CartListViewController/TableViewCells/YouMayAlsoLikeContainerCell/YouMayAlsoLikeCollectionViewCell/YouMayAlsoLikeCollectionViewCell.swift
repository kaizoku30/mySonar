//
//  YouMayAlsoLikeCollectionViewCell.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import UIKit

class YouMayAlsoLikeCollectionViewCell: UICollectionViewCell {
	@IBOutlet private weak var itemImageView: UIImageView!
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var customisableLabel: UILabel!
    
	@IBAction func addButtonPressed(_ sender: Any) {
		addYouMayAlsoLike?(object)
	}
	
	var addYouMayAlsoLike: ((YouMayAlsoLikeObject) -> Void)?
	private var object: YouMayAlsoLikeObject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customisableLabel.attributedText = NSAttributedString(string: LocalizedStrings.ExploreMenu.customizable, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
	
	func configure(_ object: YouMayAlsoLikeObject) {
		self.object = object
        customisableLabel.isHidden = !(object.itemDetails?.isCustomised ?? false)
		itemImageView.setImageKF(imageString: object.image ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: true, loaderTintColor: .yellow, completionHandler: nil)
		titleLabel.text = AppUserDefaults.selectedLanguage() == .en ? object.itemDetails?.nameEnglish ?? "" : object.itemDetails?.nameArabic ?? ""
		priceLabel.text = "SR \((object.itemDetails?.price ?? 0.0).round(to: 2).removeZerosFromEnd())"
	}
}

class YouMayAlsoLikeShimmerCell: UICollectionViewCell {
	@IBOutlet private weak var shimmerView: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		shimmerView.startShimmering()
	}
}
