//
//  HomeFavouritesCell.swift
//  Kudu
//
//  Created by Admin on 08/07/22.
//

import UIKit

class HomeFavouritesCell: UITableViewCell {
    @IBOutlet private weak var favouritesLabel: UILabel!
    @IBOutlet private weak var orderFromListLabel: UILabel!
    @IBOutlet private weak var orderNowLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        favouritesLabel.text = LocalizedStrings.Home.favourites
        orderFromListLabel.text = LocalizedStrings.Home.orderFromListOfFavourites
        orderNowLabel.text = LocalizedStrings.Home.orderNow
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
