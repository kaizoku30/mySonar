//
//  StoreListMinDetailCell.swift
//  Kudu
//
//  Created by Admin on 27/09/22.
//

import UIKit

class StoreListMinDetailCell: UITableViewCell {
    @IBOutlet private weak var storeNameLabel: UILabel!
    @IBOutlet private weak var storeAddressLabel: UILabel!
    
    func configure(_ obj: StoreMinDetail) {
        let lang = AppUserDefaults.selectedLanguage()
        storeNameLabel.text = lang == .en ? obj.nameEnglish ?? "" : obj.nameArabic ?? ""
        storeAddressLabel.text = lang == .en ? obj.restaurantLocation?.areaNameEnglish ?? "" : obj.restaurantLocation?.areaNameArabic ?? ""
    }
}

class StoreListShimmerCell: UITableViewCell {
    @IBOutlet private weak var shimmerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shimmerView.startShimmering()
    }
}
