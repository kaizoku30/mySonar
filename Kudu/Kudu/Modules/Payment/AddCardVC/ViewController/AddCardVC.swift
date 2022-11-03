//
//  AddCardVC.swift
//  Kudu
//
//  Created by Admin on 18/10/22.
//

import UIKit

class AddCardVC: BaseVC {
    @IBOutlet private weak var baseView: AddCardView!
    let viewModel = AddCardVM()
    var flow: CartPageFlow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleViewActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        debugPrint("ADD CARD SCREEN APPEARED")
        self.baseView.refreshRow(row: .email)
    }
    
    private func handleViewActions() {
        baseView.handleViewActions = { [weak self] (action) in
            guard let strongSelf = self else { return }
            switch action {
            case .backButtonPressed:
                strongSelf.pop()
            }
        }
    }
}

extension AddCardVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AddCardView.Rows.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = AddCardView.Rows(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        switch type {
        case .cardNumber:
            return getCardNumberCell(tableView, cellForRowAt: indexPath)
        case .expiryCvv:
            return getExpiryCVVCell(tableView, cellForRowAt: indexPath)
        case .name:
            return getCardNameCell(tableView, cellForRowAt: indexPath)
        case .email:
            return getEmailTVCell(tableView, cellForRowAt: indexPath)
        case .saveCard:
            return getSaveCardTVCell(tableView, cellForRowAt: indexPath)
        case .payButton:
            return getPayButtonCell(tableView, cellForRowAt: indexPath)
        }
    }
}

extension AddCardVC {
    private func getCardNumberCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: CardNumberTVCell.self)
        cell.updatedCardNumber = { [weak self] in
            self?.viewModel.updateValue(type: .cardNumber, value: $0)
        }
        cell.configure(viewModel.getForm.cardNumber)
        return cell
    }
    
    private func getExpiryCVVCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: ExpiryCVVTVCell.self)
        
        cell.openCVVInfo = { [weak self] in
            self?.tabBarController?.addOverlayBlack()
            let vc = CVVInfoVC.instantiate(fromAppStoryboard: .Payment)
            vc.dismissPopup = { [weak self] in
                vc.dismiss(animated: true, completion: { [weak self] in
                    self?.tabBarController?.removeOverlay()
                })
            }
            vc.modalPresentationStyle = .overFullScreen
            self?.present(vc, animated: true)
        }
        cell.updatedExpiry = { [weak self] in
            self?.viewModel.updateExpiry($0)
        }
        cell.updatedCVV = { [weak self] in
            self?.viewModel.updateCVV($0)
        }
        cell.configure(cvv: self.viewModel.getForm.cvv, expiry: self.viewModel.getForm.expiry)
        return cell
    }
    
    private func getCardNameCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: CardNameTVCell.self)
        cell.updatedName = { [weak self] in
            self?.viewModel.updateValue(type: .name, value: $0)
        }
        cell.configure(self.viewModel.getForm.name)
        return cell
    }
    
    private func getEmailTVCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: EmailTVCell.self)
        cell.verificationFlow = { [weak self] in
            self?.triggerEmailVerification()
        }
        cell.updateEmail = { [weak self] in
            self?.viewModel.updateEmail(email: $0)
        }
        cell.configure(email: viewModel.getEmail, verified: viewModel.isEmailVerified, hideEmail: viewModel.hideEmail)
        return cell
    }
    
    private func getSaveCardTVCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: SaveCardCheckboxTVCell.self)
        cell.savedCardChanged = { [weak self] in
            self?.viewModel.saveCard($0)
            self?.baseView.refreshRow(row: .saveCard)
        }
        cell.defaultCardChanged = { [weak self] in
            self?.viewModel.setDefaultCard($0)
            self?.baseView.refreshRow(row: .saveCard)
        }
        cell.configure(isDefault: self.viewModel.getForm.isDefault, savedCard: self.viewModel.getForm.saveCard)
        return cell
    }
    
    private func getPayButtonCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: PayButtonTVCell.self)
        cell.selectionStyle = .none
        cell.priceButtonPressed = { [weak self] in
            let error = self?.viewModel.validateForm()
            if error.isNotNil {
                self?.baseView.refreshRow(row: .payButton)
                self?.baseView.showError(msg: error?.errorMsg ?? "")
            } else {
                //Need to hit api
                self?.handleCheckoutTokenCreation(isApplePay: false)
            }
        }
        cell.setPrice(viewModel.getPrice)
        return cell
    }
    
    private func handleCheckoutTokenCreation(isApplePay: Bool) {
        self.viewModel.createToken(response: { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .success(let tokenString):
                debugPrint("TOKEN FOUND : \(tokenString)")
                let req = self.viewModel.getPaymentRequestObject(token: tokenString)
                self.handleServerPayment(req: req, isApplePay: isApplePay)
            case .failure(let error):
                self.baseView.refreshRow(row: .payButton)
                self.baseView.showError(msg: error.localizedDescription)
            }
        })
    }
    
    private func handleServerPayment(req: AddCardPaymentRequest, isApplePay: Bool) {
        self.viewModel.requestPaymentFromServer(req: req, isApplePay: isApplePay, response: { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .success:
                self.goToOrderSuccess()
            case .failure(let error):
                self.baseView.refreshRow(row: .payButton)
                self.baseView.showError(msg: error.localizedDescription)
            }
        })
    }
    
    private func goToOrderSuccess() {
        CartUtility.syncCart(completion: {
            self.baseView.refreshRow(row: .payButton)
            debugPrint("PAYMENT DONE ON SERVER, ORDER PLACED")
            mainThread {
                let vc = OrderSuccessVC.instantiate(fromAppStoryboard: .CartPayment)
                vc.flow = self.flow
                self.push(vc: vc)
            }
        })
    }
}

extension AddCardVC {
    private func triggerEmailVerification() {
        debugPrint("Email Verification Triggered")
        self.viewModel.setEmailUpdated()
        self.viewModel.sendEmailOTP(response: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.baseView.refreshRow(row: .email)
            switch $0 {
            case .success:
                let vc = PhoneVerificationVC.instantiate(fromAppStoryboard: .Onboarding)
                vc.viewModel = PhoneVerificationVM(_delegate: vc, flowType: .comingFromEditProfile, emailForVerification: strongSelf.viewModel.getEmail)
                strongSelf.push(vc: vc)
            case .failure(let error):
                strongSelf.baseView.showError(msg: error.localizedDescription)
            }
        })
        
    }
}
