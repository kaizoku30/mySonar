//
//  ItemCarouselCell.swift
//  Kudu
//
//  Created by Admin on 28/09/22.
//

import UIKit

class ItemCarouselCell: UICollectionViewCell {
    
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var imgView: UIImageView!
    @IBOutlet private weak var infoContainerView: UIView!
    
    @IBAction private func addButtonPressed(_ sender: Any) {
        addItem?(menuItem)
    }
    
    var addItem: ((MenuItem) -> Void)?
    private var menuItem: MenuItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoContainerView.dropShadow(scale: true, color: UIColor(r: 45, g: 118, b: 159, alpha: 0.03))
    }
    
    func configure(_ obj: MenuItem) {
        self.menuItem = obj
        let price = obj.price ?? 0
        priceLabel.text = "SR \(price.round(to: 2).removeZerosFromEnd())"
        let lang = AppUserDefaults.selectedLanguage()
        let name = lang == .en ? obj.nameEnglish ?? "" : obj.nameArabic ?? ""
        self.itemNameLabel.text = name
        self.imgView.setImageKF(imageString: obj.itemImageUrl ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: true, loaderTintColor: AppColors.kuduThemeYellow, completionHandler: nil)
    }
}
