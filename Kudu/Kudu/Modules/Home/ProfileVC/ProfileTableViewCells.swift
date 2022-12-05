//
//  ProfileTableViewCells.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit

class ProfileTitleCell: UITableViewCell {
    @IBOutlet weak var titleLabelCell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}

class ProfileActionTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabelCell: UILabel!
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}

class OurStoreTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = LSCollection.Profile.ourStore
        self.selectionStyle = .none
    }
}

class LanguagePickerCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arabicLanguageSwitch: UISwitch!
    
    @IBAction func languageChanged(_ sender: UISwitch) {
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
        arabicLanguageSwitch.semanticContentAttribute = .forceLeftToRight
    }
    
    func configure() {
        arabicLanguageSwitch.backgroundColor = AppColors.kuduThemeBlue
        arabicLanguageSwitch.onTintColor = AppColors.kuduThemeBlue
        arabicLanguageSwitch.cornerRadius = arabicLanguageSwitch.height/2
        titleLabel.text = LSCollection.Profile.language
        arabicLanguageSwitch.setOn(false, animated: true)
    }
}
