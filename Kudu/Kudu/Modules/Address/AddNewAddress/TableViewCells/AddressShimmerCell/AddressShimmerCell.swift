//
//  AddressShimmerCell.swift
//  Kudu
//
//  Created by Admin on 20/09/22.
//

import UIKit

class AddressShimmerCell: UITableViewCell {
    @IBOutlet private weak var shimmerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        shimmerView.startShimmering()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
