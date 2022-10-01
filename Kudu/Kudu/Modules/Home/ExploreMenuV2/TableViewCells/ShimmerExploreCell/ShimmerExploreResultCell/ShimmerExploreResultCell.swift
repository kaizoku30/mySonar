//
//  ShimmerExploreResultCell.swift
//  Kudu
//
//  Created by Admin on 20/09/22.
//

import UIKit

class ShimmerExploreResultCell: UITableViewCell {
    @IBOutlet weak var shimmerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //shimmerView.startShimmering()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configure() {
        shimmerView.startShimmering()
    }
    
}
