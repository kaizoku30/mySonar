//
//  TopSearchCategoriesCell.swift
//  Kudu
//
//  Created by Admin on 28/07/22.
//

import UIKit

class TopSearchCategoriesCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var topCategories: [MenuCategory] = []
    var performOperation: ((MenuCategory) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        titleLabel.text = LocalizedStrings.SearchMenu.topSearchedCategories
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.registerCell(with: ExploreMenuCategoryCollectionViewCell.self)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ topCategories: [MenuCategory]) {
        self.topCategories = topCategories
        collectionView.reloadData()
    }

}

extension TopSearchCategoriesCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < topCategories.count {
            let item = topCategories[indexPath.row]
            self.performOperation?(item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: ExploreMenuCategoryCollectionViewCell.self, indexPath: indexPath)
        if indexPath.row < topCategories.count {
            cell.configure(item: topCategories[indexPath.row])
        }
        return cell
    }

}
