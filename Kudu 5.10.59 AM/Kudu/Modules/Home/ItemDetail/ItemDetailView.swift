//
//  ChangeDefaultAddressView.swift
//  Kudu
//
//  Created by Admin on 19/07/22.
//

import UIKit
import NVActivityIndicatorView

class ItemDetailView: UIView {

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
    
    @IBAction func incrementButtonPressed(_ sender: Any) {
        // Implementation Pending
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        // Implementation Pending
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        // Implementation Pending
    }
    
    @IBAction private func dismissButtonPressed(_ sender: Any) {
        handleDeallocation?()
        removeFromContainer()
    }
    
    static var ContentHeight: CGFloat { 564 }
    private weak var containerView: UIView?
    private var allergenArray: [AllergicComponent] = []
    private var allergenViewMode: DisplayModeAllergen = .less
    private var item: MenuItem?
    private var itemIdForAPI: String = ""
    var handleDeallocation: (() -> Void)?
    
    enum DisplayModeAllergen {
        case less
        case more
    }
    
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
        bottomSheet.transform = CGAffineTransform(translationX: 0, y: ItemDetailView.ContentHeight)
        addButton.setTitle(LocalizedStrings.ExploreMenu.addButton, for: .normal)
     }
    
    private func removeFromContainer() {
        self.containerView?.subviews.forEach({
            if $0.tag == Constants.CustomViewTags.alertTag {
                $0.removeFromSuperview()
            }
        })
        self.containerView?.subviews.forEach({
            if $0.tag == Constants.CustomViewTags.dimViewTag {
                $0.removeFromSuperview()
            }
        })
    }
    
    func configure(container view: UIView, item: MenuItem) {
        self.item = item
        self.containerView = view
        setData()
        let dimmedView = UIView(frame: view.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        view.addSubview(dimmedView)
        self.tag = Constants.CustomViewTags.alertTag
        self.center = view.center
        view.addSubview(self)
        UIView.animate(withDuration: 1, animations: {
            self.bottomSheet.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { _ in
            // Implementation Not Needed
        })
    }
    
    private func setData() {
        guard let item = item else {
            return
        }
        for i in 0..<5 {
            self.allergenArray.append(AllergicComponent(_id: nil, name: "Testing \(i)", imageUrl: "https://source.unsplash.com/user/c_v_r/100x100"))
        }
        //self.allergenArray = item.allergicComponent ?? []
        let name = AppUserDefaults.selectedLanguage() == .en ? item.nameEnglish ?? "" : item.nameArabic ?? ""
        let description = AppUserDefaults.selectedLanguage() == .en ? item.descriptionEnglish ?? "" : item.descriptionArabic ?? ""
        self.itemNameLabel.text = name
        self.itemPriceLabel.text = "SR " + (item.price ?? 0.0).round(to: 2).removeZerosFromEnd()
        self.itemDescriptionLabel.text = description
        self.itemDescriptionLabel.adjustsFontSizeToFitWidth = true
        self.itemImgView.setImageKF(imageString: item.itemImageUrl ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: false, loaderTintColor: .clear, completionHandler: nil)
        allergenCollection.configure(allergenArray: self.allergenArray)
    }
    
    func configureForExploreMenu(container view: UIView, item: MenuSearchResultItem) {
        self.containerView = view
        self.itemIdForAPI = item._id ?? ""
        self.loaderView.isHidden = false
        self.loader.startAnimating()
        let dimmedView = UIView(frame: view.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        view.addSubview(dimmedView)
        self.tag = Constants.CustomViewTags.alertTag
        self.center = view.center
        view.addSubview(self)
        UIView.animate(withDuration: 1, animations: {
            self.bottomSheet.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: {
            if $0 {
                self.getDetails()
            }
        })
    }
    
    private func getDetails() {
        WebServices.HomeEndPoints.getItemDetail(itemId: self.itemIdForAPI, success: { [weak self] (result) in
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
