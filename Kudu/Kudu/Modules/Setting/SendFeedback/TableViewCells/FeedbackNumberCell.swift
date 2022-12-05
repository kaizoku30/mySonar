//
//  FeedbackNumberCell.swift
//  Kudu
//
//  Created by Admin on 22/07/22.
//

import UIKit

class FeedbackNumberCell: UITableViewCell {
    @IBOutlet weak var tfContainerView: UIView!
    @IBOutlet weak var phoneTF: UITextField!
    
    var textEntered: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        tfContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped)))
        tfContainerView.backgroundColor = AppColors.SendFeedbackScreen.textfieldBg
        tfContainerView.semanticContentAttribute = .forceLeftToRight
        phoneTF.placeholder = LSCollection.Setting.enterMobileNumber
        phoneTF.semanticContentAttribute = .forceLeftToRight
        phoneTF.keyboardType = .phonePad
        phoneTF.delegate = self
        phoneTF.textContentType = UITextContentType(rawValue: "")
        phoneTF.autocorrectionType = .no
        phoneTF.autocapitalizationType = .none
        phoneTF.spellCheckingType = .no
        phoneTF.tintColor = .black
        phoneTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        // Initialization code
    }
    
    @objc private func containerTapped() {
        phoneTF.becomeFirstResponder()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ text: String) {
        phoneTF.text = text
    }

}

extension FeedbackNumberCell: UITextFieldDelegate {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if (textField.text ?? "").count == 9 {
            textField.resignFirstResponder()
           // self.setupButton(state: .enabled)
        } else {
           // self.setupButton(state: .disabled)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        debugPrint("Text field ended : \(textField.text ?? "")")
        self.textEntered?(text)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let phoneTextfieldText: NSString = (textField.text ?? "") as NSString
        let newPhoneTextfieldText = phoneTextfieldText.replacingCharacters(in: range, with: string)
        return self.validatePhoneNumber(newPhoneTextfieldText, string)
    }
}
