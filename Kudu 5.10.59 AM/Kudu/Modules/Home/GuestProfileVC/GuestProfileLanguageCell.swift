//
//  GuestProfileLanguageCell.swift
//  Kudu
//
//  Created by Admin on 09/08/22.
//

import UIKit

class GuestProfileLanguageCell: UITableViewCell {
    @IBOutlet private weak var arabicLanguageSwitch: UISwitch!
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBAction func languageSwitched(_ sender: Any) {
        let selectedLanguage = AppUserDefaults.selectedLanguage()
        if selectedLanguage == .ar {
            changeLanguageToArabic?(false)
        } else {
            changeLanguageToArabic?(true)
        }
    }
    
    var changeLanguageToArabic: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        titleLabel.text = LocalizedStrings.Profile.language
        arabicLanguageSwitch.semanticContentAttribute = .forceLeftToRight
    }
    
    func configure() {
        arabicLanguageSwitch.backgroundColor = AppColors.kuduThemeBlue
        arabicLanguageSwitch.onTintColor = AppColors.kuduThemeBlue
        arabicLanguageSwitch.cornerRadius = arabicLanguageSwitch.height/2
        arabicLanguageSwitch.setOn(false, animated: true)
    }
}
