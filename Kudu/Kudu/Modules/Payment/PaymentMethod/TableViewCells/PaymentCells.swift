//
//  PaymentCells.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit
import PassKit

class CardHeaderCell: UITableViewCell {
    
    @IBOutlet private weak var addCardLabel: UILabel!
    @IBOutlet private weak var addCardImg: UIImageView!
    @IBOutlet private weak var creditCardDebitCardLabel: UILabel!
    
    var triggerAddCardFlow: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        addCardLabel.text = LSCollection.Payments.addNewCard
        creditCardDebitCardLabel.text = LSCollection.Payments.creditCardDebitCard
        addCardLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addCardFlow)))
        addCardImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addCardFlow)))
    }
    
    @objc private func addCardFlow() {
        triggerAddCardFlow?()
    }
}

class SavedCardHeaderCell: UITableViewCell {
    @IBOutlet private weak var savedCardsHeaderLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        savedCardsHeaderLabel.text = LSCollection.Payments.savedCards
        selectionStyle = .none
    }
}

class PaymentMethodShimmerCell: UITableViewCell {
    
    @IBOutlet private weak var shimmerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerView.startShimmering()
    }
}

class CODCell: UITableViewCell {
    
    @IBOutlet private weak var codLabel: UILabel!
    @IBOutlet private weak var selectionImg: UIImageView!
    
    func configure(_ selected: Bool, serviceType: APIEndPoints.ServicesType) {
        selectionImg.image = selected ? AppImages.LanguagePrefScreen.selected : AppImages.LanguagePrefScreen.unSelected
        switch serviceType {
        case .curbside:
            codLabel.text = "Cash on Curbside"
        case .delivery:
            codLabel.text = "Cash on Delivery"
        case .pickup:
            codLabel.text = "Cash on Pickup"
        }
    }
}

class ApplePayPaymentCell: UITableViewCell {
    @IBOutlet weak var applePayButton: PKPaymentButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        applePayButton.addTarget(self, action: #selector(applePayPressed), for: .touchUpInside)
    }
    
    var applePayTriggered: (() -> Void)?
    
    @objc private func applePayPressed() {
        applePayTriggered?()
    }
}

class SavedCardCell: UITableViewCell {
    @IBOutlet private weak var paymenButton: AppButton!
    @IBOutlet private weak var bottomBorder: UIView!
    @IBOutlet private weak var cardPaymentView: UIView!
    @IBOutlet private weak var cardDetailView: UIView!
    @IBOutlet private weak var selectionImg: UIImageView!
    @IBOutlet private weak var cardImageView: UIImageView!
    private let placeholderImg = UIImage(named: "k_ccPlaceholder")
    @IBOutlet private weak var cvvTextfield: UITextField!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardHolderNameLabel: UILabel!
    
    @IBAction private func cvvTextFieldEdit(_ sender: Any) {
        self.enableDisableButton(enable: self.cvvTextfield.text?.count ?? 0 == 3 || self.cvvTextfield.text?.count ?? 0 == 4)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        cvvTextfield.text = ""
        cvvTextfield.delegate = self
        cardPaymentView.isHidden = true
        cvvTextfield.tintColor = .black
        paymenButton.addTarget(self, action: #selector(paymentPressed), for: .touchUpInside)
    }
    
    @objc private func paymentPressed() {
        if cvvTextfield.text?.count ?? 0 == 3 || cvvTextfield.text?.count ?? 0 == 4 {
            paymenButton.startBtnLoader(color: .white)
            initiatePayment?(cvvTextfield.text ?? "", self.cardIndex)
        }
    }
    
    private var cardIndex: Int!
    
    var initiatePayment: ((String, Int) -> Void)?
    
    func configure(showPayment: Bool, cvvPrefill: String, price: Double, last4: String, cardIndex: Int, cardImage: UIImage, cardHolderName: String) {
        self.paymenButton.stopBtnLoader(titleColor: .white)
        self.cardIndex = cardIndex
        cvvTextfield.isSecureTextEntry = true
        if showPayment {
            selectionImg.image = AppImages.LanguagePrefScreen.selected
            paymenButton.setTitle("\(LSCollection.Payments.paySR) \(price.round(to: 2).removeZerosFromEnd())", for: .normal)
            cvvTextfield.text = cvvPrefill.isEmpty ? nil : cvvPrefill
            enableDisableButton(enable: cvvTextfield.text?.count ?? 0 == 3 || cvvTextfield.text?.count ?? 0 == 4 )
            cardPaymentView.isHidden = false
        } else {
            selectionImg.image = AppImages.LanguagePrefScreen.unSelected
            cvvTextfield.text = nil
            cardPaymentView.isHidden = true
        }
        cardHolderNameLabel.text = cardHolderName
        cardNumberLabel.text = "XXXXXXXXXXXX\(last4)"
        cardImageView.image = cardImage
    }
    
    private func enableDisableButton(enable: Bool) {
        paymenButton.backgroundColor = enable ? AppColors.kuduThemeYellow : AppColors.unselectedButtonBg
        paymenButton.setTitleColor(enable ? AppColors.white : AppColors.unselectedButtonTextColor, for: .normal)
    }
}

extension SavedCardCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        if string.isEmpty || string == "" {
            return true
        }
        let characterSet = CharacterSet(charactersIn: string)
        if !characterSet.isSubset(of: .decimalDigits) {
            return false
        }
        return text.count < 4
    }
}
