//
//  SuggestionTableViewCell.swift
//  Kudu
//
//  Created by Admin on 28/07/22.
//

import UIKit

class SuggestionTableViewCell: UITableViewCell {
    @IBOutlet weak var cellImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var resultTypeLabel: UILabel!
    
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
    
    func configure(_ result: MenuSearchResultItem) {
        self.item = result
        if result.isItem ?? false {
            let name = AppUserDefaults.selectedLanguage() == .en ? result.nameEnglish : result.nameArabic
            nameLabel.text = name ?? ""
            let categoryName = AppUserDefaults.selectedLanguage() == .en ? result.titleEnglish ?? "" : result.titleArabic ?? ""
            resultTypeLabel.text = "\(categoryName)"
            cellImgView.setImageKF(imageString: result.itemImageUrl ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: false, loaderTintColor: .clear, completionHandler: nil)
        } else {
            let title = AppUserDefaults.selectedLanguage() == .en ? result.titleEnglish : result.titleArabic
            nameLabel.text = title ?? ""
            resultTypeLabel.text = LSCollection.SearchMenu.inCategory
            cellImgView.setImageKF(imageString: result.menuImageUrl ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: false, loaderTintColor: .clear, completionHandler: nil)
        }
    }
}
