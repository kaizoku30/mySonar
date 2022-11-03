//
//  SaveCardCheckboxTVCell.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit

class SaveCardCheckboxTVCell: UITableViewCell {
    @IBOutlet private weak var saveCardInfoView: UIView!
    @IBOutlet private weak var defaultCheckbox: UIImageView!
    @IBOutlet private weak var saveCardCheckbox: UIImageView!
    private let unselected = AppImages.AddAddress.checkBoxUnselected
    private let selectedCheck = AppImages.AddAddress.checkBoxSelected
    
    private var isDefault = false
    private var isSaved = false
    
    var defaultCardChanged: ((Bool) -> Void)?
    var savedCardChanged: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        saveCardInfoView.isHidden = true
        defaultCheckbox.image = unselected
        saveCardCheckbox.image = unselected
        defaultCheckbox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(defaultCardTapped)))
        saveCardCheckbox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveCardTapped)))
    }
    
    @objc private func saveCardTapped() {
        savedCardChanged?(!isSaved)
    }
    
    @objc private func defaultCardTapped() {
        defaultCardChanged?(!isDefault)
    }
    
    func configure(isDefault: Bool, savedCard: Bool) {
        self.isDefault = isDefault
        self.isSaved = savedCard
        defaultCheckbox.image = isDefault ? selectedCheck : unselected
        saveCardCheckbox.image = savedCard ? selectedCheck : unselected
        saveCardInfoView.isHidden = !savedCard
    }
}
