//
//  HorizontallyExpandableCollectionViewCell.swift
//  ExpandableHorizontalCollectionProject
//
//  Created by Admin on 12/08/22.
//

import UIKit

class HorizontallyExpandableCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var roundImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageContainerView.backgroundColor = AppColors.AllergenView.collapsed
        imageContainerView.layer.cornerRadius = 12
        expanded = false
        stackView.isHidden = true
    }
    
    private var expanded = false

    func configure(expand: Bool, text: String, image: String) {
        //roundImageView.image = UIImage(named: "k_allergen_mustardExample")
        roundImageView.setImageKF(imageString: image, placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: false, loaderTintColor: .clear, completionHandler: nil)
        if expand {
            label.text = text
            stackView.isHidden = false
            self.imageContainerView.layer.cornerRadius = 0
            self.layer.cornerRadius = 12
            self.backgroundColor = AppColors.AllergenView.expanded
            imageContainerView.backgroundColor = .clear
        } else {
            self.stackView.isHidden = true
            self.layer.cornerRadius = 0
            self.imageContainerView.layer.cornerRadius = 12
            self.backgroundColor = AppColors.clear
            imageContainerView.backgroundColor = AppColors.AllergenView.collapsed
        }
    }
    
}
