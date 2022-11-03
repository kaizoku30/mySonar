//
//  CartCouponShimmerCell.swift
//  Kudu
//
//  Created by Admin on 06/10/22.
//

import UIKit

class CartCouponShimmerCell: UITableViewCell {
    @IBOutlet private weak var shimmerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerView.startShimmering()
    }
    
}
