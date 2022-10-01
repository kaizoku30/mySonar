//
//  CartBannerView.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import UIKit

class CartBannerView: UIView {
	@IBOutlet private var mainContentView: UIView!
	@IBOutlet private weak var priceLabel: UILabel!
	@IBOutlet private weak var itemCountLabel: UILabel!
	@IBOutlet private weak var viewCartButton: AppButton!
	
	@IBAction private func viewCartPressed(_ sender: Any) {
		viewCart?()
	}
	
	var viewCart: (() -> Void)?
	
	//private var cartList: [CartListObject] = CartUtility.fetchCart()
	static var height: CGFloat { 54 }
	var color: UIColor { self.mainContentView.backgroundColor! }
	var cartShouldBeVisible: Bool {
        CartUtility.getItemCount() != 0 }
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
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
	}
	
	func syncCart(showCart: @escaping (Bool) -> Void) {
		CartUtility.syncCart {
			//guard let strongSelf = self else { return }
			let updatedCart = CartUtility.fetchCart()
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
	
}
