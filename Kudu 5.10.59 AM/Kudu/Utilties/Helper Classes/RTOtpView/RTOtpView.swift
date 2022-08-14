//
//  RTOtpView.swift
//  Kudu
//
//  Created by Admin on 27/06/22.
//

import UIKit

class RTOtpView: UIView {
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet private var mainContentView: UIView!
    @IBOutlet weak var sixthTF: UITextField!
    @IBOutlet weak var fifthTF: UITextField!
    @IBOutlet weak var fourthTF: UITextField!
    @IBOutlet weak var thirdTF: UITextField!
    @IBOutlet weak var secondTF: UITextField!
    @IBOutlet weak var firstTF: UITextField!
    @IBOutlet weak var sixthContainer: UIView!
    @IBOutlet weak var fifthContainer: UIView!
    @IBOutlet weak var fourthContainer: UIView!
    @IBOutlet weak var thirdContainer: UIView!
    @IBOutlet weak var secondContainer: UIView!
    @IBOutlet weak var firstContainer: UIView!
    
    private var textFields: [UITextField] = []
    private var containers: [UIView] = []
    
    var otpEntered: ((String) -> Void)?
    
    var getCurrentOtp: String {
        var string = ""
        textFields.forEach({ string.append(contentsOf: $0.text ?? "") })
        return string
    }
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
        
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RTOtpView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if AppUserDefaults.selectedLanguage() == .ar {
            textFields = [sixthTF, fifthTF, fourthTF, thirdTF, secondTF, firstTF]
        } else {
            textFields = [firstTF, secondTF, thirdTF, fourthTF, fifthTF, sixthTF]
        }
        var i = 0
        textFields.forEach({
            i += 1
            $0.textContentType = .oneTimeCode
            $0.tag = i
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            $0.keyboardType = .phonePad
            $0.delegate = self })
        if AppUserDefaults.selectedLanguage() == .ar {
            containers = [sixthContainer, fifthContainer, fourthContainer, thirdContainer, secondContainer, firstContainer]
        } else {
            containers = [firstContainer, secondContainer, thirdContainer, fourthContainer, fifthContainer, sixthContainer]
        }
    }
    
    func toggleErrorState(show: Bool, shake: Bool = true) {
        if show {
            containers.forEach({ $0.borderColor = .red })
            if shake {
                textFields.forEach({ $0.text = "" })
                self.shakeView() }
        } else {
            containers.forEach({ $0.borderColor = .black.withAlphaComponent(0.4)})
        }
    }
    
}

extension RTOtpView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            let newPosition = textField.endOfDocument
            textField.becomeFirstResponder()
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField) {
        if sender.text?.count ?? 0 != 1 { return }
        if AppUserDefaults.selectedLanguage() == .ar {
            self.autoToggleForArabic(sender.tag)
        } else {
            self.autoToggleForEnglish(sender.tag)
        }
        
        self.otpEntered?(getCurrentOtp)
    }
    
    private func autoToggleForEnglish(_ tag: Int) {
        switch tag {
        case 1:
            secondTF.becomeFirstResponder()
        case 2:
            thirdTF.becomeFirstResponder()
        case 3:
            fourthTF.becomeFirstResponder()
        case 4:
            fifthTF.becomeFirstResponder()
        case 5:
            sixthTF.becomeFirstResponder()
        default:
            sixthTF.resignFirstResponder()
        }
    }
    
    private func autoToggleForArabic(_ tag: Int) {
        switch tag {
        case 1:
            fifthTF.becomeFirstResponder()
        case 2:
            fourthTF.becomeFirstResponder()
        case 3:
            thirdTF.becomeFirstResponder()
        case 4:
            secondTF.becomeFirstResponder()
        case 5:
            firstTF.becomeFirstResponder()
        default:
            firstTF.resignFirstResponder()
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        debugPrint("Test")
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let stringEntered = string
        if stringEntered == "" {
            self.otpEntered?(getCurrentOtp)
        }
        let allowedCharacterSet = CharacterSet(charactersIn: "1234567890")
        let charactersEntered = CharacterSet(charactersIn: stringEntered)
        
        if stringEntered.count == 6 && charactersEntered.isSubset(of: allowedCharacterSet) {
            debugPrint("OTP String Received")
            autoFillOtp(stringEntered, currentTF: textField)
            return false
        }
        
        if stringEntered.count > 1 {
            return false
        }
        
        if !charactersEntered.isSubset(of: allowedCharacterSet) {
            return false
        }
        textField.text = ""
        if string.isEmpty {
            handleTextFieldReplacementEmptyString(textField, string: string)
        }
        return true
    }
    
    
    
    private func handleTextFieldReplacementEmptyString(_ textField: UITextField, string: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            debugPrint("Current TF : \(textField.tag)")
            let newTFTag = textField.tag - 2
            let selectedLang = AppUserDefaults.selectedLanguage()
            if (textField.tag) == 2 {
                if selectedLang == .en { self?.firstTF.becomeFirstResponder() } else {
                    self?.sixthTF.becomeFirstResponder()
                }
            } else {
                if selectedLang == .en { self?.autoToggleForEnglish(newTFTag) } else {
                    self?.autoToggleForArabic(newTFTag)
                }
            }
        })
    }
    
    private func autoFillOtp(_ otpString: String, currentTF: UITextField) {
        if AppUserDefaults.selectedLanguage() == .ar {
            sixthTF.text = otpString[0]
            fifthTF.text = otpString[1]
            fourthTF.text = otpString[2]
            thirdTF.text = otpString[3]
            secondTF.text = otpString[4]
            firstTF.text = otpString[5]
        } else {
            firstTF.text = otpString[0]
            secondTF.text = otpString[1]
            thirdTF.text = otpString[2]
            fourthTF.text = otpString[3]
            fifthTF.text = otpString[4]
            sixthTF.text = otpString[5]
        }
        self.otpEntered?(getCurrentOtp)
        currentTF.resignFirstResponder()
    }
    
}
