//
//  AppTextFieldView.swift
//  KUDU
//
//  Created by Admin on 05/01/22.
//

import UIKit
import IQKeyboardManagerSwift

enum AppTextFieldType {
    case email
    case phoneNo
    case password
    case name
    case address
    case couponCode
}

enum AppTextFieldUIType {
    case plain
    case roundedWithBorder
}

class AppTextFieldView: UIView {
    @IBOutlet private weak var txtFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var txtFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet private var mainContentView: UIView!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet private weak var rightClearButton: AppButton!
    @IBAction private func clearBtnPressed(_ sender: Any) {
        txtField.text = ""
        textFieldDidChangeCharacters?(txtField.text)
    }
    @IBOutlet private weak var leftClearButton: AppButton!
    @IBOutlet private weak var leftSpaceConstraint: NSLayoutConstraint! // [ Left Clear Button ] --- [ Textfield ]
    @IBOutlet private weak var leftClearButtonWidth: NSLayoutConstraint! // 0 - 35
    @IBOutlet private weak var rightClearButtonWidth: NSLayoutConstraint!
    @IBOutlet private weak var rightSpaceConstraint: NSLayoutConstraint!
    
    var currentText: String {
        get {
        txtField.text ?? ""
        }
        set {
        txtField.text = newValue
        }
    }
    
    var placeholderText: String {
        didSet {
            txtField.placeholder = placeholderText
        }
    }

    var textFieldClearBtnPressed:(() -> Void)?
    var textFieldDidChangeCharacters: ((String?) -> Void)?
    var textFieldDidBeginEditing: (() -> Void)?
    var textFieldFinishedEditing: ((String?) -> Void)?
    var textFieldValidInputEntered: (() -> Void)?
    var disableTextField: Bool? {
        didSet {
            setTextFieldEnabled()
        }
    }
    
    var font: UIFont? {
        didSet {
            self.txtField.font = font
        }
    }
    var textColor: UIColor? {
        didSet {
            self.txtField.textColor = textColor
        }
    }
    var textFieldType: AppTextFieldType {
        didSet {
            configureTF()
        }
    }
    var textFieldUI: AppTextFieldUIType {
        didSet {
            configureTF()
        }
    }
    var validInputEntered: Bool {
            switch textFieldType {
            case .email:
                return CommonValidation.isValidEmail(txtField.text ?? "")
            case .password:
                return CommonValidation.isValidPassword(currentText)
            case .phoneNo:
                return true
            case .name, .address, .couponCode:
                return true
            }
    }
    var alignmentOfTextField: NSTextAlignment {
        get {
            return txtField.textAlignment
        }
        set {
            txtField.textAlignment = newValue
        }
    }
    private var lastEnteredCharacter = ""
    
    override init(frame: CGRect) {
         placeholderText = ""
         textFieldType = .email
         textFieldUI = .plain
         super.init(frame: frame)
         commonInit()
        
     }
     
     required init?(coder adecoder: NSCoder) {
         placeholderText = ""
         textFieldType = .email
         textFieldUI = .plain
         super.init(coder: adecoder)
         commonInit()
     }

}

extension AppTextFieldView {
    private func commonInit() {
        Bundle.main.loadNibNamed("AppTextFieldView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        txtField.delegate = self
        txtField.textContentType = UITextContentType(rawValue: "")
        txtField.autocorrectionType = .no
        txtField.autocapitalizationType = .none
        txtField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        txtField.spellCheckingType = .no
        txtField.tintColor = AppColors.darkGray
        configureTF()
    }
    
    func setTextFieldEnabled() {
        if self.disableTextField ?? false {
            self.isUserInteractionEnabled = false
            self.backgroundColor = AppColors.gray
            txtField.attributedPlaceholder = NSAttributedString(
                string: txtField.placeholder ?? "",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
            )
        } else {
            self.isUserInteractionEnabled = true
            self.backgroundColor = .clear
            txtField.attributedPlaceholder = NSAttributedString(
                string: txtField.placeholder ?? "",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    func focus() {
        self.txtField.becomeFirstResponder()
    }
    
    func unfocus() {
        self.txtField.resignFirstResponder()
    }
    
    func configureTF() {
        let currentLanguage = AppUserDefaults.selectedLanguage()
        if textFieldType != .phoneNo {
            txtField.textAlignment = currentLanguage == .en ? .left : .right
        } else {
            txtField.textAlignment = .left
        }
        
        switch textFieldType {
        case .email:
            
            //txtField.placeholder = LocalizedStrings.SignUp.emailId
            txtField.keyboardType = .emailAddress
            
        case.phoneNo:
            txtField.textAlignment = .left
            txtField.placeholder = LocalizedStrings.Login.phoneNo
            txtField.keyboardType = .phonePad
        case .password:
         //   txtField.placeholder = LS.Placeholder.password
            txtField.keyboardType = .asciiCapable
            txtField.isSecureTextEntry = true
        case .name, .couponCode:
            txtField.keyboardType = .default
          //  txtField.placeholder = LocalizedStrings.SignUp.name
        case .address:
            txtField.keyboardType = .default
            //txtField.keyboardType = .
        }
        switch textFieldUI {
        case .plain:
            break
        case .roundedWithBorder:
            setUpRoundedTFWithBorder()
        }
    }
    
    func setUpRoundedTFWithBorder() {
        self.backgroundColor = UIColor(r: 196, g: 196, b: 196, alpha: 0.2)
        leftSpaceConstraint.constant = 10
        txtFieldTopConstraint.constant = 10
        txtFieldBottomConstraint.constant = 10
        self.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 4.0
        self.layoutIfNeeded()
    }
    
//    func setupViewForPhoneNumberField() {
//        txtField.textAlignment = .left
//        rightClearButton.isHidden = true
//        rightClearButtonWidth.constant = 0
//        rightSpaceConstraint.constant = 0
//        leftSpaceConstraint.constant = 5
//        leftClearButtonWidth.constant = 35
//        leftClearButton.isHidden = true
//    }
    
}

extension AppTextFieldView: UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textFieldType {
        case .email:
            textField.text = textField.text?.lowercased()
        case .couponCode:
            if currentText.contains(".") {
                textField.text = currentText.replacingOccurrences(of: ".", with: "")
            }
            //textField.text = textField.text?.uppercased()
        case .name, .address:
            if currentText.contains(".") {
                textField.text = currentText.replacingOccurrences(of: ".", with: "")
            }
        case .phoneNo:
            if textField.text?.count ?? 0 == 9 {
                textField.resignFirstResponder()
            }
        case .password:
            break
        }
        
        textFieldDidChangeCharacters?(textField.text)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        CommonFunctions.hideToast()
        switch textFieldType {
        case .email, .name, .password, .address, .couponCode:
            break
           // rightClearButton.isHidden = false
           // leftClearButton.isHidden = false
        case .phoneNo:
            txtField.textAlignment = .left
            
        }
        self.textFieldDidBeginEditing?()
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text: NSString = (textField.text ?? "") as NSString
        let newString = text.replacingCharacters(in: range, with: string)
        switch textFieldType {
        case .email:
            return string != CommonStrings.whiteSpace && !newString.contains(CommonStrings.whiteSpace) && !string.isEmojiString()
        case .phoneNo:
            return self.validatePhoneNumber(newString, string)
        case .password:
            if newString.count > 16 || string == CommonStrings.whiteSpace || newString.contains(CommonStrings.whiteSpace) || string.isEmojiString() {
                return false
            }
            return true
        case .address:
            return self.validateAddressTextField(newString, string)
        case .name:
            return self.validateNameTextField(newString, string)
        case .couponCode:
            return self.valideCouponCode(newString, string)
        }
    }
    
    private func validatePhoneNumber(_ newString: String, _ string: String) -> Bool {
        let allowed = CharacterSet(charactersIn: "1234567890")
        let enteredCharacterSet = CharacterSet(charactersIn: newString)
        if !enteredCharacterSet.isSubset(of: allowed) || newString.count > 9 {
            return false
        }
        return true
    }
    
    private func valideCouponCode(_ newString: String, _ string: String) -> Bool {
        let allowed = CharacterSet.alphanumerics
        let enteredCharacterSet = CharacterSet(charactersIn: newString)
        if !enteredCharacterSet.isSubset(of: allowed) {
            return false
        }
        return true
    }
    
    private func validateNameTextField(_ newString: String, _ string: String) -> Bool {
        
        let alphabetSet = CharacterSet.letters
        let allowedSet = alphabetSet.union(CharacterSet(charactersIn: CommonStrings.whiteSpace))
        let enteredSet = CharacterSet(charactersIn: newString)
        
        if currentText == CommonStrings.emptyString && string == CommonStrings.whiteSpace {
            return false
        }
        
        if newString.count > 40 || (string == CommonStrings.whiteSpace && lastEnteredCharacter == CommonStrings.whiteSpace) {
            return false
        }
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        let isArabic = predicate.evaluate(with: newString)
        
        if !enteredSet.isSubset(of: allowedSet) && isArabic == false {
            return false
        }
        lastEnteredCharacter = string
        return true
    }
    
    private func validateAddressTextField(_ newString: String, _ string: String) -> Bool {
        
        let alphabetSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-,"))
        let allowedSet = alphabetSet.union(CharacterSet(charactersIn: CommonStrings.whiteSpace))
        let enteredSet = CharacterSet(charactersIn: newString)
        
        if currentText == CommonStrings.emptyString && string == CommonStrings.whiteSpace {
            return false
        }
        
        if newString.count > 80 || (string == CommonStrings.whiteSpace && lastEnteredCharacter == CommonStrings.whiteSpace) {
            return false
        }
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        let isArabic = predicate.evaluate(with: newString)
        
        if !enteredSet.isSubset(of: allowedSet) && isArabic == false {
            return false
        }
        lastEnteredCharacter = string
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        leftClearButton.isHidden = true
        rightClearButton.isHidden = true
        switch textFieldType {
        case .email:
            debugPrint("Valid email :\(CommonValidation.isValidEmail(textField.text ?? ""))")
        case .phoneNo, .password, .name, .address, .couponCode:
            break
        }
        textFieldFinishedEditing?(textField.text)
    }
}
