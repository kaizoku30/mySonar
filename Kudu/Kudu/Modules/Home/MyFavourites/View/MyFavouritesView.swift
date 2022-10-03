//
//  MyFavouritesView.swift
//  Kudu
//
//  Created by Admin on 18/08/22.
//

import UIKit

class MyFavouritesView: UIView {
    @IBOutlet private weak var cartBanner: CartBannerView!
    @IBOutlet private weak var cartBannerContainer: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noFavouriteView: UIView!
    @IBOutlet private weak var favouriteTitleLabel: UILabel!
    @IBOutlet private weak var cartBannerImageBackDrop: UIImageView!
    @IBAction private func backButtonPressed(_ sender: Any) {
        handleViewActions?(.backButtonPressed)
    }
    
    private var fetchingItems: Bool = false
    private var offSetToRetain: CGFloat = 0
    var isFetchingItems: Bool { fetchingItems }
    var handleViewActions: ((ViewActions) -> Void)?
    var tableViewCurrentOffset: CGFloat { tableView.contentOffset.y }
    
    enum ViewActions {
        case backButtonPressed
        case viewCart
        case handleCartConflict(count: Int, index: Int)
    }
    
    enum APICalled {
        case favouritesAPI
        case itemDetail
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
        cartBanner.viewCart = { [weak self] in
            self?.handleViewActions?(.viewCart)
        }
    }
    
    private func initialSetup() {
        tableView.registerCell(with: ItemTableViewCell.self)
        tableView.registerCell(with: AutoCompleteLoaderCell.self)
		tableView.showsVerticalScrollIndicator = false
        checkCartStatus()
    }
    
    func refreshTableView() {
        mainThread {
            self.tableView.reloadData()
        }
    }
    
    func retainOffset() {
        self.offSetToRetain = self.tableView.contentOffset.y
    }
    
    func scrollToOffset(_ offSet: CGFloat) {
        mainThread {
            self.tableView.contentOffset.y = offSet
        }
    }
    
    func showCartConflictAlert(_ count: Int, index: Int) {
        let alert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 186))
        alert.setTextAlignment(.left)
        alert.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: nil)
        alert.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: .right)
        alert.configure(title: "Change Order Type ?", message: "Please be aware your cart will be cleared as you change order type", leftButtonTitle: "Cancel", rightButtonTitle: "Continue", container: self)
        alert.handleAction = { [weak self] in
            if $0 == .right {
                CartUtility.clearCart(clearedConfirmed: {
                    self?.handleViewActions?(.handleCartConflict(count: count, index: index))
                    weak var weakRef = alert
                    weakRef?.removeFromContainer()
                })
            }
        }
    }
    
    func removeFromFavourites(index: Int) {
        mainThread {
			self.tableView.reloadData()
            if self.tableView.numberOfRows(inSection: 0) == 0 {
                self.tableView.isHidden = true
                self.noFavouriteView.isHidden = false
            }
        }
    }
}

extension MyFavouritesView {
    func handleAPIRequest(_ api: APICalled) {
        mainThread({
            self.tableView.isUserInteractionEnabled = false
            if api == .favouritesAPI {
                self.fetchingItems = true
                self.tableView.reloadData()
            }
			if api == .itemDetail {
				self.addLoadingOverlay()
			}
        })
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, noResult: Bool, errorMsg: String?) {
        mainThread {
            self.fetchingItems = false
            self.tableView.isUserInteractionEnabled = true
            if let errorMsg = errorMsg {
                let error = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
                error.show(message: errorMsg, view: self)
                return
            }
            self.tableView.reloadData()
            self.tableView.performBatchUpdates({ //Let tableview update
            }, completion: { _ in
                if self.offSetToRetain != 0 {
                    self.tableView.setContentOffset(CGPoint(x: 0, y: self.offSetToRetain), animated: true)
                    self.offSetToRetain = 0
                }
                self.tableView.isHidden = noResult
                self.noFavouriteView.isHidden = !noResult
            })
        }
    }
}

extension MyFavouritesView {
    func addLoadingOverlay() {
		addSubview(LoadingDetailOverlay.create(withFrame: CGRect(x: 0, y: 0, width: self.width, height: self.height), atCenter: self.center))
	}
	
	func removeLoadingOverlay() {
		guard let overlay = subviews.first(where: { $0.tag == Constants.CustomViewTags.detailOverlay }) else { return }
		mainThread {
			overlay.removeFromSuperview()
		}
	}
}

extension MyFavouritesView {
    
    private func checkCartStatus() {
        if cartBanner.cartShouldBeVisible {
            cartBanner.configure()
        }
        self.cartBannerContainer.backgroundColor = cartBanner.cartShouldBeVisible ? cartBanner.color : AppColors.offWhiteTableBg
        self.cartBanner.isHidden = !self.cartBanner.cartShouldBeVisible
        self.cartBannerImageBackDrop.isHidden = !self.cartBanner.cartShouldBeVisible
    }
    
    func refreshCartLocally() {
        mainThread {
            if self.cartBanner.cartShouldBeVisible {
                self.cartBanner.configure()
                self.cartBannerContainer.backgroundColor = self.cartBanner.color
                self.cartBanner.isHidden = false
                self.cartBannerImageBackDrop.isHidden = false
            } else {
                self.cartBannerContainer.backgroundColor = AppColors.offWhiteTableBg
                self.cartBanner.isHidden = true
                self.cartBannerImageBackDrop.isHidden = true
            }
        }
    }
}
