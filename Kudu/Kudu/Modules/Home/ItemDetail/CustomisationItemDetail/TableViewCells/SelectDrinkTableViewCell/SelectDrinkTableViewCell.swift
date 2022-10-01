//
//  SelectDrinkSizeTableViewCell.swift
//  Kudu
//
//  Created by Admin on 10/08/22.
//

import UIKit

class SelectDrinkTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var optionSubtitle: UILabel!
    @IBOutlet private weak var sizeSubtitle: UILabel!
    @IBOutlet private weak var drinkSizeCollectionView: UICollectionView!
    @IBOutlet private weak var drinkObjectsCollectionView: UICollectionView!
    
    var drinkSelectionChanged: ((String, String, String) -> Void)?
    var drinkSizeSelectionChanged: ((String, String, String) -> Void)?
    private var selectedDrinkSize: DrinkSize = .regular
    private var drinksSizeTypes: [DrinkSizeObject] = []
    private var drinkObjects: [ModifierObject] = []
    private var subArrayRegular: [ModifierObject] = []
    private var subArrayMedium: [ModifierObject] = []
    private var subArrayLarge: [ModifierObject] = []
    private var selectedModifier: ModifierObject!
    private var modGroup: ModGroup!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        sizeSubtitle.text = "Select Size"
        optionSubtitle.text = ""
        drinkObjectsCollectionView.registerCell(with: DrinkObjectCollectionViewCell.self)
        drinkSizeCollectionView.registerCell(with: DrinkSizeCollectionViewCell.self)
		let semantics: UISemanticContentAttribute = AppUserDefaults.selectedLanguage() == .en ? .forceLeftToRight : .forceRightToLeft
		optionSubtitle.semanticContentAttribute = semantics
		sizeSubtitle.semanticContentAttribute = semantics
		drinkObjectsCollectionView.semanticContentAttribute = semantics
		drinkSizeCollectionView.semanticContentAttribute = semantics
		
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(drinkModGroup: ModGroup) {
        self.modGroup = drinkModGroup
        self.drinkObjects = drinkModGroup.modifiers ?? []
        let drinksToFilter = self.drinkObjects
        self.subArrayRegular = drinksToFilter.filter({ $0.drinkSize ?? "" == DrinkSize.regular.rawValue })
        self.subArrayMedium = drinksToFilter.filter({ $0.drinkSize ?? "" == DrinkSize.medium.rawValue })
        self.subArrayLarge = drinksToFilter.filter({ $0.drinkSize ?? "" == DrinkSize.large.rawValue })
        drinksSizeTypes = ModGroup.sortAndGetDrinkSizes(drinks: drinkModGroup.modifiers ?? [])
        if let selectedIndex = self.drinkObjects.firstIndex(where: { $0.addedToTemplate ?? false == true }) {
            selectedModifier = self.drinkObjects[selectedIndex]
            selectedDrinkSize = DrinkSize(rawValue: self.drinkObjects[selectedIndex].drinkSize ?? "") ?? .regular
            for i in 0..<drinksSizeTypes.count {
                if drinksSizeTypes[i].drinkSize == selectedDrinkSize {
                    drinksSizeTypes[i].selectedState = true
                } else {
                    drinksSizeTypes[i].selectedState = false
                }
            }
        }
        switch selectedDrinkSize {
        case .regular:
            optionSubtitle.text = LocalizedStrings.CustomisableDetail.select1OutOfXOptions.replace(string: CommonStrings.numberPlaceholder, withString: "\(subArrayRegular.count )")
        case .medium:
            optionSubtitle.text = LocalizedStrings.CustomisableDetail.select1OutOfXOptions.replace(string: CommonStrings.numberPlaceholder, withString: "\(subArrayMedium.count )")
        case .large:
            optionSubtitle.text = LocalizedStrings.CustomisableDetail.select1OutOfXOptions.replace(string: CommonStrings.numberPlaceholder, withString: "\(subArrayLarge.count )")
        }
		if AppUserDefaults.selectedLanguage() == .ar {
			drinksSizeTypes = drinksSizeTypes.reversed()
		}
        drinkSizeCollectionView.reloadData()
        drinkObjectsCollectionView.reloadData()
    }
}

extension SelectDrinkTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == drinkSizeCollectionView {
            return drinksSizeTypes.count
        }
        switch selectedDrinkSize {
        case .regular:
            return subArrayRegular.count
        case .medium:
            return subArrayMedium.count
        case .large:
            return subArrayLarge.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == drinkSizeCollectionView {
            let cell = collectionView.dequeueCell(with: DrinkSizeCollectionViewCell.self, indexPath: indexPath)
           // debugPrint("Current State : \(drinksSizeTypes[indexPath.row].drinkSize) \(drinksSizeTypes[indexPath.row].selectedState)")
            cell.configure(drinkSize: drinksSizeTypes[indexPath.row].drinkSize, selectedState: drinksSizeTypes[indexPath.row].selectedState)
            return cell
        }
        
        let cell = collectionView.dequeueCell(with: DrinkObjectCollectionViewCell.self, indexPath: indexPath)
        switch selectedDrinkSize {
        case .regular:
            cell.configure(imgUrl: subArrayRegular[indexPath.row].modifierImageUrl ?? "", selectedState: subArrayRegular[indexPath.row].addedToTemplate ?? false)
        case .medium:
            cell.configure(imgUrl: subArrayMedium[indexPath.row].modifierImageUrl ?? "", selectedState: subArrayMedium[indexPath.row].addedToTemplate ?? false)
        case .large:
            cell.configure(imgUrl: subArrayLarge[indexPath.row].modifierImageUrl ?? "", selectedState: subArrayLarge[indexPath.row].addedToTemplate ?? false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == drinkSizeCollectionView {
            let currentType = selectedDrinkSize
            let newType = drinksSizeTypes[indexPath.item].drinkSize
            if currentType != newType {
                drinksSizeTypes = drinksSizeTypes.map({
                    var type = $0
                    type.selectedState = false
                    return type
                })
                drinksSizeTypes[indexPath.item].selectedState = true
                self.selectedDrinkSize = drinksSizeTypes[indexPath.item].drinkSize
                debugPrint("Previously selected id : \(selectedModifier._id ?? "")")
                self.drinkSizeSelectionChanged?(self.selectedDrinkSize.rawValue, self.modGroup._id ?? "", selectedModifier._id ?? "")
                return
            }
        } else {
            debugPrint("Need to setup touch selection")
            var newModifierId: String = ""
            let oldModifierId = selectedModifier._id ?? ""
            switch selectedDrinkSize {
            case .regular:
                newModifierId = subArrayRegular[indexPath.item]._id ?? ""
            case .medium:
                newModifierId = subArrayMedium[indexPath.item]._id ?? ""
            case .large:
                newModifierId = subArrayLarge[indexPath.item]._id ?? ""
            }
            if newModifierId != oldModifierId {
                self.drinkSelectionChanged?(oldModifierId, newModifierId, modGroup._id ?? "")
            }
        }
    }
}

extension SelectDrinkTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == drinkSizeCollectionView {
            let font = AppFonts.mulishBold.withSize(12)
            let fontAttributes = [NSAttributedString.Key.font: font]
            let text = drinksSizeTypes[indexPath.row].drinkSize.title
            let size = (text as NSString).size(withAttributes: fontAttributes)
            return CGSize(width: size.width + 20 + 24, height: 30)
        } else {
            return CGSize(width: 82, height: 46)
        }
        
    }
}
