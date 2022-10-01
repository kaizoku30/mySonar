//
//  ResultShimmerTableViewCell.swift
//  Kudu
//
//  Created by Admin on 11/09/22.
//

import UIKit

class ResultShimmerTableViewCell: UITableViewCell {
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
