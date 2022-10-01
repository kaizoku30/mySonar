//
//  CommonValidation.swift
//  Kudu
//
//  Created by Admin on 05/05/22.
//

import Foundation

typealias ValidationResult = (result: Bool, error: String)
final class CommonValidation {
    static func isValidName(_ name: String) -> Bool {
        let alphabetSet = CharacterSet.letters
        let allowedSet = alphabetSet.union(CharacterSet(charactersIn: CommonStrings.whiteSpace))
        let enteredSet = CharacterSet(charactersIn: name)
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        let isArabic = predicate.evaluate(with: name)
        
        if !enteredSet.isSubset(of: allowedSet) && isArabic == false {
            return false
        }
        
        if name.count < 5 || name.count > 40 {
            return false
        }
        
        return true
    }
    
    static func isValidPhoneNumber(_ number: String) -> Bool {
        let characterSetAllowed = CharacterSet(charactersIn: "0123456789")
        let enteredSet = CharacterSet(charactersIn: number)
        
        if !enteredSet.isSubset(of: characterSetAllowed) {
            return false
        }
        
        if number.count != 9 {
            return false
        }
        
        return true
    }
    
    static func returnValidatedName(_ name: String) -> String {
        let charactersToRemove: CharacterSet = CharacterSet(charactersIn: "0123456789._[!&^%$#@()/]+")
        return String(name.map {
            let character = CharacterSet(charactersIn: "\($0)")
            if character.isSubset(of: charactersToRemove) {
                return " "
            } else { return $0 }
        })
        
    }
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,63}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        let enteredCharacterSet = CharacterSet(charactersIn: password)
        
        if password.count < 8 || password.count > 16 {
            return false
        }
        
        let capsCharSet = CharacterSet.uppercaseLetters
        
        let lowerCaseCharSet = CharacterSet.lowercaseLetters
        
        let numbers = CharacterSet(charactersIn: "1234567890")
        
        let specialChars = CharacterSet(charactersIn: ".*[!&^%$#@()/]+")
        
        if enteredCharacterSet.intersection(capsCharSet).isEmpty {
            return false
        }
        
        if enteredCharacterSet.intersection(lowerCaseCharSet).isEmpty {
            return false
        }
        
        if enteredCharacterSet.intersection(numbers).isEmpty {
            return false
        }
        
        if enteredCharacterSet.intersection(specialChars).isEmpty {
            return false
        }
        
        return true
    }
}
