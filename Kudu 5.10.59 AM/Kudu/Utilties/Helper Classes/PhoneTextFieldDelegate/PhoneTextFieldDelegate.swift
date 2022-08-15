//
//  PhoneTextFieldDelegate.swift
//  Kudu
//
//  Created by Admin on 16/08/22.
//

import UIKit

extension UITextFieldDelegate {
    func validatePhoneNumber(_ newString: String, _ string: String) -> Bool {
        let allowed = CharacterSet(charactersIn: "1234567890")
        let enteredCharacterSet = CharacterSet(charactersIn: newString)
        if !enteredCharacterSet.isSubset(of: allowed) || newString.count > 9 {
            return false
        }
        return true
    }
}
