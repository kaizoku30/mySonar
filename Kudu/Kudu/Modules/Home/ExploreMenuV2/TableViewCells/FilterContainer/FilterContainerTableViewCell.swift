//
//  FilterContainerTableViewCell.swift
//  Kudu
//
//  Created by Admin on 13/09/22.
//

import UIKit

class FilterContainerTableViewCell: UITableViewCell {
	@IBOutlet private weak var filterCollectionView: UICollectionView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		filterCollectionView.delegate = self
		filterCollectionView.dataSource = self
		filterCollectionView.semanticContentAttribute = .forceLeftToRight
		filterCollectionView.registerCell(with: ExploreMenuCategoryCollectionViewCell.self)
	}
	
	private var filterArray: [MenuCategory] = []
    var selectedCategoryIndex: Int = 0
	var selectedIndex: ((Int) -> Void)?
	
	func configure(filterArray: [MenuCategory], selectedCategoryIndex: Int, previousIndex: Int = 0) {
        mainThread {
            self.filterArray = filterArray
            self.selectedCategoryIndex = selectedCategoryIndex
            self.filterCollectionView.reloadData()
            self.filterCollectionView.performBatchUpdates({ //Let collection view update
            }, completion: { _ in
                self.filterCollectionView.scrollToItem(at: IndexPath(item: selectedCategoryIndex, section: 0), at: .centeredHorizontally, animated: true)
            })
        }
	}
}

extension FilterContainerTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let font = AppFonts.mulishSemiBold.withSize(12)
		let fontAttributes = [NSAttributedString.Key.font: font]
		let item = filterArray[indexPath.item]
		let text = AppUserDefaults.selectedLanguage() == .en ? item.titleEnglish ?? "" : item.titleArabic ?? ""
		let size = (text as NSString).size(withAttributes: fontAttributes)
		var itemSpecificWidth = size.width + 32
		if itemSpecificWidth < (48 + 32) {
			itemSpecificWidth = 48 + 32
		}
		return CGSize(width: itemSpecificWidth, height: 89)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueCell(with: ExploreMenuCategoryCollectionViewCell.self, indexPath: indexPath)
		if indexPath.item < filterArray.count {
			let item = filterArray[indexPath.item]
			let selected = selectedCategoryIndex == indexPath.item
			cell.configure(item: item, selected: selected)
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		filterArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.selectedIndex?(indexPath.item)
	}
}
