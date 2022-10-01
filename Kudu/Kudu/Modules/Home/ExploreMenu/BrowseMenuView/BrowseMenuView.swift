//
//  BrowseMenuView.swift
//  Kudu
//
//  Created by Admin on 12/08/22.
//

import UIKit

class BrowseMenuView: UIView {
	@IBOutlet private weak var mainContentView: UIView!
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var closeButtonView: UIView!
	@IBOutlet private weak var browseMenuHeaderView: UIView!
	
	@IBAction private func dismissButtonPressed(_ sender: Any) {
		removeFromContainer()
	}
	
	private var categories: [MenuCategory] = []
	private weak var containerView: UIView?
	var categorySelected: ((Int) -> Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder adecoder: NSCoder) {
		super.init(coder: adecoder)
		commonInit()
	}
	
	private func commonInit() {
		Bundle.main.loadNibNamed("BrowseMenuView", owner: self, options: nil)
		addSubview(mainContentView)
		mainContentView.frame = self.bounds
		mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		tableView.registerCell(with: BrowseMenuTitleCell.self)
		tableView.registerCell(with: BrowseMenuCategoryTitleCell.self)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorStyle = .none
		browseMenuHeaderView.roundTopCorners(cornerRadius: 7)
		tableView.roundBottomCorners(cornerRadius: 7)
		mainContentView.roundTopCorners(cornerRadius: 7)
	}
	
	@objc private func removeFromContainer() {
		UIView.animate(withDuration: 0.2, animations: {
			self.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
		}) { (completed) in
			if !completed { return }
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
	}
	
	func configure(categories: [MenuCategory], container view: UIView, browseMenuButtonFrame: CGRect) {
		self.categories = categories
		self.containerView = view
		let dimmedView = UIView(frame: view.frame)
		dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
		dimmedView.tag = Constants.CustomViewTags.dimViewTag
		dimmedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeFromContainer)))
		view.addSubview(dimmedView)
		self.tag = Constants.CustomViewTags.alertTag
		self.width = 240
		self.height = CGFloat(40 + (34*categories.count)) + 61
		self.center = CGPoint(x: view.width/2, y: browseMenuButtonFrame.maxY)
		self.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
		self.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
		view.addSubview(self)
        self.layoutIfNeeded()
		UIView.animate(withDuration: 0.4, animations: {
			self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
		}, completion: { (completed) in
			if !completed {
				return
			}
			UIView.animate(withDuration: 0.1, animations: {
				self.transform = CGAffineTransform(scaleX: 1, y: 1)
			}, completion: {
				if $0 {
					self.closeButtonView.isHidden = false
					self.setShadow(dimmedView: dimmedView)
					self.tableView.reloadData()
				}
			})
		})
		
	}
	
	private func setShadow(dimmedView: UIView) {
		dimmedView.layer.masksToBounds = false
		dimmedView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
		dimmedView.layer.shadowOpacity = 1
		dimmedView.layer.shadowOffset = CGSize(width: 0, height: 10)
		dimmedView.layer.shadowRadius = 7
		dimmedView.layer.shouldRasterize = true
		dimmedView.layer.rasterizationScale = UIScreen.main.scale
	}
}

extension BrowseMenuView: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: BrowseMenuCategoryTitleCell.self)
		let name = categories[safe: indexPath.row]
		let selectedLanguage = AppUserDefaults.selectedLanguage()
		let categoryTitle = selectedLanguage == .en ? name?.titleEnglish ?? "" : name?.titleArabic ?? ""
		cell.configure(categoryTitle)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		removeFromContainer()
		categorySelected?(indexPath.row)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		34
	}
}

extension UIView {
	func applyTransform(withScale scale: CGFloat, anchorPoint: CGPoint) {
		layer.anchorPoint = anchorPoint
		let scale = scale != 0 ? scale : CGFloat.leastNonzeroMagnitude
		let xPadding = 1/scale * (anchorPoint.x - 0.5)*bounds.width
		let yPadding = 1/scale * (anchorPoint.y - 0.5)*bounds.height
		transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: xPadding, y: yPadding)
	}
}
