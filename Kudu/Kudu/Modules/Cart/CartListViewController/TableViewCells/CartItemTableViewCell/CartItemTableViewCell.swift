//
//  CartItemTableViewCell.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import UIKit

class CartItemTableViewCell: UITableViewCell {

    @IBOutlet weak var mainContentContainerView: UIView!
    @IBOutlet weak var productDetailStack: UIStackView!
	@IBOutlet weak var customisationDetails: UILabel!
	@IBOutlet weak var customisationDetailsView: UIView!
	@IBOutlet weak var productDetailArrow: UIImageView!
	@IBOutlet weak var productDetailView: UIView!
	@IBOutlet weak var favouriteImgView: UIImageView!
	@IBOutlet weak var itemTitle: UILabel!
	@IBOutlet weak var itemImgView: UIImageView!
	@IBOutlet weak var itemPrice: UILabel!
	@IBOutlet weak var customisedLabel: UILabel!
    @IBOutlet weak var imageContainerView: UIView!
    
	@IBOutlet weak var incrementorStackView: UIStackView!
	@IBOutlet weak var deleteBtn: AppButton!
	@IBOutlet weak var counterLabelButton: AppButton!
	@IBOutlet weak var addButton: AppButton!
	
    @IBOutlet weak var outOfStockLabel: UILabel!
    @IBOutlet weak var outOfStockView: UIView!
    @IBOutlet weak var productDetailsTitleLbl: UILabel!
    
    @IBOutlet weak var tempLoader: UIActivityIndicatorView!
    @IBOutlet weak var tempLoaderView: UIView!
    
    private var item: CartListObject!
	private let unliked = UIImage(named: "k_unliked_final")!
	private let liked = UIImage(named: "k_liked_final")!
	
	var cartCountUpdated: ((Int, Int) -> Void)?
	var likeStatusUpdated: ((Bool, Int) -> Void)?
	var toggleProductDetails: ((Bool, Int) -> Void)?
	var confirmCustomisationRepeat: ((Int) -> Void)?
    var confirmDelete: ((Int, Int) -> Void)?
    var handleTap: ((Int) -> Void)?
    
	private var index: Int = 0
	private var itemCartCount: Int = 0
	private var showingProductDetails = false
    private var backDropColor: UIColor!
    private let disabledBackDropColor = UIColor(r: 239, g: 239, b: 239, alpha: 0.1)
    
	override func awakeFromNib() {
        super.awakeFromNib()
		self.selectionStyle = .none
        productDetailsTitleLbl.text = LSCollection.CartScren.productDetails
		initialSetup()
        backDropColor = imageContainerView.backgroundColor
        // Initialization code
        mainContentContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentTapped)))
    }
    
    @objc private func contentTapped() {
        debugPrint("Content Tapped")
        if self.item.offerdItem ?? false { return }
        self.handleTap?(self.index)
    }
	
	private func initialSetup() {
		productDetailStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleProductDetailsView)))
		productDetailStack.isHidden = true
		productDetailView.isHidden = true
		customisationDetailsView.isHidden = true
		customisationDetails.numberOfLines = 0
        customisedLabel.attributedText = NSAttributedString(string: LSCollection.ExploreMenu.customizable, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: AppColors.kuduThemeBlue])
	}
	
	@objc private func toggleProductDetailsView() {
		toggleProductDetails?(!showingProductDetails, self.index)
		debugPrint("Toggle product details tapped")
	}

	private func updateButtonView() {
		self.deleteBtn.setImage(itemCartCount == 1 ? AppImages.ExploreMenu.delete : AppImages.ExploreMenu.minus, for: .normal)
		self.addButton.isHidden = itemCartCount != 0
		self.counterLabelButton.setTitle("\(itemCartCount)", for: .normal)
		self.incrementorStackView.isHidden = itemCartCount == 0
	}
	
    func configure(_ item: CartListObject, index: Int, isTempLoading: Bool) {
        self.counterLabelButton.stopBtnLoader(titleColor: .white)
        tempLoaderView.isHidden = !isTempLoading
        if isTempLoading {
            self.tempLoader.startAnimating()
        } else {
            self.tempLoader.stopAnimating()
        }
        let freeItem = item.offerdItem ?? false
		let lang = AppUserDefaults.selectedLanguage()
		self.index = index
		self.item = item
        if !freeItem {
            self.checkAndSetOutOfStock()
        }
		self.showingProductDetails = item.expandProductDetails ?? false
		let price: Double = (CartUtility.getPriceForAnItem(item).round(to: 2))
		itemPrice.text = "SR \(price.removeZerosFromEnd())"
		itemTitle.text = lang == .en ? (item.itemDetails?.nameEnglish ?? "") : (item.itemDetails?.nameArabic ?? "")
        itemImgView.setImageKF(imageString: (item.itemDetails?.itemImageUrl ?? ""), placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: true, loaderTintColor: AppColors.kuduThemeYellow, completionHandler: { [weak self] _ in
            if !freeItem {
                self?.checkAndSetOutOfStock()
            }
        })
		setFavouriteState()
		itemCartCount = item.quantity ?? 0
		updateButtonView()
        self.addButton.isHidden = true
        self.incrementorStackView.isHidden = freeItem
        self.itemPrice.text = freeItem ? "SR 0" : self.itemPrice.text
        if freeItem {
            favouriteImgView.isHidden = true
            showProductDetailView(false, expand: false)
            customisedLabel.attributedText = NSAttributedString(string: "Free Item", attributes: [.foregroundColor: AppColors.Coupon.couponValidLabel])
            customisedLabel.isHidden = false
        } else {
            favouriteImgView.isHidden = false
            customisedLabel.textColor = AppColors.kuduThemeBlue
            customisedLabel.isHidden = !(item.itemDetails?.isCustomised ?? false)
            showProductDetailView(item.itemDetails?.isCustomised ?? false, expand: item.expandProductDetails ?? false)
            customisedLabel.attributedText = NSAttributedString(string: LSCollection.ExploreMenu.customizable, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: AppColors.kuduThemeBlue])
        }
	}
	
	private func setFavouriteState() {
		var likeStatus: Bool!
		let existingHashIds = AppUserDefaults.value(forKey: .hashIdsForFavourites) as? [String] ?? []
		likeStatus = existingHashIds.contains(item.hashId ?? "")
		let image = likeStatus ? liked : unliked
		favouriteImgView.image = image
	}
	
	private func showProductDetailView(_ show: Bool, expand: Bool) {
		if show {
			productDetailStack.isHidden = false
			productDetailArrow.image = expand ? AppImages.Cart.upArrow : AppImages.Cart.downArrow
			productDetailView.isHidden = false
			setCustomisationText()
			customisationDetailsView.isHidden = !expand
		} else {
			customisationDetailsView.isHidden = true
			productDetailView.isHidden = true
			productDetailStack.isHidden = true
		}
	}
	
	private func setCustomisationText() {
		let customisationString = NSMutableAttributedString(string: "Customised : ", attributes: [.foregroundColor: AppColors.kuduThemeYellow, .font: AppFonts.mulishSemiBold.withSize(10)])
        var modifierString = ""
        self.item.modGroups?.forEach({
            $0.modifiers?.forEach({ (modifier) in
                let title = AppUserDefaults.selectedLanguage() == .en ? modifier.nameEnglish ?? "": modifier.nameArabic ?? ""
                modifierString.append("\(title), ")
            })
        })
        if modifierString.count > 2 {
            modifierString.removeLast(2)
        }
        let allmodifiers = NSMutableAttributedString(string: modifierString, attributes: [.foregroundColor: AppColors.black.withAlphaComponent(0.6), .font: AppFonts.mulishRegular.withSize(10)])
        customisationString.append(allmodifiers)
        if self.item.modGroups?.count ?? 0 == 0 || modifierString.isEmpty {
            //no customisation
            customisationString.append(NSMutableAttributedString(string: "No customisation added", attributes: [.foregroundColor: AppColors.black.withAlphaComponent(0.6), .font: AppFonts.mulishRegular.withSize(10)]))
        }
		customisationDetails.attributedText = customisationString
	}
    
    private func checkAndSetOutOfStock() {
        var isAvailable = self.item.itemDetails?.isAvailable ?? false
        if let excludeLocations = (self.item.itemDetails?.excludeLocations), !excludeLocations.isEmpty {
            if excludeLocations.contains(where: { $0 == CartUtility.getCartStoreID ?? ""}) {
                isAvailable = false
            }
        }
        outOfStockView.isHidden = isAvailable
        outOfStockLabel.isHidden = isAvailable
        itemImgView.image = isAvailable ? self.itemImgView.image : self.itemImgView.image?.grayscale()
        imageContainerView.backgroundColor = isAvailable ? backDropColor : disabledBackDropColor
        customisedLabel.textColor = isAvailable ? AppColors.kuduThemeBlue : AppColors.Cart.outOfStockTextColor
    }

	// MARK: Important Item Based Operations
	
	@IBAction private func favouriteButtonTapped(_ sender: Any) {
		
		if let item = item {
			var likeStatus: Bool!
			let existingHashIds = AppUserDefaults.value(forKey: .hashIdsForFavourites) as? [String] ?? []
			likeStatus = existingHashIds.contains(item.hashId ?? "")
			HapticFeedbackGenerator.triggerVibration(type: .lightTap)
			let newStatus = !likeStatus
			if newStatus {
				favouriteImgView.animationImages = AppGifs.likeAnim.animationImages
				favouriteImgView.animationDuration = 0.75
				favouriteImgView.animationRepeatCount = 1
				favouriteImgView.image = AppGifs.likeAnim.animationImages.last!
				favouriteImgView.startAnimating()
			} else {
				favouriteImgView.image = unliked
			}
			likeStatusUpdated?(!likeStatus, self.index)
		}
	}
	
	@IBAction private func deleteButtonPressed(_ sender: Any) {
		if itemCartCount > 0 {
            HapticFeedbackGenerator.triggerVibration(type: .lightTap)
            if itemCartCount - 1 == 0 {
                self.confirmDelete?(itemCartCount, self.index)
                return
            }
			//itemCartCount -= 1
            if item.itemDetails?.isAvailable ?? false == false {
                itemCartCount = 0
            }
			//updateButtonView()
            self.counterLabelButton.startBtnLoader(color: .white, small: true)
			self.cartCountUpdated?(itemCartCount - 1, self.index)
		}
	}
	
	@IBAction private func plusButtonPressed(_ sender: Any) {
		//itemCartCount += 1
		//updateButtonView()
		HapticFeedbackGenerator.triggerVibration(type: .lightTap)
        if self.item.itemDetails?.isCustomised ?? false {
			self.confirmCustomisationRepeat?(self.index)
		} else {
            self.counterLabelButton.startBtnLoader(color: .white, small: true)
			self.cartCountUpdated?(itemCartCount + 1, self.index)
		}
	}
	
	@IBAction private func addButtonPressed(_ sender: Any) {
		//itemCartCount += 1
		HapticFeedbackGenerator.triggerVibration(type: .lightTap)
		cartCountUpdated?(itemCartCount + 1, self.index)
		//updateButtonView()
	}
}
