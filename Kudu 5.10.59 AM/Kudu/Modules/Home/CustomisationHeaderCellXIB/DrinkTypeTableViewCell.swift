//
//  DrinkTypeTableViewCell.swift
//  Kudu
//
//  Created by Admin on 10/08/22.
//

import UIKit

class DrinkTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var drinkSizeTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        drinkSizeTitle.font = AppFonts.mulishRegular.withSize(10)
//        collectionView.registerCell(with: DrinkSizeCollectionViewCell.self)
        collectionView.registerCell(with: DrinkTypeCollectionViewCell.self)
        self.drinkSizeTitle.text = "Please set a value for Facebook AutoLog AppEvents Enabled. Set the flag to TRUE if you want to collect app install, app launch and in-app purchase events automatically "
        collectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    struct DrinkType {
        let drinkImage: UIImage
        var isSelecte: Bool
    }
   var drinkType = [DrinkType(drinkImage: AppImages.ExploreMenu.drinkImage, isSelecte: false),   DrinkType(drinkImage: AppImages.Home.footerImg, isSelecte: false), DrinkType(drinkImage: AppImages.OurStore.storeImagePlaceholder, isSelecte: false)]
    
}

extension DrinkTypeTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueCell(with: DrinkTypeCollectionViewCell.self, indexPath: indexPath)
        if  drinkType[indexPath.item].isSelecte {
            cell.layer.borderColor = AppColors.ExploreMenuScreen.selectedDrinkTypeBorderColor.cgColor
            cell.layer.backgroundColor = AppColors.ExploreMenuScreen.selctDrinkTypeBackgroundColor.cgColor
            for index in 0..<drinkType.count {
                drinkType[index].isSelecte = false
            }
        }
        cell.drinkTypeImage.image = drinkType[indexPath.item].drinkImage
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        drinkType[indexPath.item].isSelecte = true
        collectionView.reloadData()
    }
}

extension DrinkTypeTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 82, height: 46)
    }
}
