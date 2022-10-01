//
//  ItemTableViewCell.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import UIKit
import TTTAttributedLabel

class ItemTableViewCell: UITableViewCell {
	@IBOutlet private weak var favouriteImageView: UIImageView!
	@IBOutlet private weak var gradientImageView: UIImageView!
    @IBOutlet private weak var customisableLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: TTTAttributedLabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var addButton: AppButton!
    @IBOutlet private weak var itemImgView: UIImageView!
    @IBOutlet private weak var incrementorStackView: UIStackView!
    @IBOutlet private weak var deleteBtn: AppButton!
    @IBOutlet private weak var plusButton: AppButton!
    @IBOutlet private weak var counterLabelButton: AppButton!
    @IBOutlet private weak var shimmerView: UIView!
   // @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var favouriteTapArea: AppButton!
	
	// MARK: Cell Functions
    var cartConflictForFavourites: ((Int, Int) -> Void)?
    var confirmCustomisationRepeatForFavourites: ((MenuItem, Int, Int) -> Void)?
    var cartCountUpdatedForFavourites: ((MenuItem, Int, Int) -> Void)?
	var confirmCustomisationRepeat: ((Int, MenuItem) -> Void)?
	var cartCountUpdated: ((Int, MenuItem) -> Void)?
	var openItemDetailForSearch: ((MenuSearchResultItem) -> Void)?
	var openItemDetail: ((MenuItem) -> Void)?
	var openItemDetailForFavourites: ((MenuItem, Int) -> Void)?
	var likeStatusUpdated: ((Bool, MenuItem) -> Void)?
	var triggerLoginFlow: (() -> Void)?
	var removeFromFavourites: ((String, Int) -> Void)?
    var cartConflict: ((Int, MenuItem) -> Void)?
    
	// MARK: Cell Properties
	//private var isImageLoading: Bool = true
	private var isFavourite: Bool = false
    private var item: MenuItem!
	private var resultItem: MenuSearchResultItem?
	private var index: Int = 0
    var itemCartCount: Int = 0
	private var favouriteFlow: Bool = false
    private var serviceType: APIEndPoints.ServicesType = .delivery
	
	private let unliked = UIImage(named: "k_unliked_final")!
	private let liked = UIImage(named: "k_liked_final")!
}

extension ItemTableViewCell {
	
	// MARK: IBActions
	@IBAction private func favouriteButtonTapped(_ sender: Any) {
        
        if AppUserDefaults.value(forKey: .loginResponse).isNil {
            triggerLoginFlow?()
            return
        }
        
        if let item = item {
            var likeStatus = item.isFavourites ?? false
            let cartCount = item.cartCount ?? 0
            let existingHashIds = AppUserDefaults.value(forKey: .hashIdsForFavourites) as? [String] ?? []
            if let templates = item.templates, templates.isEmpty == false, cartCount > 0 {
                likeStatus = existingHashIds.contains(templates.last?.hashId ?? "")
            } else {
                likeStatus = existingHashIds.contains(where: { $0 == MD5Hash.generateHashForTemplate(itemId: item._id ?? "", modGroups: nil) })
            }
			HapticFeedbackGenerator.triggerVibration(type: .lightTap)
            removeFromFavourites?(self.item?._id ?? "", self.index)
			if favouriteFlow { return }
			let newStatus = !likeStatus
			if newStatus {
				favouriteImageView.animationImages = AppGifs.likeAnim.animationImages
				favouriteImageView.animationDuration = 0.75
				favouriteImageView.animationRepeatCount = 1
				self.favouriteImageView.image = AppGifs.likeAnim.animationImages.last!
				favouriteImageView.startAnimating()
			} else {
				favouriteImageView.image = unliked
			}
            likeStatusUpdated?(!likeStatus, self.item)
        }
    }
    
    @IBAction private func deleteButtonPressed(_ sender: Any) {
        if itemCartCount > 0 {
            itemCartCount -= 1
            updateButtonView()
			HapticFeedbackGenerator.triggerVibration(type: .lightTap)
            self.cartCountUpdatedForFavourites?(self.item, itemCartCount, self.index)
            self.cartCountUpdated?(itemCartCount, self.item)
        }
    }
    
    @IBAction private func plusButtonPressed(_ sender: Any) {
        
        if item.isCustomised ?? false == true, let item = self.item {
          //  self.customisableLabel.isHidden = true
//            self.activityIndicator.startAnimating()
//            self.activityIndicator.isHidden = false
			HapticFeedbackGenerator.triggerVibration(type: .lightTap)
            confirmCustomisationRepeat?(itemCartCount + 1, item)
            confirmCustomisationRepeatForFavourites?(item, itemCartCount + 1, index)
            return
        }
        
        itemCartCount += 1
        updateButtonView()
		HapticFeedbackGenerator.triggerVibration(type: .lightTap)
        self.cartCountUpdatedForFavourites?(self.item, itemCartCount, self.index)
        self.cartCountUpdated?(itemCartCount, self.item)
    }
    
    @IBAction private func addButtonPressed(_ sender: Any) {
        
        if item?.isAvailable ?? true == false {
            return
        }
        
        if AppUserDefaults.value(forKey: .loginResponse).isNil {
            triggerLoginFlow?()
            return
        }
        
        if item.isCustomised ?? false {
            openItemDetail?(self.item)
            if let result = self.resultItem {
                openItemDetailForSearch?(result)
            }
            openItemDetailForFavourites?(self.item, self.index)
            return
        }
        
        if self.serviceType != CartUtility.getCartServiceType && CartUtility.fetchCart().isEmpty == false {
            self.cartConflict?(1, self.item)
            self.cartConflictForFavourites?(1, self.index)
            return
        }
        
        itemCartCount += 1
        updateButtonView()
		HapticFeedbackGenerator.triggerVibration(type: .lightTap)
        self.cartCountUpdatedForFavourites?(self.item, itemCartCount, self.index)
        cartCountUpdated?(itemCartCount, self.item)
    }
	
	@objc private func performRouting() {
		
		if item?.isAvailable ?? true == false {
			return
		}
		
		if let item = item {
			if item.isCustomised ?? false {
				//self.customisableLabel.isHidden = true
				//self.activityIndicator.startAnimating()
				//self.activityIndicator.isHidden = false
			}
			if let item = resultItem {
				self.openItemDetailForSearch?(item)
			}
			self.openItemDetail?(item)
			openItemDetailForFavourites?(self.item, self.index)
		}
	}
	
    func updateButtonView() {
        if itemCartCount == 0 || itemCartCount > 0 {
            self.deleteBtn.setImage(itemCartCount == 1 ? AppImages.ExploreMenu.delete : AppImages.ExploreMenu.minus, for: .normal)
            self.addButton.isHidden = itemCartCount != 0
            self.counterLabelButton.setTitle("\(itemCartCount)", for: .normal)
            self.incrementorStackView.isHidden = itemCartCount == 0
        }
	}
	
}

extension ItemTableViewCell {
    
	// MARK: Lifecycle Methods
	
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
		self.gradientImageView.isUserInteractionEnabled = true
        self.gradientImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performRouting)))
        addButton.setTitle(LocalizedStrings.ExploreMenu.addButton, for: .normal)
        customisableLabel.attributedText = NSAttributedString(string: LocalizedStrings.ExploreMenu.customizable, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
       // activityIndicator.isHidden = true
		favouriteImageView.image = nil
		shimmerView.isHidden = false
		if AppUserDefaults.selectedLanguage() == .ar {
			self.descriptionLabel.textAlignment = .right
		}
		descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performRouting)))
    }
	
	override func prepareForReuse() {
		super.prepareForReuse()
		favouriteImageView.image = nil
	}
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

	func shimmer() {
		self.shimmerView.startShimmering()
		self.shimmerView.isHidden = false
	}
	
	func stopShimmer() {
		self.shimmerView.stopShimmering()
		self.shimmerView.isHidden = false
	}
    
    func configure(_ item: MenuItem, serviceType: APIEndPoints.ServicesType) {
        self.serviceType = serviceType
        self.item = item
        setItemData(item: item)
        setFavouriteState()
		shimmerView.stopShimmering()
		shimmerView.isHidden = true
		
    }
    
    func configure(_ item: FavouriteItem, index: Int) {
        self.serviceType = APIEndPoints.ServicesType(rawValue: item.itemDetails?.servicesAvailable ?? "") ?? .delivery
        self.index = index
        self.item = MenuItem(menuId: item.itemDetails?.menuId ?? "", _id: item.itemId ?? "", nameArabic: item.itemDetails?.nameArabic ?? "", descriptionEnglish: item.itemDetails?.descriptionEnglish ?? "", nameEnglish: item.itemDetails?.nameEnglish ?? "", isCustomised: item.itemDetails?.isCustomised ?? false, price: item.itemDetails?.price ?? 0.0, descriptionArabic: item.itemDetails?.descriptionArabic ?? "", itemImageUrl: item.itemDetails?.itemImageUrl ?? "", allergicComponent: item.itemDetails?.allergicComponent ?? [], isAvailable: item.itemDetails?.isAvailable ?? false, modGroups: item.modGroups ?? [], cartCount: item.cartCount ?? 0, templates: item.templates ?? [], titleArabic: nil, titleEnglish: nil, itemId: item.itemDetails?.itemId ?? 0, servicesAvailable: item.itemDetails?.servicesAvailable, calories: item.itemDetails?.calories)
        setItemData(item: self.item)
		favouriteImageView.image = liked
		shimmerView.stopShimmering()
		shimmerView.isHidden = true
		
        //favouriteButton.setImage(AppImages.MainImages.likedHeart, for: .normal)
    }
	
	func configure(_ item: MenuSearchResultItem, serviceType: APIEndPoints.ServicesType) {
        self.serviceType = serviceType
		self.resultItem = item
		let menuItem = item.convertToMenuItem()
		self.item = menuItem
		setFavouriteState()
		setItemData(item: menuItem)
		shimmerView.stopShimmering()
		shimmerView.isHidden = true
		
	}
	
	func configureLoading() {
		//self.isImageLoading = true
	}
	
    private func setItemData(item: MenuItem) {
        self.customisableLabel.isHidden = !(item.isCustomised ?? false)
        self.priceLabel.text = "SR " + "\((item.price ?? 0.0).round(to: 2).removeZerosFromEnd())"
        descriptionLabel.text = AppUserDefaults.selectedLanguage() == .en ? (item.descriptionEnglish ?? "") : (item.descriptionArabic ?? "")
        if AppUserDefaults.selectedLanguage() == .en {
            let trunc = NSMutableAttributedString(string: "..\(LocalizedStrings.ExploreMenu.moreLabel)")
            trunc.addAttribute(NSAttributedString.Key.font, value: AppFonts.mulishBold.withSize(13), range: NSMakeRange(0, 6))
            trunc.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColors.kuduThemeBlue, range: NSMakeRange(0, 6))
            descriptionLabel.attributedTruncationToken = trunc
        } else {
            let trunc = NSMutableAttributedString(string: "\(LocalizedStrings.ExploreMenu.moreLabel)..")
            trunc.addAttribute(NSAttributedString.Key.font, value: AppFonts.mulishBold.withSize(13), range: NSMakeRange(0, 6))
            trunc.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColors.kuduThemeBlue, range: NSMakeRange(0, 6))
            descriptionLabel.attributedTruncationToken = trunc
        }
        descriptionLabel.numberOfLines = 3
        descriptionLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.itemNameLabel.text = AppUserDefaults.selectedLanguage() == .en ? (item.nameEnglish ?? "") : (item.nameArabic ?? "")
        self.grayScaleContent(available: item.isAvailable ?? true)
		self.itemImgView.setImageKF(imageString: (item.itemImageUrl ?? ""), placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: true, loaderTintColor: AppColors.kuduThemeYellow, completionHandler: nil)
        self.itemCartCount = item.cartCount ?? 0
        self.updateButtonView()
    }

    private func grayScaleContent(available: Bool) {
        addButton.backgroundColor = available ? AppColors.kuduThemeBlue : AppColors.ExploreMenuScreen.addButtonUnavailable
        addButton.setTitleColor(available ? .white : AppColors.ExploreMenuScreen.addButtonUnavailableTextColor, for: .normal)
        addButton.titleLabel?.lineBreakMode = .byWordWrapping
        addButton.setFont(available ? AppFonts.mulishMedium.withSize(14) : AppFonts.mulishMedium.withSize(10))
        addButton.titleLabel?.textAlignment = .center
        addButton.setTitle(available ? LocalizedStrings.ExploreMenu.addButton : "Not\nAvailable", for: .normal)
        self.itemImgView.image = available ? self.itemImgView.image : self.itemImgView.image?.grayscale()
        self.gradientImageView.image = available ? AppImages.ExploreMenu.cellGradient : self.gradientImageView.image?.grayscale()
    }
}

extension ItemTableViewCell {
	// MARK: Favourite Management
    func setFavouriteState() {
		var likeStatus = item.isFavourites ?? false
		let cartCount = item.cartCount ?? 0
		let existingHashIds = AppUserDefaults.value(forKey: .hashIdsForFavourites) as? [String] ?? []
		if let templates = item.templates, templates.isEmpty == false, cartCount > 0 {
			likeStatus = existingHashIds.contains(templates.last?.hashId ?? "")
		} else {
			let itemHash = MD5Hash.generateHashForTemplate(itemId: item._id ?? "", modGroups: nil)
			likeStatus = existingHashIds.contains(itemHash)
		}
		let image = likeStatus ? liked : unliked
		favouriteImageView.image = image
	}
	
	func configureForFavourites(index: Int) {
		self.favouriteFlow = true
		self.index = index
		self.backgroundColor = .clear
		self.contentView.backgroundColor = .clear
		self.item?.isFavourites = true
		favouriteImageView.image = liked
	}
}
