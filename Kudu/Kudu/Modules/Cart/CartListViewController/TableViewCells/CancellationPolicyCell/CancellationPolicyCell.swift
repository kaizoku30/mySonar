//
//  CancellationPolicyCell.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import UIKit

class CancellationPolicyCell: UITableViewCell {
	@IBOutlet private weak var policyText: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		selectionStyle = .none
		setPolicyText()
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
