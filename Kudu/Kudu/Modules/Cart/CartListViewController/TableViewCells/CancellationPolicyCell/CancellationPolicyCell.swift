//
//  CancellationPolicyCell.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import UIKit

class CancellationPolicyCell: UITableViewCell {
	@IBOutlet private weak var policyText: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
		selectionStyle = .none
		setPolicyText()
        titleLabel.text = LSCollection.CartScren.cPolicy
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
	
	private func setPolicyText() {
		policyText.text = CartUtility.getCancellationPolicy
	}

}
