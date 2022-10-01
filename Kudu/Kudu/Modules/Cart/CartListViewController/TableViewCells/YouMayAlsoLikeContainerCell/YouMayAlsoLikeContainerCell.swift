//
//  YouMayAlsoLikeContainerCell.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import UIKit

class YouMayAlsoLikeContainerCell: UITableViewCell {
	@IBOutlet private weak var collectionView: UICollectionView!
	var addYouMayAlsoLike: ((YouMayAlsoLikeObject) -> Void)?
	
    override func awakeFromNib() {
        super.awakeFromNib()
		collectionView.dataSource = self
		collectionView.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
	
	private var fetchingData = false
	private var items: [YouMayAlsoLikeObject] = []

	func configure(fetching: Bool, items: [YouMayAlsoLikeObject]) {
		self.items = items
		self.fetchingData = fetching
		self.collectionView.reloadData()
		self.collectionView.layoutIfNeeded()
		debugPrint("Collection view width : \(self.collectionView.width)")
		debugPrint("Colection view items : \(fetchingData ? 5 : items.count)")
	}
}

extension YouMayAlsoLikeContainerCell: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if fetchingData {
			let cell = collectionView.dequeueCell(with: YouMayAlsoLikeShimmerCell.self, indexPath: indexPath)
			return cell
		} else {
			let cell = collectionView.dequeueCell(with: YouMayAlsoLikeCollectionViewCell.self, indexPath: indexPath)
			cell.configure(items[indexPath.item])
			cell.addYouMayAlsoLike = { [weak self] in
				self?.addYouMayAlsoLike?($0)
			}
			return cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		fetchingData ? 5 : items.count
	}
}
