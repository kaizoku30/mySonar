//
//  ShimmerExploreCell.swift
//  Kudu
//
//  Created by Admin on 14/09/22.
//

import UIKit

class ShimmerExploreCell: UITableViewCell {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		selectionStyle = .none
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.registerCell(with: ExploreMenuCategoryCollectionViewCell.self)
		tableView.delegate = self
		tableView.dataSource = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure() {
        self.collectionView.reloadData()
        self.tableView.reloadData()
    }
    
}

extension ShimmerExploreCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		CGSize(width: 80, height: 89)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 5
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueCell(with: ExploreMenuCategoryCollectionViewCell.self, indexPath: indexPath)
		cell.shimmer()
		return cell
	}
}

extension ShimmerExploreCell: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: ShimmerExploreResultCell.self)
        cell.configure()
		return cell
	}
}
