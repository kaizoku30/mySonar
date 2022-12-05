//
//  File.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit
import Frames

class CardNumberTVCell: UITableViewCell {
    
    @IBOutlet private weak var cardImgView: UIImageView!
    @IBOutlet private weak var textField: UITextField!
    @IBAction private func updatedCardTextfield(_ sender: Any) {
        checkCardType()
    }
    
    private func checkCardType() {
        let updatedText = textField.text ?? ""
        let type = cardUtils.getTypeOf(cardNumber: updatedText.removeSpaces)
        if type.isNil {
            textField.text = updatedText
            cardImgView.image = UIImage(color: .clear, size: CGSize(width: 75, height: 75))!
            cardImgView.isHidden = updatedText.isEmpty || updatedText == ""
            updatedCardNumber?(updatedText.removeSpaces)
        } else {
            let formatted = cardUtils.format(cardNumber: updatedText.removeSpaces, cardType: type!)
            textField.text = formatted
            cardImgView.image = cardUtils.getImageForScheme(scheme: type!.scheme)
            cardImgView.isHidden = updatedText.isEmpty || updatedText == ""
            updatedCardNumber?(updatedText.removeSpaces)
        }
//        let result = CreditDebitCardUtility.checkCardNumber(input: updatedText)
//        textField.text = result.formatted
//        cardImgView.image = result.type.associatedImage
//        debugPrint("Card Result : \(result)")
//        cardImgView.isHidden = updatedText.isEmpty || updatedText == ""
//        updatedCardNumber?(updatedText.removeSpaces)
    }
    
    @IBAction func textFieldEndedEditing(_ sender: Any) {
        cardImgView.isHidden = textField.text?.isEmpty ?? true || textField.text ?? "" == ""
    }
    
    var updatedCardNumber: ((String) -> Void)?
    private let cardUtils = CardUtils()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.placeholder = LSCollection.Payments.enterCardNumber
        self.selectionStyle = .none
        textField.delegate = self
    }
    
    func configure(_ number: String) {
        if number.isEmpty {
            textField.text = nil
            cardImgView.isHidden = true
        } else {
            textField.text = number
            checkCardType()
        }
    }
}

extension CardNumberTVCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var place = textField.text ?? ""
        place = place.removeSpaces
        if string.isEmpty || string == "" {
            return true
        }
        let allowedSet = CharacterSet.decimalDigits
        let stringSet = CharacterSet(charactersIn: string)
        if !stringSet.isSubset(of: allowedSet) {
            return false
        }
        let type = cardUtils.getTypeOf(cardNumber: textField.text?.removeSpaces ?? "")
        if type.isNil {
            return place.count < 19
        } else {
            let validLengths = type!.validLengths
            let max = validLengths.max() ?? 0
            let debugString = "Valid lengths : \(validLengths)"
            debugPrint(debugString)
            let maxString = "Max value"
            debugPrint(maxString)
            debugPrint(max)
            if max == 0 {
                return place.count < 19
            } else {
                return place.count < max
            }
        }
        
    }
}
