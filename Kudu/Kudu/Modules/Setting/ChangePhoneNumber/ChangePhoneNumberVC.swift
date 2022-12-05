//
//  ChangePhoneNumberVC.swift
//  Kudu
//
//  Created by Admin on 28/10/22.
//

import UIKit

class ChangePhoneNumberVC: BaseVC {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var changePhoneNumberTF: UITextField!
    @IBOutlet private weak var changePhoneNumContainer: UIView!
    @IBOutlet private weak var verifyNowButton: AppButton!
    
    @IBAction private func backButtonPressed(_ sender: Any) {
        self.pop()
    }
    
    @IBAction private func verifyButtonPressed(_ sender: Any) {
        if changePhoneNumberTF.text ?? "" == "" {
            self.showError(msg: LSCollection.SignUp.pleaseEnterPhoneNumber)
            return
        }
        
        if (changePhoneNumberTF.text ?? "").count < 9 {
            self.showError(msg: LSCollection.SignUp.pleaseEnterValidPhoneNumber)
            return
        }
        
        if (changePhoneNumberTF.text ?? "") == DataManager.shared.loginResponse?.mobileNo ?? "" {
            self.showError(msg: "Please enter a new number")
            return
        }
        
        self.verifyNowButton.startBtnLoader(color: .white)
        let changeNumberReq = ChangePhoneNumberRequest(mobileNo: self.changePhoneNumberTF.text ?? "", isSendOtp: true)
        self.hitAPI(req: changeNumberReq)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        
    }
    
    private func initialSetup() {
        verifyNowButton.setTitle(LSCollection.Profile.verifyNow, for: .normal)
        changePhoneNumberTF.placeholder = LSCollection.Setting.enterMobileNumber
        changePhoneNumContainer.semanticContentAttribute = .forceLeftToRight
        changePhoneNumberTF.semanticContentAttribute = .forceLeftToRight
    }
    
    private func showError(msg: String) {
        mainThread {
            self.verifyNowButton.stopBtnLoader(titleColor: .white)
            let errorView = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.view.width - 32, height: 48))
            mainThread {
                errorView.show(message: msg, view: self.view)
            }
        }
    }
}

extension ChangePhoneNumberVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text: NSString = (textField.text ?? "") as NSString
        let newString = text.replacingCharacters(in: range, with: string)
        let allowed = CharacterSet(charactersIn: "1234567890")
        let enteredCharacterSet = CharacterSet(charactersIn: newString)
        if !enteredCharacterSet.isSubset(of: allowed) || newString.count > 9 {
            return false
        }
        return true
    }
}

extension ChangePhoneNumberVC {
    private func hitAPI(req: ChangePhoneNumberRequest) {
        APIEndPoints.SettingsEndPoints.changePhoneNumber(req: req, success: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.verifyNowButton.stopBtnLoader(titleColor: .white)
            let vc = PhoneVerificationVC.instantiate(fromAppStoryboard: .Onboarding)
            vc.viewModel = PhoneVerificationVM(_delegate: vc, flowType: .comingFromChangeNumberFlow)
            vc.viewModel?.setChangePhoneRequest(req: req)
            self?.push(vc: vc)
        }, failure: { [weak self] (error) in
            self?.verifyNowButton.stopBtnLoader(titleColor: .white)
            self?.showError(msg: error.msg)
        })
    }
}
