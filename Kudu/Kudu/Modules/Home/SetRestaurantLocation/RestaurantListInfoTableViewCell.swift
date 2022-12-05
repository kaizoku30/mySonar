//
//  RestaurantListInfoTableViewCell.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit

class RestaurantListInfoTableViewCell: UITableViewCell {
    @IBOutlet private weak var storeNearYouLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(numberOfStores: Int?) {
        storeNearYouLabel.isHidden = numberOfStores.isNil
        if numberOfStores == 1 {
            storeNearYouLabel.text = LSCollection.SetRestaurant.xStoreNearYou.replace(string: CommonStrings.numberPlaceholder, withString: "\(numberOfStores ?? 0)")
        } else {
            storeNearYouLabel.text = LSCollection.SetRestaurant.xStoresNearYou.replace(string: CommonStrings.numberPlaceholder, withString: "\(numberOfStores ?? 0)")
        }
        
    }

}
