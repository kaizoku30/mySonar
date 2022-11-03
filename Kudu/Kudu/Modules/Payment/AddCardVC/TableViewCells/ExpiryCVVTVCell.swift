//
//  ExpiryCVVTVCell.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit

class ExpiryCVVTVCell: UITableViewCell {
    
    @IBOutlet private weak var cvvInfoImgView: UIImageView!
    @IBOutlet private weak var cvvTF: UITextField!
    @IBOutlet private weak var expiryTF: UITextField!
    
    @IBAction private func expiryEdited(_ sender: Any) {
        updatedExpiry?(expiryTF.text ?? "")
    }
    
    @IBAction func cvvEdited(_ sender: Any) {
        updatedCVV?(cvvTF.text ?? "")
    }
    
    var updatedCVV: ((String) -> Void)?
    var updatedExpiry: ((String) -> Void)?
    var openCVVInfo: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        expiryTF.delegate = self
        cvvTF.delegate = self
        cvvTF.isSecureTextEntry = true
        cvvInfoImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCVVView)))
    }
    
    func configure(cvv: String, expiry: String) {
        if cvv.isEmpty {
            cvvTF.text = nil
        } else {
            cvvTF.text = cvv
        }
        
        if expiry.isEmpty {
            expiryTF.text = nil
        } else {
            expiryTF.text = expiry
        }
    }
    
    @objc private func openCVVView() {
        openCVVInfo?()
    }
}

extension ExpiryCVVTVCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        if string.isEmpty || string == "" {
            return true
        }
        let characterSet = CharacterSet(charactersIn: string)
        if !characterSet.isSubset(of: .decimalDigits) {
            return false
        }
        if textField == cvvTF {
            return text.count < 4
        }
        if text.count == 2 {
            expiryTF.text?.append("/")
        }
        if text.count == 0 {
            let replacementNumber = Int(string) ?? 0
            if replacementNumber > 1 {
                return false
            } else {
                return true
            }
        }
        if text.count == 1 {
            let firstDigit = Int(String(text.first ?? "0")) ?? 0
            let replacementNumber = Int(string) ?? 0
            if firstDigit == 0 {
                //Second month digit can range from 1-9
                if replacementNumber < 1 || replacementNumber > 9 {
                    return false
                } else {
                    return true
                }
            }
            if firstDigit == 1 {
                //Second month digit can range from 0-2
                if replacementNumber > 2 {
                    return false
                } else {
                    return true
                }
            }
        }
        let currentYear = Date().year
        debugPrint("Current Year : \(currentYear)")
        let lastTwoDigits = String(currentYear).getLastNSubString(number: 2)
        if text.count == 2 || text.count == 3 {
            let firstYearDigit = String(lastTwoDigits.first ?? "2")
            let firstYearNumber = Int(firstYearDigit) ?? 0
            let replacementNumber = Int(string) ?? 0
            if replacementNumber < firstYearNumber {
                return false
            } else {
                return true
            }
        }
        if text.count == 4 {
            let secondYearDigit = String(lastTwoDigits.last ?? "2")
            let secondYearNumber = Int(secondYearDigit) ?? 0
            let replacementNumber = Int(string) ?? 0
            if replacementNumber < secondYearNumber {
                return false
            } else {
                return true
            }
        }
        return text.count < 5
    }
}
