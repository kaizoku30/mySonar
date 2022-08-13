//
//  RecentSearchSectionTitleCell.swift
//  Kudu
//
//  Created by Admin on 20/07/22.
//

import UIKit

class RecentSearchSectionTitleCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var clearBtn: AppButton!
    
    var clearBtnPressed: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        clearBtn.setAttributedTitle(NSAttributedString(string: LocalizedStrings.MapPin.clear, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]), for: .normal)
        clearBtn.handleBtnTap = { [weak self] in
            self?.clearBtnPressed?()
        }
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(type: GoogleAutoCompleteView.SetDeliveryLocationSection) {
        titleLabel.text = type.title
        clearBtn.isHidden = type == .savedAddresses
    }
}
