//
//  RatingOrderTableViewCell.swift
//  Kudu
//
//  Created by Admin on 13/10/22.
//

import UIKit
import Cosmos

class RatingOrderTableViewCell: UITableViewCell {
    @IBOutlet weak var comsosView: CosmosView!
    @IBOutlet weak var ratingDescription: UILabel!
    
    func configure(rating: Double, desc: String) {
        comsosView.settings.fillMode = .half
        comsosView.rating = rating
        ratingDescription.text = desc
    }
}
