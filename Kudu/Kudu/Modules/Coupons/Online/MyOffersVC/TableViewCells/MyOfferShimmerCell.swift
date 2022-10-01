//
//  MyOfferShimmerCell.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import UIKit

class MyOfferShimmerCell: UITableViewCell {
    @IBOutlet private weak var shimmerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure() {
        shimmerView.startShimmering()
    }

}
