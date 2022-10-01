//
//  FeedbackEmailCell.swift
//  Kudu
//
//  Created by Admin on 22/07/22.
//

import UIKit

class FeedbackEmailCell: UITableViewCell {
    @IBOutlet weak var tfContainerView: UIView!
    @IBOutlet weak var emailTFView: AppTextFieldView!
    
    var textEntered: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        emailTFView.textFieldType = .name
        emailTFView.backgroundColor = .clear
        emailTFView.placeholderText = LocalizedStrings.Setting.emailIdOptional
        tfContainerView.backgroundColor = AppColors.SendFeedbackScreen.textfieldBg
        tfContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped)))
        emailTFView.textFieldFinishedEditing = { [weak self] in
            let enteredString = $0 ?? ""
            debugPrint("Text field ended : \(enteredString)")
            self?.textEntered?(enteredString)
        }
    }
    
    @objc private func containerTapped() {
        emailTFView.focus()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(_ text: String) {
        emailTFView.currentText = text
    }
}
