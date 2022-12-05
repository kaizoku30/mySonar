//
//  CartBannerView.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import UIKit
import NVActivityIndicatorView

class CartBannerView: UIView {
    @IBOutlet private weak var srLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private var mainContentView: UIView!
	@IBOutlet private weak var priceLabel: UILabel!
	@IBOutlet private weak var itemCountLabel: UILabel!
	@IBOutlet private weak var viewCartButton: AppButton!
    @IBAction private func viewCartPressed(_ sender: Any) {
		viewCart?()
	}
	
    @IBOutlet private weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet private weak var shimmer1: UIView!
    
    var viewCart: (() -> Void)?
	static var height: CGFloat { 54 }
	var color: UIColor { self.mainContentView.backgroundColor! }
	var cartShouldBeVisible: Bool {
        CartUtility.getItemCount() != 0 }
    private var shimmers: [UIView] = []
    
    override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
        shimmers = [shimmer1]
	}
	
	required init?(coder adecoder: NSCoder) {
		super.init(coder: adecoder)
		commonInit()
	}
	
	private func commonInit() {
		Bundle.main.loadNibNamed("CartBannerView", owner: self, options: nil)
		addSubview(mainContentView)
		mainContentView.frame = self.bounds
		mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		mainContentView.roundTopCorners(cornerRadius: 4)
        viewCartButton.setTitle(LSCollection.Home.viewCart, for: .normal)
	}
	
	func syncCart(showCart: @escaping (Bool) -> Void) {
        if DataManager.shared.isUserLoggedIn == false {
            CartUtility.clearLocalData()
            showCart(false)
            return
        }
        self.showLoader(true)
		CartUtility.syncCart {
			//guard let strongSelf = self else { return }
			let updatedCart = CartUtility.fetchCartLocally()
            self.showLoader(false)
			showCart(!updatedCart.isEmpty)
		}
	}
	
	func configure() {
		let price = CartUtility.getPrice()
		priceLabel.text = price.round(to: 2).removeZerosFromEnd()
        let items = CartUtility.getItemCount()
		itemCountLabel.text = "\(items) Items"
        self.isHidden = !cartShouldBeVisible
	}
    
    func showLoader(_ show: Bool) {
        mainThread {
            
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseOut, animations: {
                self.shimmer1.isHidden = show ? false : true
                [self.priceLabel, self.itemCountLabel, self.separatorView, self.srLabel].forEach({ $0?.alpha = show ? 0 : 1 })
                self.shimmer1.alpha = show ? 0.25 : 0
                
            }, completion: { if $0 {
                if show {
                    self.shimmer1.startShimmering()
                } else {
                    self.shimmer1.stopShimmering()
                }
            }})
        }
    }
	
}
