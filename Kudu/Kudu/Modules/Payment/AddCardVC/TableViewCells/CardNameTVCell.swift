//
//  CardNameTVCell.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit

class CardNameTVCell: UITableViewCell {
    @IBOutlet private weak var nameTF: UITextField!
    
    @IBAction func nameTFEdited(_ sender: Any) {
        updatedName?(nameTF.text ?? "")
    }
    
    var updatedName: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        nameTF.delegate = self
    }
    
    func configure(_ name: String) {
        if name.isEmpty {
            nameTF.text = nil
        } else {
            nameTF.text = name
        }
    }
}

extension CardNameTVCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text ?? "" == "" {
            if string.isEmpty || string == " " {
                return false
            }
        }
        
        if string.isEmpty || string == "" || string == " " {
            return true
        }
        
        let allowedSet = CharacterSet.letters
        let enteredSet = CharacterSet.init(charactersIn: string)
        if !enteredSet.isSubset(of: allowedSet) { return false }
        return textField.text?.count ?? 0 < 40
    }
}
