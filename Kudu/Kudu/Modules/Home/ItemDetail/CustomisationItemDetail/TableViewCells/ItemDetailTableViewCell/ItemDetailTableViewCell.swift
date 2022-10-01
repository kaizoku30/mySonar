//
//  ItemDetailTableViewCell.swift
//  Kudu
//
//  Created by Admin on 24/08/22.
//

import UIKit

class ItemDetailTableViewCell: UITableViewCell {
    @IBOutlet private weak var allergenCollection: HorizontallyExpandableCollection!
    @IBOutlet private weak var actionSheet: UIView!
    @IBOutlet private weak var itemImgView: UIImageView!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var itemPriceLabel: UILabel!
    @IBOutlet private weak var itemDescriptionView: UIView!
    @IBOutlet private weak var itemDescriptionLabel: UILabel!
    @IBOutlet private weak var allergenContainerView: UIView!
    @IBOutlet private weak var allergenceTitleLabel: UILabel!
    
    private var allergenArray: [AllergicComponent] = []
    private var allergenViewToggled: ((Bool) -> Void)?
    private var item: MenuItem?
    private var allergenExpandedState: Bool = false
    private var containerWidth: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(item: MenuItem, expandedState: Bool, containerWidth: CGFloat) {
        self.allergenExpandedState = expandedState
        self.item = item
        self.containerWidth = containerWidth
        setData()
    }
    
}

extension ItemDetailTableViewCell {
    private func setData() {
        guard let item = item else {
            return
        }
        self.allergenArray = item.allergicComponent ?? []
        allergenceTitleLabel.isHidden = self.allergenArray.isEmpty
        allergenContainerView.isHidden = self.allergenArray.isEmpty
        let name = AppUserDefaults.selectedLanguage() == .en ? item.nameEnglish ?? "" : item.nameArabic ?? ""
        var description = AppUserDefaults.selectedLanguage() == .en ? item.descriptionEnglish ?? "" : item.descriptionArabic ?? ""
        if let calorie = item.calories, calorie > 0 {
            description.append(" (\(calorie)Kcal)")
        }
        itemDescriptionView.isHidden = description.isEmpty
        self.itemNameLabel.text = name
        self.itemPriceLabel.text = "SR " + (item.price ?? 0.0).round(to: 2).removeZerosFromEnd()
        self.itemDescriptionLabel.text = description
        self.itemDescriptionLabel.adjustsFontSizeToFitWidth = true
        self.itemImgView.setImageKF(imageString: item.itemImageUrl ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: false, loaderTintColor: .clear, completionHandler: nil)
        allergenCollection.configure(allergenArray: self.allergenArray, expandedState: self.allergenExpandedState, containerWidth: self.containerWidth)
        allergenCollection.allergenToggled = { [weak self] (expandedState) in
            self?.allergenExpandedState = expandedState
            self?.allergenViewToggled?(expandedState)
        }
    }
}
