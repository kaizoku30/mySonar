//
//  EmailTVCell.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit

class EmailTVCell: UITableViewCell {
    
    @IBAction func verifyButtonPressed(_ sender: Any) {
        if self.verified == false {
            verifyButton.startBtnLoader(color: AppColors.kuduThemeBlue)
            verificationFlow?()
        }
    }
    
    @IBOutlet private weak var verifyButton: AppButton!
    @IBOutlet private weak var emailTF: UITextField!
    @IBOutlet private weak var emailToolTip: UIView!
    @IBOutlet private weak var emailContainer: UIView!
    @IBOutlet private weak var verifiedEmailCheckMark: UIImageView!
    
    @IBAction func emailTFEdited(_ sender: Any) {
        if self.verified == false {
            self.verifyButton.isHidden = !(!verified && emailTF.text ?? "" != "")
            self.updateEmail?(self.emailTF.text ?? "")
        }
    }
    
    private var verified = false
    
    var verificationFlow: (() -> Void)?
    var updateEmail: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        [emailToolTip, emailContainer].forEach({ $0?.isHidden = true })
    }
    
    func configure(email: String, verified: Bool, hideEmail: Bool) {
        self.verifyButton.stopBtnLoader(titleColor: AppColors.kuduThemeBlue)
        self.verified = verified
        if hideEmail {
            [emailToolTip, emailContainer].forEach({ $0?.isHidden = true })
        } else {
            emailTF.text = email
            emailTF.isUserInteractionEnabled = !verified
            verifyButton.isHidden = false
            verifyButton.setTitle(verified ? "Verified" : "Verify Now", for: .normal)
            verifyButton.isHidden = verified
            verifiedEmailCheckMark.isHidden = !verified
            verifyButton.isUserInteractionEnabled = !verified
            [emailToolTip, emailContainer].forEach({ $0?.isHidden = false })
        }
    }
}
	
