//
//  HomeExploreMenuCell.swift
//  Kudu
//
//  Created by Admin on 07/07/22.
//

import UIKit

class HomeExploreMenuCell: UITableViewCell {
    
    @IBOutlet private weak var exploreMenuTitle: UILabel!
    @IBOutlet private weak var button1Container: UIView!
    @IBOutlet private weak var button2Container: UIView!
    @IBOutlet private weak var button3Container: UIView!
    @IBOutlet private weak var button4Container: UIView!
    @IBOutlet private weak var button1ImgView: UIImageView!
    @IBOutlet private weak var button2ImgView: UIImageView!
    @IBOutlet private weak var button3ImgView: UIImageView!
    @IBOutlet private weak var button4ImgView: UIImageView!
    @IBOutlet private weak var button1Title: UILabel!
    @IBOutlet private weak var button2Title: UILabel!
    @IBOutlet private weak var button3Title: UILabel!
    @IBOutlet private weak var button4Title: UILabel!
    @IBOutlet private weak var shimmer1View: UIView!
    @IBOutlet private weak var shimmer2View: UIView!
    @IBOutlet private weak var shimmer3View: UIView!
    @IBOutlet private weak var shimmer4View: UIView!
    @IBOutlet private weak var fullMenuButton: AppButton!
    
    @IBAction private func viewAllPressed(_ sender: Any) {
        self.viewAllTapped?()
    }
    
    private var shimmerViews: [UIView] = []
    private var buttonContainers: [UIView] = []
    private var buttonTitles: [UILabel] = []
    private var buttonImageViews: [UIImageView] = []
    private var list: [MenuCategory]?
    var menuItemTapped: ((Int) -> Void)?
    var viewAllTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        initialSetup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainThread({ [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.list.isNil {
                strongSelf.shimmerViews.layoutIfNeeded()
                strongSelf.shimmerViews.startShimmering()
            }
        })
    }
    
    private func initialSetup() {
        exploreMenuTitle.text = LSCollection.Home.exploreMenu
        fullMenuButton.setTitle(LSCollection.Home.fullMenu, for: .normal)
        shimmerViews = [shimmer1View, shimmer2View, shimmer3View, shimmer4View]
        buttonContainers = [button1Container, button2Container, button3Container, button4Container]
        buttonImageViews = [button1ImgView, button2ImgView, button3ImgView, button4ImgView]
        buttonTitles = [button1Title, button2Title, button3Title, button4Title]
        for i in 0...3 {
            buttonContainers[i].roundBottomCorners(cornerRadius: 12)
            shimmerViews[i].tag = i
            shimmerViews[i].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:))))
        }
    }
    
    @objc private func buttonTapped(_ sender: UITapGestureRecognizer) {
        if let list = self.list, (sender.view?.tag ?? 0) < list.count {
            self.menuItemTapped?(sender.view?.tag ?? 0)
        }
    }
    
    func configure(list: [MenuCategory]?) {
        buttonContainers.isHidden(true)
        buttonImageViews.isHidden(true)
        self.list = list
        guard let list = list else {
            return
        }
        for i in 0..<4 {
            if i < list.count {
                let item = list[i]
                let title = AppUserDefaults.selectedLanguage() == .en ? (item.titleEnglish ?? "") : (item.titleArabic ?? "")
                buttonTitles[i].text = title
                let url = item.menuImageUrl ?? ""
				buttonImageViews[i].setImageKF(imageString: url, placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: false, loaderTintColor: .clear, completionHandler: { [weak self] _ in
                        mainThread {
                            self?.removeShimmerForView(i)
                        }
                    })
                
            } else {
                self.shimmerViews[i].stopShimmering()
            }
        }
    }
    
    private func removeShimmerForView(_ index: Int) {
        self.shimmerViews[index].stopShimmering()
        self.buttonContainers[index].isHidden = false
        self.buttonImageViews[index].isHidden = false
    }
    
}

extension Array where Element == UIView {
    
    func isHidden(_ isHidden: Bool) {
        self.forEach({
            $0.isHidden = isHidden
        })
    }
    
    func startShimmering() {
        self.forEach({
            $0.startShimmering()
        })
    }
    
    func stopShimmering() {
        self.forEach({
            $0.stopShimmering()
        })
    }
    
    func layoutIfNeeded() {
        self.forEach({
            $0.layoutIfNeeded()
        })
    }
    
}

extension Array where Element == UIImageView {
    
    func isHidden(_ isHidden: Bool) {
        self.forEach({
            $0.isHidden = isHidden
        })
    }
    
}
