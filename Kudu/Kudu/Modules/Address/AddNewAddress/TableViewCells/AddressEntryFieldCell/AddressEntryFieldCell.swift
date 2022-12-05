//
//  AddressEntryFieldCell.swift
//  Kudu
//
//  Created by Admin on 13/07/22.
//

import UIKit

class AddressEntryFieldCell: UITableViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var phoneTF: UITextField!
    @IBOutlet private weak var phoneEntryContainerView: UIView!
    @IBOutlet private weak var entryContainerView: UIView!
    @IBOutlet private weak var entryTFView: AppTextFieldView!
    @IBOutlet private weak var countryCodeLabel: UILabel!
    @IBOutlet private weak var phoneTFLeftPadding: NSLayoutConstraint!
    
    typealias CellType = AddNewAddressView.CellType
    
    private var entryType: CellType = .name
    
    var textEntered: ((CellType, String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
        // Initialization code
    }
    
    private func initialSetup() {
        self.selectionStyle = .none
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped)))
        entryTFView.backgroundColor = .clear
        entryTFView.font = AppFonts.mulishMedium.withSize(14)
        phoneEntryContainerView.semanticContentAttribute = .forceLeftToRight
        phoneTF.semanticContentAttribute = .forceLeftToRight
    }
    
    private func setupPhoneTextField() {
        phoneTF.keyboardType = .phonePad
        phoneTF.delegate = self
        phoneTF.textContentType = UITextContentType(rawValue: "")
        phoneTF.autocorrectionType = .no
        phoneTF.autocapitalizationType = .none
        phoneTF.spellCheckingType = .no
        phoneTF.tintColor = .black
        if entryType == .zipCode {
            mainThread {
                self.phoneTF.keyboardType = .numberPad
                self.countryCodeLabel.text = ""
                self.phoneTFLeftPadding.constant = 0
            }
        }
        phoneTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupEntryTextField() {
        entryTFView.textFieldType = entryType == .name ? .name : .address
    }
    
    private func setPlaceholder() {
        var placeholder = ""
        switch self.entryType {
        case .name:
            placeholder = LSCollection.AddNewAddress.enterYourName
        case .phoneNum:
            placeholder = LSCollection.AddNewAddress.enterMobileNumberOptional
//        case .buildingName:
//            placeholder = LocalizedStrings.AddNewAddress.buildingName
//        case .city:
//            placeholder = LocalizedStrings.AddNewAddress.city
//        case .state:
//            placeholder = LocalizedStrings.AddNewAddress.state
        case .landmark:
            placeholder = LSCollection.AddNewAddress.landmark
        case .zipCode:
            placeholder = LSCollection.AddNewAddress.zipCode
        default:
            break
        }
        if self.entryType == .phoneNum || self.entryType == .zipCode {
            phoneTF.placeholder = placeholder
        } else {
            entryTFView.placeholderText = placeholder
        }
    
        entryTFView.textFieldFinishedEditing = { [weak self] in
            let enteredString = $0 ?? ""
            debugPrint("Text field ended : \(enteredString)")
            self?.textEntered?(self?.entryType ?? .name, enteredString)
        }
    }
    
    @objc private func containerTapped() {
        if self.entryType == .phoneNum || self.entryType == .zipCode {
            phoneTF.becomeFirstResponder()
        } else {
            entryTFView.focus()
        }
    }
    
    func configure(type: CellType, entry: String?, prefillAttempted: Bool = false) {
        self.entryType = type
        if type == .phoneNum || type == .zipCode {
            setupPhoneTextField()
            phoneTF.text = entry
            phoneTF.isUserInteractionEnabled = true
            if type == .zipCode {
                if prefillAttempted {
                    phoneTF.isUserInteractionEnabled = (entry ?? "").isEmpty
                } else {
                    phoneTF.isUserInteractionEnabled = false
                }
            }
        } else {
            setupEntryTextField()
            entryTFView.currentText = entry ?? ""
        }
        setPlaceholder()
        entryTFView.isUserInteractionEnabled = !(type == .phoneNum || type == .zipCode)
        entryContainerView.isHidden = (type == .phoneNum || type == .zipCode)
        phoneEntryContainerView.isHidden = (type != .phoneNum && type != .zipCode)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

extension AddressEntryFieldCell: UITextFieldDelegate {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if (textField.text ?? "").count == 9 && self.entryType == .phoneNum {
            textField.resignFirstResponder()
           // self.setupButton(state: .enabled)
        } else {
           // self.setupButton(state: .disabled)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        debugPrint("Text field ended : \(textField.text ?? "")")
        self.textEntered?(entryType, text)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text: NSString = (textField.text ?? "") as NSString
        let newString = text.replacingCharacters(in: range, with: string)
        return self.entryType == .phoneNum ? self.validatePhoneNumber(newString, string) : self.validateZipCode(newString, string)
    }
    
    private func validatePhoneNumber(_ newString: String, _ string: String) -> Bool {
        let allowed = CharacterSet(charactersIn: "1234567890")
        let enteredCharacterSet = CharacterSet(charactersIn: newString)
        if !enteredCharacterSet.isSubset(of: allowed) || newString.count > 9 {
            return false
        }
        return true
    }
    
    private func validateZipCode(_ newString: String, _ string: String) -> Bool {
        let allowed = CharacterSet(charactersIn: "1234567890")
        let enteredCharacterSet = CharacterSet(charactersIn: newString)
        if !enteredCharacterSet.isSubset(of: allowed) {
            return false
        }
        return true
    }
}
