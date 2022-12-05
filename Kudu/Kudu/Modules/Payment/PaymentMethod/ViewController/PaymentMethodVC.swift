//
//  PaymentMethodVC.swift
//  Kudu
//
//  Created by Admin on 29/09/22.
//

import UIKit
import PassKit
import Frames

class PaymentMethodVC: BaseVC {
    var orderId: String!
    var req: OrderPlaceRequest!
    var flow: CartPageFlow!
    var allowedPaymentMethods: [PaymentType]!
    
    @IBOutlet private weak var baseView: PaymentMethodView!
    @IBOutlet private weak var payButton: AppButton!
    @IBAction private func pay(_ sender: Any) {
        //For COD
        self.payButton.startBtnLoader(color: .white)
        if config.isCOD {
            self.baseView.isUserInteractionEnabled = false
            APIEndPoints.PaymentEndPoints.makeCODPayment(orderID: orderId, amount: req.totalAmount, success: { _ in
                self.baseView.isUserInteractionEnabled = true
                mainThread {
                    self.payButton.stopBtnLoader(titleColor: .white)
                    self.goToOrderSuccess()
                }
            }, failure: {
                self.baseView.isUserInteractionEnabled = true
                mainThread {
                    self.baseView.tableView.reloadData()
                    self.payButton.stopBtnLoader(titleColor: .white)
                }
                self.baseView.showError(msg: $0.msg)
            })
        }
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        self.pop()
    }
    
    private let viewModel = PaymentMethodVM()
    private var isFetchingCards = true
    private let checkoutAPIClient: CheckoutAPIClient = CheckoutAPIClient(publicKey: "pk_sbox_sgshjgfctpf7cgalgxgzcb4itau", environment: .sandbox)
    
    struct PaymentConfiguration {
        var isCOD = false
        var isCard = false
        var cardIndex: Int = -1
        var cvvPrefill: String = ""
    }
    
    private var config = PaymentConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.baseView.tableView.reloadData()
        let amount = req.totalAmount
        self.payButton.setTitle("\(LSCollection.Payments.paySR) \(amount.round(to: 2).removeZerosFromEnd())", for: .normal)
        self.viewModel.getCards(fetched: { [weak self] (result) in
            mainThread {
                switch result {
                case .success:
                    if self?.viewModel.getCards.count ?? 0 == 0 {
                        self?.config.isCOD = true
                        self?.baseView.showCODPayment(true)
                    } else {
                        self?.config.isCard = true
                        self?.config.cardIndex = 0
                    }
                    self?.isFetchingCards = false
                    self?.baseView.tableView.reloadData()
                case .failure(let error):
                    self?.baseView.showError(msg: error.localizedDescription)
                }
            }
        })
    }
}

extension PaymentMethodVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFetchingCards {
            return 4
        }
        
        let header = 1
        let cardCount = viewModel.getCards.count
        let savedCardHeader = cardCount > 0 ? 1 : 0
        let applePay = 1
        let cod = 1
        return header + savedCardHeader + cardCount + applePay + cod
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isFetchingCards {
            return UITableView.automaticDimension
        }
        
        if !allowedPaymentMethods.contains(.Card) {
            if indexPath.row == 0 {
                return 0
            }
            
            if indexPath.row == 1 && viewModel.getCards.isEmpty == false {
                return 0
            }
            
            if !(indexPath.row == tableView.numberOfRows(inSection: 0) - 2) && !(indexPath.row == tableView.numberOfRows(inSection: 0) - 1) {
                return 0
            }
        }
        
        if !allowedPaymentMethods.contains(.ApplePay) {
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 2 {
                return 0
            }
        }
        
        if !allowedPaymentMethods.contains(.COD) {
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                return 0
            }
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFetchingCards {
            let cell = tableView.dequeueCell(with: PaymentMethodShimmerCell.self)
            cell.selectionStyle = .none
            return cell
        }
        if indexPath.row == 0 {
            return getCardHeaderCell(tableView, cellForRowAt: indexPath)
        }
        
        if indexPath.row == 1 && viewModel.getCards.isEmpty == false {
            return getSavedCardsHeader(tableView, cellForRowAt: indexPath)
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 2 {
            //Last always cod
            return getApplePayCell(tableView, cellForRowAt: indexPath)
            
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            //Last always cod
            return getCODCell(tableView, cellForRowAt: indexPath)
            
        }
        
        //Saved Card cell
        return getSavedCard(tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFetchingCards { return }
        if viewModel.getCards.isEmpty {
            //No need as COD selected
            return
        }
        let lastIndex = tableView.numberOfRows(inSection: 0) - 1
        
        if indexPath.row == lastIndex - 1 {
            //Apple Pay
            debugPrint("Launch Apple Pay Flow")
            return
        }
        
        if lastIndex == indexPath.row {
            config.isCard = false
            config.isCOD = true
            config.cvvPrefill = ""
            config.cardIndex = -1
            self.baseView.showCODPayment(true)
        } else {
            config.isCard = true
            config.isCOD = false
            config.cvvPrefill = ""
            config.cardIndex = indexPath.row - 2
            self.baseView.showCODPayment(false)
        }
        self.baseView.tableView.reloadData()
    }
}

extension PaymentMethodVC {
    func getCardHeaderCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: CardHeaderCell.self)
        cell.selectionStyle = .none
        cell.triggerAddCardFlow = { [weak self] in
            let vc = AddCardVC.instantiate(fromAppStoryboard: .Payment)
            vc.flow = self?.flow ?? .fromExplore
            vc.viewModel.setPrice(self?.req.totalAmount ?? 0.0)
            vc.viewModel.setOrderID(self?.orderId ?? "")
            mainThread {
                self?.push(vc: vc)
            }
        }
        return cell
    }
    
    func getSavedCard(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: SavedCardCell.self)
        cell.selectionStyle = .none
        if indexPath.row - 2 < viewModel.getCards.count {
            let card = viewModel.getCards[indexPath.row - 2]
            cell.initiatePayment = { [weak self] (cvv, cardIndex) in
                self?.initiateCardPayment(cvv: cvv, cardIndex: cardIndex)
            }
            cell.configure(showPayment: config.isCard == true && config.cardIndex == indexPath.row - 2, cvvPrefill: config.cvvPrefill, price: req.totalAmount, last4: card.last4 ?? "", cardIndex: indexPath.row - 2, cardImage: card.getCardImage(), cardHolderName: card.cardHolderName ?? "")
        }
        return cell
    }
    
    func getSavedCardsHeader(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: SavedCardHeaderCell.self)
        cell.selectionStyle = .none
        return cell
    }
    
    func getCODCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: CODCell.self)
        cell.selectionStyle = .none
        cell.configure(config.isCOD, serviceType: req.servicesType)
        return cell
    }
    
    func getApplePayCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: ApplePayPaymentCell.self)
        cell.selectionStyle = .none
        cell.applePayTriggered = { [weak self] in
            mainThread {
                self?.openApplePay()
            }
        }
        return cell
    }
}

extension PaymentMethodVC {
    private func initiateCardPayment(cvv: String, cardIndex: Int) {
        self.baseView.isUserInteractionEnabled = false
        self.viewModel.makeSavedCardPayment(orderId: orderId, amount: self.req.totalAmount, cvv: cvv, cardId: viewModel.getCards[cardIndex].id ?? "", result: { [weak self] in
            guard let `self` = self else { return }
            self.baseView.isUserInteractionEnabled = true
            switch $0 {
            case .success:
                self.goToOrderSuccess()
            case .failure(let error):
                mainThread({
                    self.baseView.tableView.reloadData()
                    self.baseView.showError(msg: error.localizedDescription)
                })
            }
        })
    }
    
    private func goToOrderSuccess() {
        CartUtility.syncCart(completion: {
            debugPrint("PAYMENT DONE ON SERVER, ORDER PLACED")
            mainThread {
                self.baseView.tableView.reloadData()
                let vc = OrderSuccessVC.instantiate(fromAppStoryboard: .CartPayment)
                vc.flow = self.flow
                self.push(vc: vc)
            }
        })
    }
}

extension PaymentMethodVC: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        debugPrint("Apple Pay Token : \(payment.token)")
        completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.success, errors: []))
        self.tabBarController?.addLoaderOverlay()
        checkoutAPIClient.createApplePayToken(paymentData: payment.token.paymentData, completion: { [weak self] (result) in
            switch result {
            case .success(let tokenDetails):
                debugPrint("Token Details")
                debugPrint(tokenDetails)
                guard let `self` = self else { return }
                let addCardPaymentRequestMock = AddCardPaymentRequest(orderId: self.orderId, token: tokenDetails.token, isSave: false, isDefault: false, amount: self.req.totalAmount, type: .token, cardHolderName: DataManager.shared.loginResponse?.fullName ?? "")
                APIEndPoints.PaymentEndPoints.makeTokenPayment(request: addCardPaymentRequestMock, isApplePay: true, success: { [weak self] _ in
                    self?.tabBarController?.removeLoaderOverlay()
                    self?.goToOrderSuccess()
                }, failure: { [weak self] (error) in
                    self?.tabBarController?.removeLoaderOverlay()
                    self?.baseView.showError(msg: error.msg)
                })
            case .failure(let error):
                mainThread {
                    self?.tabBarController?.removeLoaderOverlay()
                    self?.baseView.showError(msg: error.localizedDescription)
                }
            }
        })
    }
    
    private func openApplePay() {
        //Apple Pay Testing
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.kudu.checkout22.sandbox"
        request.supportedNetworks = [.visa, .amex, .masterCard]
        request.merchantCapabilities = [.capability3DS]
        request.countryCode = "SA"
        request.currencyCode = "SAR"
        
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "KUDU Order", amount: NSDecimalNumber(value: req.totalAmount))
        ]
        
        let applePayVC = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayVC?.delegate = self
        self.present(applePayVC!, animated: true)
    }
}
