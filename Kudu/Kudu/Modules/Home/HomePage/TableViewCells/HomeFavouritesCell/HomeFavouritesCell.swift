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
    
    var goToMyFavourites: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        favouritesLabel.text = LSCollection.Home.favourites
        orderFromListLabel.text = LSCollection.Home.orderFromListOfFavourites
        orderNowLabel.text = LSCollection.Home.orderNow
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped)))
    }
    
    @objc private func containerTapped() {
        goToMyFavourites?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
