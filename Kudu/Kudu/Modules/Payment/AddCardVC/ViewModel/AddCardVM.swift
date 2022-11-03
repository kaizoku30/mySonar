//
//  AddCardVM.swift
//  Kudu
//
//  Created by Admin on 18/10/22.
//

import Foundation
import UIKit
import Frames

final class AddCardVM {
    
    private let checkoutAPIClient: CheckoutAPIClient = CheckoutAPIClient(publicKey: "pk_sbox_sgshjgfctpf7cgalgxgzcb4itau", environment: .sandbox)
    
    struct CardForm {
        var name: String = ""
        var expiry: String = ""
        var cvv: String = ""
        var cardNumber: String = ""
        var isDefault: Bool = false
        var saveCard: Bool = false
    }
    
    private var form = CardForm() {
        didSet {
            debugPrint("Form : \(form)")
        }
    }
    var getForm: CardForm { form }
    var hideEmail: Bool {
        let email = DataManager.shared.loginResponse?.email ?? ""
        let emailVerified = DataManager.shared.loginResponse?.isEmailVerified ?? false
        if form.saveCard == false {
            return true
        }
        return !email.isEmpty && emailVerified == true && emailUpdated == false
    }
    private var email: String = ""
    private var emailVerified: Bool { DataManager.shared.loginResponse?.isEmailVerified ?? false }
    private var emailUpdated = false
    private var priceToPay: Double = 0
    private var orderId: String!
    var getEmail: String { email }
    var isEmailVerified: Bool { emailVerified }
    var getPrice: Double { priceToPay }
    var getOrderID: String { orderId }
    private let cardUtils = CardUtils()
    
    init() {
        email = DataManager.shared.loginResponse?.email ?? ""
    }
    
    func setPrice(_ price: Double) {
        self.priceToPay = price
    }
    
    func setOrderID(_ id: String) {
        self.orderId = id
    }
    
    func updateValue(type: AddCardView.Rows, value: Any) {
        switch type {
        case .cardNumber:
            form.cardNumber = value as? String ?? ""
        case .expiryCvv:
            break
        case .name:
            form.name = value as? String ?? ""
        case .email:
            break
        case .saveCard:
            break
        case .payButton:
            break
        }
    }
    
    func updateExpiry(_ expiry: String) {
        form.expiry = expiry
    }
    
    func updateCVV(_ cvv: String) {
        form.cvv = cvv
    }
    
    func updateEmail(email: String) {
        self.emailUpdated = true
        self.email = email
    }
    
    func setEmailUpdated() {
        self.emailUpdated = true
    }
    
    func saveCard(_ save: Bool) {
        form.saveCard = save
        if !save {
            form.isDefault = false
        }
    }
    
    func setDefaultCard( _ defaultCard: Bool) {
        form.isDefault = defaultCard
        if defaultCard {
            form.saveCard = true
        }
    }
}

extension AddCardVM {
    
    func validateForm() -> ValidationError? {
    
        if form.cardNumber.isEmpty {
            return .pleaseEnterCardNumber
        }
        let creditCardNumber = form.cardNumber
        let type = cardUtils.getTypeOf(cardNumber: creditCardNumber)
        
        if type.isNil {
            return .pleaseEnterValidCardNumber
        } else {
            let validNumbers = type!.validLengths
            let currentLength = creditCardNumber.count
            if !validNumbers.contains(where: { $0 == currentLength }) {
                return .pleaseEnterValidCardNumber
            }
        }
        
        if form.expiry.isEmpty {
            return .pleaseEnterExpiry
        }
        
        if form.expiry.count < 5 {
            return .pleaseEnterValidExpiry
        }
        
        let expiryText = form.expiry
        let month = expiryText.dropLast(3)
        let currentMonth = Date().month
        
        if Int(month) ?? 0 <= currentMonth {
            return .pleaseEnterValidExpiry
        }
        
        if form.cvv.isEmpty {
            return .pleaseEnterCVV
        }
        
        if form.cvv.count < 3 {
            return .pleaseEnterValidCVV
        }
        
        if form.name.isEmpty {
            return .pleaseEnterName
        }
        
        if CommonValidation.isValidName(form.name) == false {
            return .pleaseEnterValidName
        }
        
        if form.saveCard {
            if email.isEmpty {
                return .pleaseEnterEmail
            }
            
            if CommonValidation.isValidEmail(email) == false {
                return .pleaseEnterValidEmail
            }
            
            if emailVerified == false {
                return .pleaseVerifyEmail
            }
        }
        
        return nil
    }
    
    enum ValidationError: String {
        case pleaseEnterName
        case pleaseEnterValidName
        case pleaseEnterExpiry
        case pleaseEnterValidExpiry
        case pleaseEnterCVV
        case pleaseEnterValidCVV
        case pleaseEnterEmail
        case pleaseEnterValidEmail
        case pleaseVerifyEmail
        case pleaseEnterCardNumber
        case pleaseEnterValidCardNumber
        
        var errorMsg: String {
            switch self {
            case .pleaseEnterName:
                return "Please enter Name"
            case .pleaseEnterValidName:
                return "Please enter valid Name"
            case .pleaseEnterExpiry:
                return "Please enter Expiry Date"
            case .pleaseEnterValidExpiry:
                return "Please enter valid Expiry Date"
            case .pleaseEnterCVV:
                return "Please enter CVV"
            case .pleaseEnterValidCVV:
                return "Please enter valid CVV"
            case .pleaseEnterCardNumber:
                return "Please enter Card Number"
            case .pleaseEnterValidCardNumber:
                return "Please enter valid Card Number"
            case .pleaseEnterEmail:
                return "Please enter Email"
            case .pleaseEnterValidEmail:
                return "Please enter valid Email"
            case .pleaseVerifyEmail:
                return "Please verify Email to save card"
            }
        }
    }
}

extension AddCardVM {
    func sendEmailOTP(response: @escaping (Result<Bool, Error>) -> Void) {
        let triggerVerificationFlow = getEmail != DataManager.shared.loginResponse?.email ?? "" || (DataManager.shared.loginResponse?.isEmailVerified ?? false) == false
        APIEndPoints.HomeEndPoints.updateProfile(name: DataManager.shared.loginResponse?.fullName ?? "", email: triggerVerificationFlow ? getEmail : nil, success: { [weak self] _ in
            DataManager.shared.loginResponse?.email = self?.getEmail ?? ""
            if triggerVerificationFlow {
                DataManager.shared.loginResponse?.isEmailVerified = false
            }
            NotificationCenter.postNotificationForObservers(.updateProfilePage)
            response(.success(true))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            response(.failure(error))
        })
    }
}

extension AddCardVM {
    //Checkout Implementation
    private func getCardTokenRequest() -> CkoCardTokenRequest {
        let cardUtils = CardUtils()
        let cardNumber = cardUtils.standardize(cardNumber: self.form.cardNumber)
        let expirationDate = self.form.expiry
        let cvv = self.form.cvv
        let (expiryMonth, expiryYear) = cardUtils.standardize(expirationDate: expirationDate)
        return CkoCardTokenRequest(number: cardNumber, expiryMonth: expiryMonth, expiryYear: expiryYear, cvv: cvv)
    }
    
    func createToken(response: @escaping (Result<String, Error>) -> Void) {
        let card = getCardTokenRequest()
        print(card)
        checkoutAPIClient.createCardToken(card: card) { result in

            switch result {
            case .success(let cardTokenResponse):
                response(.success(cardTokenResponse.token))
            case .failure:
                response(.failure(NSError(localizedDescription: "Could not add credit card. Please verify details.")))
            }
        }
    }
    
    func getPaymentRequestObject(token: String) -> AddCardPaymentRequest {
        AddCardPaymentRequest(orderId: self.orderId, token: token, isSave: form.saveCard, isDefault: form.isDefault, amount: self.priceToPay, type: .token, cardHolderName: form.name)
    }
    
    func requestPaymentFromServer(req: AddCardPaymentRequest, isApplePay: Bool, response: @escaping ((Result<Bool, Error>) -> Void)) {
        APIEndPoints.PaymentEndPoints.makeTokenPayment(request: req, isApplePay: isApplePay, success: { _ in
            response(.success(true))
        }, failure: { (error) in
            response(.failure(NSError(localizedDescription: error.msg)))
        })
    }
}
