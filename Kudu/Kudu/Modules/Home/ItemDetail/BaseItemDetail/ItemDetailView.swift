//
//  ChangeDefaultAddressView.swift
//  Kudu
//
//  Created by Admin on 19/07/22.
//

import UIKit
import NVActivityIndicatorView

class ItemDetailView: UIView {

    @IBOutlet private weak var tapGestureView: UIView!
    @IBOutlet private weak var allergenCollection: HorizontallyExpandableCollection!
    @IBOutlet private weak var loader: NVActivityIndicatorView!
    @IBOutlet private weak var actionSheet: UIView!
    @IBOutlet private weak var bottomSheet: UIView!
    @IBOutlet private weak var dismissButton: AppButton!
    @IBOutlet private var mainContentView: UIView!
    @IBOutlet private weak var itemImgView: UIImageView!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var itemPriceLabel: UILabel!
    @IBOutlet private weak var itemDescriptionLabel: UILabel!
    @IBOutlet private weak var addButton: AppButton!
    @IBOutlet private weak var incrementorStackView: UIStackView!
    @IBOutlet private weak var counterLblBtn: AppButton!
    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var allergenceTitleLabel: UILabel!
    @IBOutlet private weak var deleteBtn: AppButton!
    
    @IBAction func incrementButtonPressed(_ sender: Any) {
        itemCartCount += 1
        updateButtonView()
        HapticFeedbackGenerator.triggerVibration(type: .lightTap)
        self.cartCountUpdated?(itemCartCount, self.item)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        if itemCartCount > 0 {
            HapticFeedbackGenerator.triggerVibration(type: .lightTap)
            if itemCartCount == 1 && showDeleteConfirmation {
                //show delete confirmation
                showConfirmDeletePop()
                return
            }
            itemCartCount -= 1
            updateButtonView()
            self.cartCountUpdated?(itemCartCount, self.item)
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        HapticFeedbackGenerator.triggerVibration(type: .lightTap)
        
        if AppUserDefaults.value(forKey: .loginResponse).isNil {
            triggerLoginFlow?()
            return
        }
        
        if self.serviceType != CartUtility.getCartServiceType && CartUtility.fetchCart().isEmpty == false {
            self.showCartConflictAlert(1, self.item)
            return
        }
        
        if comingFromRecommendations {
            self.cartCountUpdated?(itemCartCount, self.item)
            removeFromContainer()
            return
        }
        itemCartCount += 1
        updateButtonView()
        cartCountUpdated?(itemCartCount, self.item)
    }
    
    private func updateButtonView() {
        if itemCartCount == 0 || itemCartCount > 0 {
            self.deleteBtn.setImage(itemCartCount == 1 ? AppImages.ExploreMenu.delete : AppImages.ExploreMenu.minus, for: .normal)
            self.addButton.isHidden = itemCartCount != 0
            self.counterLblBtn.setTitle("\(itemCartCount)", for: .normal)
            self.incrementorStackView.isHidden = itemCartCount == 0
        }
    }
    
    @IBAction private func dismissButtonPressed(_ sender: Any) {
        removeFromContainer()
    }
    
    static var ContentHeight: CGFloat { 564 }
    private weak var containerView: UIView?
    private var allergenArray: [AllergicComponent] = []
    private var item: MenuItem!
    private var itemIdForAPI: String = ""
    private var serviceType: APIEndPoints.ServicesType = .delivery
    private var showDeleteConfirmation = false
    var handleDeallocation: (() -> Void)?
    private var itemCartCount: Int = 0
    var cartCountUpdated: ((Int, MenuItem) -> Void)?
    var triggerLoginFlow: (() -> Void)?
    private var comingFromRecommendations = false
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
      private func commonInit() {
        Bundle.main.loadNibNamed("ItemDetailView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        actionSheet.roundTopCorners(cornerRadius: 32)
        loaderView.roundTopCorners(cornerRadius: 32)
//        bottomSheet.transform = CGAffineTransform(translationX: 0, y: ItemDetailView.ContentHeight)
        addButton.setTitle(LocalizedStrings.ExploreMenu.addButton, for: .normal)
        tapGestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeFromContainer)))
     }
    
    @objc private func removeFromContainer() {
        self.handleDeallocation?()
        
    }
    
    func configure(container view: UIView, item: MenuItem, serviceType: APIEndPoints.ServicesType) {
        self.item = item
        self.serviceType = serviceType
        self.containerView = view
        setData()
        self.tag = Constants.CustomViewTags.alertTag
        self.center = view.center
        view.addSubview(self)
    }
    
    private func setData() {
        guard let item = item else {
            return
        }
        self.allergenArray = item.allergicComponent ?? []
        allergenceTitleLabel.isHidden = self.allergenArray.isEmpty
        allergenCollection.isHidden = self.allergenArray.isEmpty
        let name = AppUserDefaults.selectedLanguage() == .en ? item.nameEnglish ?? "" : item.nameArabic ?? ""
        var description = AppUserDefaults.selectedLanguage() == .en ? item.descriptionEnglish ?? "" : item.descriptionArabic ?? ""
        if let calorie = item.calories, calorie > 0 {
            description.append(" (\(calorie)Kcal)")
        }
        self.itemNameLabel.text = name
        self.itemPriceLabel.text = "SR " + (item.price ?? 0.0).round(to: 2).removeZerosFromEnd()
        self.itemDescriptionLabel.text = description
        self.itemDescriptionLabel.adjustsFontSizeToFitWidth = true
        self.itemImgView.setImageKF(imageString: item.itemImageUrl ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: false, loaderTintColor: .clear, completionHandler: nil)
        allergenCollection.configure(allergenArray: self.allergenArray)
        if self.comingFromRecommendations { return }
        self.itemCartCount = self.item.cartCount ?? 0
        updateButtonView()
    }
    
    func configureForExploreMenu(container view: UIView, itemId: String, serviceType: APIEndPoints.ServicesType, showDeleteConfirmation: Bool = false) {
        self.containerView = view
        self.showDeleteConfirmation = showDeleteConfirmation
        self.serviceType = serviceType
        self.itemIdForAPI = itemId
        self.loaderView.isHidden = false
        self.loader.startAnimating()
        self.tag = Constants.CustomViewTags.alertTag
        self.center = view.center
        view.addSubview(self)
        self.getDetails()
    }
    
    func setRecommendationFlow() {
        comingFromRecommendations = true
    }
    
    private func getDetails() {
        APIEndPoints.HomeEndPoints.getItemDetail(itemId: self.itemIdForAPI, success: { [weak self] (result) in
            mainThread {
                if let data = result.data, data.count > 0, self != nil {
                    self?.item = result.data![0]
                    self?.setData()
                    self?.loaderView.isHidden = true
                    self?.loader.stopAnimating()
                    self?.loaderView.removeFromSuperview()
                }
            }
        }, failure: { [weak self] in
            SKToast.show(withMessage: $0.msg)
            mainThread {
                self?.removeFromContainer()
            }
        })
    }

}

extension ItemDetailView {
    private func showCartConflictAlert(_ count: Int, _ item: MenuItem) {
        let alert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 186))
        alert.setTextAlignment(.left)
        alert.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: nil)
        alert.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: .right)
        alert.configure(title: "Change Order Type ?", message: "Please be aware your cart will be cleared as you change order type", leftButtonTitle: "Cancel", rightButtonTitle: "Continue", container: self)
        alert.handleAction = { [weak self] in
            if $0 == .right {
                guard let strongSelf = self else { return }
                CartUtility.clearCart(clearedConfirmed: {
                    strongSelf.itemCartCount += 1
                    strongSelf.updateButtonView()
                    strongSelf.cartCountUpdated?(count, item)
                    weak var weakRef = alert
                    weakRef?.removeFromContainer()
                })
            }
        }
    }
}

extension ItemDetailView {
    private func showConfirmDeletePop() {
        let popUp = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 156))
        popUp.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: .left)
        popUp.configure(message: "Are you sure you want to remove this item from your cart ?", leftButtonTitle: "Delete", rightButtonTitle: "Cancel", container: self, setMessageAsTitle: true)
        popUp.handleAction = { [weak self] in
            if $0 == .left {
                guard let strongSelf = self else { return }
                strongSelf.cartCountUpdated?(0, strongSelf.item)
                strongSelf.removeFromContainer()
            }
        }
    }
}
