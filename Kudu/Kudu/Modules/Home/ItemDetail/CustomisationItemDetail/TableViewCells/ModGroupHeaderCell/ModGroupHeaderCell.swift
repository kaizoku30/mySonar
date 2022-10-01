//
//  ModGroupHeaderCell.swift
//  Kudu
//
//  Created by Admin on 09/08/22.
//

import UIKit

class ModGroupHeaderCell: UITableViewCell {

	@IBOutlet private weak var subtitleLabel: UILabel!
	@IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var requiredBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        requiredBtn.isUserInteractionEnabled = false
		if AppUserDefaults.selectedLanguage() == .ar {
			contentView.semanticContentAttribute = .forceRightToLeft
		}
    }
    
	func configure(title: String?, isRequired: Bool, modGroup: ModGroup) {
        titleLabel.text = title
        requiredBtn.isHidden = !isRequired
		let min = modGroup.minimum ?? 0
		let max = modGroup.maximum ?? 0
		let total = modGroup.modifiers?.count ?? 0
		
		let modGroup = ModType(rawValue: modGroup.modType ?? "")
		if modGroup ?? .drink == .drink {
            subtitleLabel.text = ""
			return
		}
		
		if min == 0 && max == 0 {
			subtitleLabel.text = ""
		}
		
		if min > 0 && max > 0 && min != max && max > min {
			subtitleLabel.text = "Select \(min) to \(max) out of \(total) options"
		}
		
		if min > 0 && max == 0 {
			subtitleLabel.text = "Select \(min) out of \(total) options"
		}
		
		if max > 0 && min == 0 {
			subtitleLabel.text = "Select \(max) out of \(total) options"
		}
		
		if min == max && min > 0 && max > 0 {
			subtitleLabel.text = "Select \(min) out of \(total) options"
		}
		
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
