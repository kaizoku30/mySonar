//
//  PaymentMethodVC.swift
//  Kudu
//
//  Created by Admin on 29/09/22.
//

import UIKit

class PaymentMethodVC: BaseVC {
    
    var req: OrderPlaceRequest!
    var flow: CartPageFlow!
    
    @IBOutlet private weak var payButton: AppButton!
    @IBAction private func pay(_ sender: Any) {
        payButton.startBtnLoader(color: .white)
        APIEndPoints.OrderEndPoints.placeOrder(req: req, success: { [weak self] _ in
            guard let strongSelf = self else { return }
            CartUtility.syncCart {
                // Cart Screen can be shown from --- Explore, Fav, Home
                //Explore Case
                //Home Case [ Favourites within this ]
                // Safe Guard
                let cart = CartUtility.fetchCart()
                if !cart.isEmpty {
                    CartUtility.clearCart(clearedConfirmed: {
                        strongSelf.goToSuccess()
                    })
                } else {
                    strongSelf.goToSuccess()
                }
            }
        }, failure: { [weak self] (error) in
            guard let strongSelf = self else { return }
            mainThread {
                self?.payButton.stopBtnLoader(titleColor: .white)
                let appError = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: strongSelf.view.width - 32, height: 48))
                appError.show(message: error.msg, view: strongSelf.view)
            }
        })
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        self.pop()
    }
    
    private func goToSuccess() {
        mainThread {
            let vc = OrderSuccessVC.instantiate(fromAppStoryboard: .CartPayment)
            vc.flow = self.flow
            self.push(vc: vc)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let amount = req.totalAmount
        let amountToShow = amount.round(to: 2).removeZerosFromEnd()
        payButton.setTitle("Pay SR \(amountToShow)", for: .normal)
    }
}
