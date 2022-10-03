//
//  OutOfReachView.swift
//  Kudu
//
//  Created by Admin on 08/09/22.
//

import UIKit

class OutOfReachView: AppPopUpViewType {
	@IBOutlet private var mainContentView: UIView!
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var subtitleLabel: UILabel!
	
	@IBAction private func closeButtonPressed(_ sender: Any) {
		removeFromContainer()
	}
	
	static var HorizontalPadding: CGFloat { 2*47 }
	static var VerticalPadding: CGFloat { 13 + 130 + 36}
	private let titleFont = AppFonts.mulishBold.withSize(16)
	private let messageFont = AppFonts.mulishMedium.withSize(12)
    var handleDeallocation: (() -> Void)?
    
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder adecoder: NSCoder) {
		super.init(coder: adecoder)
		commonInit()
	}
	
	private func commonInit() {
		Bundle.main.loadNibNamed("OutOfReachView", owner: self, options: nil)
		addSubview(mainContentView)
		mainContentView.frame = self.bounds
		mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}
	
	private func removeFromContainer() {
        handleDeallocation?()
		removeSelf()
	}
	
	func configure(container view: UIView) {
		self.containerView = view
		let dimmedView = UIView(frame: view.frame)
		dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
		dimmedView.tag = Constants.CustomViewTags.dimViewTag
		view.addSubview(dimmedView)
		self.tag = Constants.CustomViewTags.alertTag
		let title = "Out of reach"
		let subtitle = "We don’t deliver here yet, but we’re expanding quickly and hopefully will soon!"
		let titleHeight = title.heightOfText(titleLabel.width, font: titleFont)
		let messageHeight = subtitle.heightOfText(subtitleLabel.width, font: messageFont)
		self.height = titleHeight + messageHeight + OutOfReachView.VerticalPadding + 10
		self.layoutIfNeeded()
		self.center = view.center
		view.addSubview(self)
	}
	
}
