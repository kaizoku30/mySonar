//
//  FeedbackTextViewCell.swift
//  Kudu
//
//  Created by Admin on 22/07/22.
//

import UIKit

class FeedbackTextViewCell: UITableViewCell {
    @IBOutlet weak var feedbackTxtView: UITextView!
    var textEntered: ((String) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        feedbackTxtView.textContainer.lineFragmentPadding = 15
        feedbackTxtView.backgroundColor = AppColors.SendFeedbackScreen.textfieldBg
        feedbackTxtView.delegate = self
        feedbackTxtView.text = LSCollection.Setting.writeYourFeedbackHere
        feedbackTxtView.tintColor = .black
        feedbackTxtView.textColor = AppColors.SendFeedbackScreen.placeholderTextColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ text: String) {
        if text.isEmpty {
            feedbackTxtView.textColor = AppColors.SendFeedbackScreen.placeholderTextColor
            feedbackTxtView.text = LSCollection.Setting.writeYourFeedbackHere
        } else {
            feedbackTxtView.textColor = .black
            feedbackTxtView.text = text
        }
        
    }

}

extension FeedbackTextViewCell: UITextViewDelegate {
    // MARK: TextView Handling
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text.byRemovingLeadingTrailingWhiteSpaces
        textView.text = text
        if text == "" {
            textView.text = LSCollection.Setting.writeYourFeedbackHere
            textView.textColor = AppColors.SendFeedbackScreen.placeholderTextColor
        }
        self.textEntered?(text)
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == LSCollection.Setting.writeYourFeedbackHere {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let oldString: NSString = (textView.text ?? "") as NSString
        if oldString as String == LSCollection.Setting.writeYourFeedbackHere || oldString == "" && text == " " {
            return false
        }
        let newString = oldString.appending(text)
        let alphaNumericCharacter = CharacterSet.alphanumerics
        let specialCharsAllows = CharacterSet.symbols.union(CharacterSet.punctuationCharacters).union(CharacterSet.controlCharacters).union(CharacterSet.decomposables)
        let allAllowedUsernameChars = alphaNumericCharacter.union(specialCharsAllows).union(CharacterSet.whitespacesAndNewlines)
        let enteredCharacterSet = CharacterSet(charactersIn: newString)
        if !enteredCharacterSet.isSubset(of: allAllowedUsernameChars) {
            return false
        }
        if newString.count > 150
        {
            return false
        }
        return true
    }
}
