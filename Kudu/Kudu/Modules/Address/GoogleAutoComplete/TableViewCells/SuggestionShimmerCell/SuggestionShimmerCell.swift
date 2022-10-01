
//
//  SuggestionShimmerCell.swift
//  Kudu
//
//  Created by Admin on 11/09/22.
//

import UIKit

class SuggestionShimmerCell: UITableViewCell {
	@IBOutlet private weak var imageShimmer: UIView!
	@IBOutlet private weak var titleShimmer: UIView!
	@IBOutlet private weak var subtitleShimmer: UIView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		selectionStyle = .none
		startShimmer()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
	
	private func startShimmer() {
		imageShimmer.startShimmering()
		titleShimmer.startShimmering()
		subtitleShimmer.startShimmering()
	}
    
}
