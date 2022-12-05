//
//  ExploreMenuV2View.swift
//  Kudu
//
//  Created by Admin on 13/09/22.
//

import UIKit

struct ExploreMenuViewScrollMetrics {
    var maxHeight: CGFloat = 0
    var maxRows: Int = 0
    var columnOffsetArray: [CGFloat] = []
    var currentColumnIndex: Int = 0
    var columnSpecificHeights: [CGFloat] = []
}

class ExploreMenuV2View: UIView {
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet private weak var exploreMenuTitle: UILabel!
    @IBOutlet private weak var browseMenuTapView: UIView!
    @IBOutlet private weak var browseMenuHeight: NSLayoutConstraint!
    @IBOutlet private weak var cartBanner: CartBannerView!
    @IBOutlet private weak var cartBannerContainer: UIView!
    @IBOutlet weak var browseMenuButton: AppButton!
    @IBOutlet private weak var browseMenuWidth: NSLayoutConstraint!
    @IBOutlet private weak var browseMenuBottomPadding: NSLayoutConstraint!
    @IBAction private func browseMenuTapped(_ sender: Any) {
        handleViewActions?(.browseMenuTapped)
    }
    @IBAction private func searchButtonPressed(_ sender: Any) {
        handleViewActions?(.searchButtonPressed)
    }
    
    enum ViewAction {
        case backButtonPressed
        case browseMenuTapped
        case searchButtonPressed
        case viewCart
        case handleCartConflict(count: Int, item: MenuItem, template: CustomisationTemplate?)
    }
    
    var handleViewActions: ((ViewAction) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    private func initialSetup() {
        browseMenuButton.setTitle(LSCollection.BrowseMenu.browseMenu, for: .normal)
        exploreMenuTitle.text = LSCollection.Home.exploreMenuVCTitle
        mainTableView.semanticContentAttribute = .forceLeftToRight
        setBrowseMenuInsets()
        cartBannerContainer.roundTopCorners(cornerRadius: 4)
        cartBanner.viewCart = { [weak self] in
            self?.handleViewActions?(.viewCart)
        }
        browseMenuTapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(browseMenuAlternateTap)))
    }
    
    @objc private func browseMenuAlternateTap() {
        self.handleViewActions?(.browseMenuTapped)
    }
    
    func showCartConflictAlert(_ count: Int, _ item: MenuItem, _ template: CustomisationTemplate? = nil) {
        let alert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 186))
        alert.setTextAlignment(.left)
        alert.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: nil)
        alert.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: .right)
        alert.configure(title: LSCollection.CartScren.orderTypeHasBeenChanged, message: LSCollection.CartScren.cartWillBeCleared, leftButtonTitle: LSCollection.SignUp.cancel, rightButtonTitle: LSCollection.SignUp.continueText, container: self)
        alert.handleAction = { [weak self] in
            if $0 == .right {
                CartUtility.clearCartRemotely(clearedConfirmed: {
                    self?.handleViewActions?(.handleCartConflict(count: count, item: item, template: template))
                    weak var weakRef = alert
                    weakRef?.removeFromContainer()
                })
                
            }
        }
    }
    
    private func setBrowseMenuInsets() {
        if AppUserDefaults.selectedLanguage() == .en {
            browseMenuButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        } else {
            browseMenuButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        }
    }
    
    func syncCart() {
        self.cartBanner.syncCart(showCart: { [weak self] (show) in
            mainThread({
                self?.cartBanner.isHidden = !show
                self?.refreshCartLocally()
            })
        })
    }
    
    private func refreshCartLocally() {
        mainThread {
            if self.cartBanner.cartShouldBeVisible {
                self.cartBanner.configure()
                if self.cartBanner.isHidden {
                    self.cartBannerContainer.backgroundColor = self.cartBanner.color
                    self.cartBanner.isHidden = false
                }
            } else {
                self.cartBannerContainer.backgroundColor = self.cartBanner.cartShouldBeVisible ? self.cartBanner.color : AppColors.offWhiteTableBg
                self.cartBanner.isHidden = !self.cartBanner.cartShouldBeVisible
            }
            if self.browseMenuBottomPadding.constant == 10 && self.cartBanner.cartShouldBeVisible {
                self.browseMenuBottomPadding.constant = self.cartBanner.height + 10
            }
            if self.browseMenuBottomPadding.constant == self.cartBanner.height + 10 && self.cartBanner.cartShouldBeVisible == false {
                self.browseMenuBottomPadding.constant = 10
            }
        }
    }
    
    func showTableView(_ show: Bool) {
        mainThread {
            self.mainTableView.reloadData()
        }
    }
    
    func refreshItemColumns(currentIndex: Int, updatedColumnData: [[MenuItem]]) {
        mainThread {
            CATransaction.begin()
            CATransaction.setCompletionBlock({ [weak self] in
                let cell = self?.mainTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ContentContainerTableViewCell
                cell?.columnData = updatedColumnData
                cell?.refreshTable()
                // Your completion code here
            })
            print("reloading")
            self.mainTableView.reloadData()
            CATransaction.commit()
        }
        
    }
    
    func updateOffset(_ offset: CGFloat) {
        mainThread {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: {
                self.mainTableView.contentOffset.y = offset
                self.layoutIfNeeded()
            })
        }
    }
    
    func updateFilters() {
        mainThread {
            self.mainTableView.reloadData()
            self.mainTableView.layoutIfNeeded()
        }
    }
    
    func scrollOnBrowseMenu() {
        self.mainTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
    func showError(msg: String) {
        mainThread {
            let error = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            error.show(message: msg, view: self, extraDelay: nil, completionBlock: nil)
        }
    }
    
    private var rotatedToCircle = false
    
    func toggleBrowseMenu(show: Bool) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: {
            let showPadding = self.cartBanner.cartShouldBeVisible ? self.cartBanner.height + 10 : 10
            self.browseMenuBottomPadding.constant = show ? showPadding : -80
            self.rotatedToCircle = false
            self.browseMenuWidth.constant = 141
            self.setBrowseMenuInsets()
            self.browseMenuButton.setTitle(LSCollection.BrowseMenu.browseMenu, for: .normal)
            self.browseMenuButton.layoutIfNeeded()
        })
    }
    
    func triggerAnimationBrowseMenu(show: Bool) {
        if show && rotatedToCircle { return }
        if !show && !rotatedToCircle { return }
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: {
            if show {
                self.rotatedToCircle = true
                self.browseMenuButton.setTitle("", for: .normal)
                self.browseMenuButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                self.browseMenuWidth.constant = 40
                self.browseMenuTapView.isHidden = false
                self.browseMenuButton.layoutIfNeeded()
            } else {
                self.browseMenuTapView.isHidden = true
                self.setDefaultBrowseMenuStyle()
            }
            
        }, completion: { _ in })
    }
    
    private func setDefaultBrowseMenuStyle() {
        self.rotatedToCircle = false
        self.browseMenuWidth.constant = 141
        self.setBrowseMenuInsets()
        self.browseMenuButton.setTitle(LSCollection.BrowseMenu.browseMenu, for: .normal)
        self.browseMenuButton.layoutIfNeeded()
    }
}
