//
//  SelectDrinkSizeTableViewCell.swift
//  Kudu
//
//  Created by Admin on 10/08/22.
//

import UIKit

class SelectDrinkSizeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var drinkSizeTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        drinkSizeTitle.font = AppFonts.mulishRegular.withSize(10)
        collectionView.registerCell(with: DrinkSizeCollectionViewCell.self)
        //        collectionView.registerCell(with: DrinkTypeCollectionViewCell.self)
        self.drinkSizeTitle.text = "Please set a value for Facebook AutoLog AppEvents Enabled. Set the flag to TRUE if you want to collect app install, app launch and in-app purchase events automatically "
        collectionView.reloadData()
    }
    struct DrinkSize {
        let sizeName: String
        var buttonState: Bool
    }
    var drinkSize = [DrinkSize(sizeName: "Regular", buttonState: false), DrinkSize(sizeName: "Medium", buttonState: false), DrinkSize(sizeName: "Large", buttonState: false)]
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension SelectDrinkSizeTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: DrinkSizeCollectionViewCell.self, indexPath: indexPath)
        cell.drinkSizeLabel.text = drinkSize[indexPath.item].sizeName
        if  drinkSize[indexPath.item].buttonState {
            cell.layer.borderColor = AppColors.ExploreMenuScreen.selectedDrinkSize.cgColor
            cell.drinkSizeLabel.textColor = AppColors.ExploreMenuScreen.selectedDrinkSize
            cell.layer.backgroundColor = AppColors.ExploreMenuScreen.selectedDrinkSizeBackgroundColor.cgColor
            for index in 0..<drinkSize.count {
                drinkSize[index].buttonState = false
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        drinkSize[indexPath.item].buttonState = true
        collectionView.reloadData()
    }
}

extension SelectDrinkSizeTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 79, height: 30)
    }
}
