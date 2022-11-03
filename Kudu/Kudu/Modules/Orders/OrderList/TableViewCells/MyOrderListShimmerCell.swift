//
//  MyOrderListShimmerCell.swift
//  Kudu
//
//  Created by Admin on 10/10/22.
//

import UIKit

class MyOrderListShimmerCell: UITableViewCell {
    @IBOutlet weak private var shimmerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shimmerView.startShimmering()
    }
}
