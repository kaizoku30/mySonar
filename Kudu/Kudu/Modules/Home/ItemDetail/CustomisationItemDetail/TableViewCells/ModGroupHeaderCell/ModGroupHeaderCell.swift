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
        requiredBtn.setTitle(LSCollection.ExploreMenu.requiredBtnTitle, for: .normal)
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
            if AppUserDefaults.selectedLanguage() == .ar {
                var conversionString = "حدد 1 إلى 3 من 5 خيارات"
                conversionString = conversionString.replace(string: "1", withString: "\(min)")
                conversionString = conversionString.replace(string: "3", withString: "\(max)")
                conversionString = conversionString.replace(string: "5", withString: "\(total)")
                subtitleLabel.text = conversionString
            }
		}
		
		if min > 0 && max == 0 {
			subtitleLabel.text = "Select \(min) out of \(total) options"
            if AppUserDefaults.selectedLanguage() == .ar {
                var conversionString = "اختر 1 او 2"
                conversionString = conversionString.replace(string: "2", withString: "\(total)")
                conversionString = conversionString.replace(string: "1", withString: "\(min)")
                subtitleLabel.text = conversionString
            }
		}
		
		if max > 0 && min == 0 {
			subtitleLabel.text = "Select \(max) out of \(total) options"
            if AppUserDefaults.selectedLanguage() == .ar {
                var conversionString = "اختر 1 او 2"
                conversionString = conversionString.replace(string: "2", withString: "\(total)")
                conversionString = conversionString.replace(string: "1", withString: "\(max)")
                subtitleLabel.text = conversionString
            }
		}
		
		if min == max && min > 0 && max > 0 {
			subtitleLabel.text = "Select \(min) out of \(total) options"
            if AppUserDefaults.selectedLanguage() == .ar {
                var conversionString = "اختر 1 او 2"
                conversionString = conversionString.replace(string: "2", withString: "\(total)")
                conversionString = conversionString.replace(string: "1", withString: "\(min)")
                subtitleLabel.text = conversionString
            }
		}
		
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
