//
//  HomeOffersDealsContainerCell.swift
//  Kudu
//
//  Created by Admin on 07/07/22.
//

import UIKit

class HomeOffersDealsContainerCell: UITableViewCell {
    
    @IBOutlet private weak var viewAllButton: AppButton!
    @IBOutlet private weak var collectionView: UICollectionView!

    private var list: [BannerItem] = []
    var redirectFromBanner: ((BannerItem) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.registerCell(with: HomeOfferDealCollectionViewCell.self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(promoArray: [BannerItem]?) {
        if promoArray.isNotNil {
            list = promoArray!
        }
        self.collectionView.reloadData()
    }
    
}

extension HomeOffersDealsContainerCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 217, height: 122)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count == 0 ? 5 : list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: HomeOfferDealCollectionViewCell.self, indexPath: indexPath)
        if indexPath.row < list.count {
            cell.configure(item: list[indexPath.row])
        } else {
            cell.configure(item: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = list[safe: indexPath.item] else { return }
        self.redirectFromBanner?(item)
        
    }
}
