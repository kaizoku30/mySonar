//
//  FeedbackNameCell.swift
//  Kudu
//
//  Created by Admin on 22/07/22.
//

import UIKit

class FeedbackNameCell: UITableViewCell {

    @IBOutlet weak var nameTFView: AppTextFieldView!
    @IBOutlet weak var tfContainerView: UIView!
    
    var textEntered: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        nameTFView.textFieldType = .name
        nameTFView.backgroundColor = .clear
        nameTFView.placeholderText = LSCollection.Setting.enterYourName
        tfContainerView.backgroundColor = AppColors.SendFeedbackScreen.textfieldBg
        tfContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped)))
        nameTFView.textFieldFinishedEditing = { [weak self] in
            let enteredString = $0 ?? ""
            debugPrint("Text field ended : \(enteredString)")
            self?.textEntered?(enteredString)
        }
    }

    @objc private func containerTapped() {
        nameTFView.focus()
    }
    
    func configure(_ text: String) {
        nameTFView.currentText = text
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
