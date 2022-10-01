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
    }
    
}
