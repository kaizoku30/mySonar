//
//  ViewController.swift
//  Kudu
//
//  Created by Admin on 26/04/22.
//

import UIKit
import Frames

class TestPaymentVC: UIViewController {

    var checkoutAPIClient: CheckoutAPIClient = CheckoutAPIClient(publicKey: "pk_test_f3ca1a66-0179-4f20-a025-bab60806da45", environment: .sandbox)
    
    @IBOutlet weak var cardNumberView: CardNumberInputView!
    @IBOutlet weak var expirationDateView: ExpirationDateInputView!
    @IBOutlet weak var cvvView: CvvInputView!
    @IBAction func onTapPay(_ sender: Any) {
        let card = getCardTokenRequest()
        print(card)
        checkoutAPIClient.createCardToken(card: card) { result in

            switch result {
            case .success(let cardTokenResponse):
                self.showAlert(with: cardTokenResponse.token)

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        WebServices.TestEndPoints.getQuestions(success: {
//            (response) in
//            
//            debugPrint("Success found \(response.data!)")
//        }, failure: { _ in
//            debugPrint("error found")
//        })
        
        let views: [StandardInputView] = [cardNumberView, expirationDateView, cvvView]
        views.forEach { view in
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 2
            view.layer.cornerRadius = 10
            view.backgroundColor = UIColor(red: 34/255, green: 41/255, blue: 47/255, alpha: 1)
            view.textField.textColor = .white
            view.label.textColor = .white
        }
        // Do any additional setup after loading the view.
    }

    private func getCardTokenRequest() -> CkoCardTokenRequest {
        let cardUtils = CardUtils()
        let cardNumber = cardUtils.standardize(cardNumber: cardNumberView.textField.text!)
        let expirationDate = expirationDateView.textField.text
        let cvv = cvvView.textField.text
        let (expiryMonth, expiryYear) = cardUtils.standardize(expirationDate: expirationDate!)
        return CkoCardTokenRequest(number: cardNumber, expiryMonth: expiryMonth, expiryYear: expiryYear, cvv: cvv!)
    }
    
    private func showAlert(with cardToken: String) {
        let alert = UIAlertController(title: "Payment",
                                      message: cardToken, preferredStyle: .alert)
        let action = UIAlertAction(title: "Send Payment Request", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
            
            print("Card Token")
            print(cardToken)
            WebServices.PaymentTestEndPoints.payADollar(cardToken: cardToken, success: { _ in
                let alert = UIAlertController(title: "Payment Success",
                                              message: "", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
            }, failure: { _ in
                let alert = UIAlertController(title: "Payment Failed",
                                              message: "", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
            })
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}
