//
//  InStorePromoCell.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit
protocol InStorePromoCellDelegate: AnyObject {
    func viewall()
    func openDetailForIndex(index: Int)
}

class InStorePromoCell: UITableViewCell {
    
    private var promos: [CouponObject] = []
    private weak var delegate: InStorePromoCellDelegate?
    
    @IBOutlet private weak var viewAllButton: AppButton!
    @IBOutlet private weak var inStorePromoLbl: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.registerCell(with: HomeOfferDealCollectionViewCell.self)
        viewAllButton.setTitle(LocalizedStrings.Home.viewAll, for: .normal)
        inStorePromoLbl.text = LocalizedStrings.Home.inStorePromos
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func viewAllTapped(_ sender: AppButton) {
        self.delegate?.viewall()
    }
    
    func configure(promos: [CouponObject], delegate: InStorePromoCellDelegate) {
        self.promos = promos
        self.delegate = delegate
        self.collectionView.reloadData()
    }
}

extension InStorePromoCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 249, height: 122)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return promos.isEmpty ? 4 : promos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: HomeOfferDealCollectionViewCell.self, indexPath: indexPath)
        if indexPath.row < promos.count {
            cell.configure(item: promos[indexPath.row])
        } else {
            cell.configureForNoObject()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < promos.count {
            self.delegate?.openDetailForIndex(index: indexPath.item)
        }
    }
}
