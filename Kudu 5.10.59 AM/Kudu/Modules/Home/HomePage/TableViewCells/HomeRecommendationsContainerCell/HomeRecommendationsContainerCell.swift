//
//  HomeRecommendationsContainerCell.swift
//  Kudu
//
//  Created by Admin on 07/07/22.
//

import UIKit

class HomeRecommendationsContainerCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var recommendationLabel: UILabel!
    @IBOutlet private weak var viewAllButton: AppButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        recommendationLabel.text = LocalizedStrings.Home.recommendations
        viewAllButton.setTitle(LocalizedStrings.Home.viewAll, for: .normal)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.registerCell(with: HomeRecommendationCollectionViewCell.self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension HomeRecommendationsContainerCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 158, height: 158)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: HomeRecommendationCollectionViewCell.self, indexPath: indexPath)
        return cell
    }
}
