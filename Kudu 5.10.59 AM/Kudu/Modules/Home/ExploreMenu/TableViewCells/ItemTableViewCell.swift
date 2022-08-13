//
//  ItemTableViewCell.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import UIKit
import TTTAttributedLabel

class ItemTableViewCell: UITableViewCell {
    @IBOutlet private weak var customisableLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: TTTAttributedLabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var addButton: AppButton!
    @IBOutlet private weak var favouriteButton: AppButton!
    @IBOutlet private weak var itemImgView: UIImageView!
    @IBOutlet private weak var incrementorStackView: UIStackView!
    @IBOutlet private weak var deleteBtn: AppButton!
    @IBOutlet private weak var plusButton: AppButton!
    @IBOutlet private weak var counterLabelButton: AppButton!
    @IBOutlet private weak var shimmerView: UIView!
    
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        
        if AppUserDefaults.value(forKey: .loginResponse).isNil {
            triggerLoginFlow?()
            return
        }
        
        if let item = item, let likeStatus = item.isLikedInApp.isNotNil ? item.isLikedInApp : false {
            self.item?.isLikedInApp = !likeStatus
            let image = !likeStatus ? AppImages.MainImages.likedHeart : AppImages.MainImages.unlikedHeart
            favouriteButton.setImage(image, for: .normal)
            likeStatusUpdated?(self.item?.isLikedInApp ?? false, self.item?._id ?? "")
        }
        if let item = resultItem, let likeStatus = item.isLikedInApp.isNotNil ? item.isLikedInApp : false {
            self.resultItem?.isLikedInApp = !likeStatus
            let image = !likeStatus ? AppImages.MainImages.likedHeart : AppImages.MainImages.unlikedHeart
            favouriteButton.setImage(image, for: .normal)
            likeStatusUpdated?(self.resultItem?.isLikedInApp ?? false, self.resultItem?._id ?? "")
        }
    }
    
    @IBAction private func deleteButtonPressed(_ sender: Any) {
        if itemCartCount > 0 {
            itemCartCount -= 1
            updateButtonView()
        }
    }
    
    @IBAction private func plusButtonPressed(_ sender: Any) {
        itemCartCount += 1
        updateButtonView()
    }
    
    @IBAction private func addButtonPressed(_ sender: Any) {
        itemCartCount += 1
        updateButtonView()
    }
    
    var openItemDetailForSearch: ((MenuSearchResultItem) -> Void)?
    var openItemDetail: ((MenuItem) -> Void)?
    var likeStatusUpdated: ((Bool, String) -> Void)?
    var triggerLoginFlow: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performRouting)))
        addButton.setTitle(LocalizedStrings.ExploreMenu.addButton, for: .normal)
        customisableLabel.attributedText = NSAttributedString(string: LocalizedStrings.ExploreMenu.customizable, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
    
    @objc private func performRouting() {
        if let item = resultItem {
            self.openItemDetailForSearch?(item)
        }
        if let item = item {
            self.openItemDetail?(item)
        }
    }
    
    private var isImageLoading: Bool = true
    private var isFavourite: Bool = false
    private var item: MenuItem?
    private var resultItem: MenuSearchResultItem?
    private var itemCartCount: Int = 0
    
    var itemCartUpdated: ((Int, Int) -> Void)?
    
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
    
    func configure(_ item: MenuItem) {
        self.item = item
        self.customisableLabel.isHidden = !(item.isCustomised ?? false)
        self.priceLabel.text = "SR " + "\((item.price ?? 0.0).round(to: 2).removeZerosFromEnd())"
        descriptionLabel.text = AppUserDefaults.selectedLanguage() == .en ? (item.descriptionEnglish ?? "") : (item.descriptionArabic ?? "")
        if AppUserDefaults.selectedLanguage() == .en {
            let trunc = NSMutableAttributedString(string: "..\(LocalizedStrings.ExploreMenu.moreLabel)")
            trunc.addAttribute(NSAttributedString.Key.font, value: AppFonts.mulishBold.withSize(12), range: NSMakeRange(0, 6))
            trunc.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColors.kuduThemeBlue, range: NSMakeRange(0, 6))
            descriptionLabel.attributedTruncationToken = trunc
        } else {
            let trunc = NSMutableAttributedString(string: "\(LocalizedStrings.ExploreMenu.moreLabel)..")
            trunc.addAttribute(NSAttributedString.Key.font, value: AppFonts.mulishBold.withSize(12), range: NSMakeRange(0, 6))
            trunc.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColors.kuduThemeBlue, range: NSMakeRange(0, 6))
            descriptionLabel.attributedTruncationToken = trunc
        }
        descriptionLabel.numberOfLines = 3
        descriptionLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.itemNameLabel.text = AppUserDefaults.selectedLanguage() == .en ? (item.nameEnglish ?? "") : (item.nameArabic ?? "")
        self.itemImgView.setImageKF(imageString: (item.itemImageUrl ?? ""), placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: false, loaderTintColor: .clear, completionHandler: { [weak self] _ in
            mainThread {
                self?.isImageLoading = false
                self?.shimmerView.isHidden = true
                self?.shimmerView.stopShimmering()
            }
        })
        self.itemCartCount = item.currentCartCountInApp ?? 0
        self.updateButtonView()
        let likeStatus = item.isLikedInApp ?? false
        let image = likeStatus ? AppImages.MainImages.likedHeart : AppImages.MainImages.unlikedHeart
        favouriteButton.setImage(image, for: .normal)
    }
    
    func configure(_ item: MenuSearchResultItem) {
        self.resultItem = item
        self.customisableLabel.isHidden = !(item.isCustomised ?? false)
        self.priceLabel.text = "SR " + "\((item.price ?? 0.0).round(to: 2).removeZerosFromEnd())"
        descriptionLabel.text = AppUserDefaults.selectedLanguage() == .en ? (item.descriptionEnglish ?? "") : (item.descriptionArabic ?? "")
        if AppUserDefaults.selectedLanguage() == .en {
            let trunc = NSMutableAttributedString(string: "..\(LocalizedStrings.ExploreMenu.moreLabel)")
            trunc.addAttribute(NSAttributedString.Key.font, value: AppFonts.mulishBold.withSize(12), range: NSMakeRange(0, 6))
            trunc.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColors.kuduThemeBlue, range: NSMakeRange(0, 6))
            descriptionLabel.attributedTruncationToken = trunc
        } else {
            let trunc = NSMutableAttributedString(string: "\(LocalizedStrings.ExploreMenu.moreLabel)..")
            trunc.addAttribute(NSAttributedString.Key.font, value: AppFonts.mulishBold.withSize(12), range: NSMakeRange(0, 6))
            trunc.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColors.kuduThemeBlue, range: NSMakeRange(0, 6))
            descriptionLabel.attributedTruncationToken = trunc
        }
        descriptionLabel.numberOfLines = 3
        descriptionLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.itemNameLabel.text = AppUserDefaults.selectedLanguage() == .en ? (item.nameEnglish ?? "") : (item.nameArabic ?? "")
        self.itemImgView.setImageKF(imageString: (item.itemImageUrl ?? ""), placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: false, loaderTintColor: .clear, completionHandler: { [weak self] _ in
            mainThread {
                self?.isImageLoading = false
                self?.shimmerView.isHidden = true
                self?.shimmerView.stopShimmering()
            }
        })
        self.itemCartCount = item.currentCartCountInApp ?? 0
        self.updateButtonView()
    }

    private func updateButtonView() {
        self.addButton.isHidden = itemCartCount != 0
        self.counterLabelButton.setTitle("\(itemCartCount)", for: .normal)
        self.incrementorStackView.isHidden = itemCartCount == 0
    }
    
    func configureLoading() {
        self.isImageLoading = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
