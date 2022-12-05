//
//  SignUpView.swift
//  Kudu
//
//  Created by Admin on 28/05/22.
//

import UIKit

class SignUpView: UIView {
    // MARK: IBOutlets
    @IBOutlet private weak var phoneContainerView: UIView!
    @IBOutlet private weak var createAccountLbl: UILabel!
    @IBOutlet private weak var nameTFView: AppTextFieldView!
    @IBOutlet private weak var emailTFView: AppTextFieldView!
    @IBOutlet private weak var signUpButton: AppButton!
    @IBOutlet private weak var phoneNumberTxtField: UITextField!
    @IBOutlet private weak var alreadyHaveAnAccountView: TappableTextView!
    @IBOutlet private weak var termsAndConditionsView: TappableTextView!
    
    // MARK: IB Actions
    @IBAction private func signUpButtonPressed(_ sender: Any) {
        handleViewActions?(.signUpButtonPressed)
    }
    
    @IBAction private func dismissButtonPressed(_ sender: Any) {
        handleViewActions?(.dismissVC)
    }
    
    // MARK: Variables
    var handleViewActions: ((ViewActions) -> Void)?
    var getName: String {
        nameTFView.currentText
    }
    var getEmail: String? {
        emailTFView.currentText == "" ? nil : emailTFView.currentText
    }
    var getPhoneNum: String {
        phoneNumberTxtField.text ?? ""
    }
    enum ViewActions {
        case signUpButtonPressed
        case dismissVC
        case mergeData
    }
    private var appPopUp: AppPopUpView?
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAlreadyHaveAnAccountView()
        setupTermsAndConditionsView()
        phoneContainerView.semanticContentAttribute = .forceLeftToRight
        phoneNumberTxtField.semanticContentAttribute = .forceLeftToRight
        setupTextField()
        nameTFView.textFieldType = .name
        emailTFView.textFieldType = .email
        phoneNumberTxtField.textColor = emailTFView.textColor
        nameTFView.placeholderText = LSCollection.SignUp.enterYourName
        emailTFView.placeholderText = LSCollection.SignUp.enterYourEmailOptional
        phoneNumberTxtField.placeholder = LSCollection.SignUp.enterYourPhoneNumber
        
    }
    
    func clearPhoneField() {
        //self.phoneNumberTxtField.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            self.phoneNumberTxtField.becomeFirstResponder()
        })
    }
    
    func setupView(delegate: SignUpVC, socialData: SocialSignUpRequest? = nil) {
        alreadyHaveAnAccountView.delegate = delegate
        termsAndConditionsView.delegate = delegate
        if let socialInfo = socialData {
            self.showError(message: LSCollection.SignUp.socialAccountNothWitUs, extraDelay: 1.5)
            prefillSocialInfo(socialInfo)
        }
        createAccountLbl.text = LSCollection.SignUp.createAccountSignUpLbl
        signUpButton.setTitle(LSCollection.SignUp.signUp, for: .normal)
    }
    
    private func prefillSocialInfo(_ data: SocialSignUpRequest) {
        if let name = data.name {
            nameTFView.currentText = name
        }
        if let email = data.email {
            emailTFView.currentText = email
        }
    }
    
    private func setupAlreadyHaveAnAccountView() {
        let regularText = NSMutableAttributedString(string: LSCollection.SignUp.alreadyHaveAnAccount, attributes: [NSAttributedString.Key.font: AppFonts.mulishRegular.withSize(12), NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.7)])
        let tappableText = NSMutableAttributedString(string: LSCollection.SignUp.signIn)
        tappableText.addAttributes([.font: AppFonts.mulishMedium.withSize(12), .link: "goToSignIn", .foregroundColor: AppColors.kuduThemeBlue], range: NSRange(location: 0, length: LSCollection.SignUp.signIn.count))
        tappableText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: AppColors.kuduThemeBlue], range: NSRange(location: 0, length: LSCollection.SignUp.signIn.count))
        alreadyHaveAnAccountView.tintColor = AppColors.kuduThemeBlue
        alreadyHaveAnAccountView.isSelectable = true
        alreadyHaveAnAccountView.isUserInteractionEnabled = true
        regularText.append(tappableText)
        alreadyHaveAnAccountView.attributedText = regularText
        alreadyHaveAnAccountView.textAlignment = .center
    }
    
    private func setupTermsAndConditionsView() {
        let greyColor = AppColors.SignUpScreen.termsAndConditionsGrey
        let regularText = NSMutableAttributedString(string: LSCollection.SignUp.bySigningUpYouAgree, attributes: [NSAttributedString.Key.font: AppFonts.mulishRegular.withSize(10), NSAttributedString.Key.foregroundColor: greyColor])
        let termsOfUse = NSMutableAttributedString(string: LSCollection.SignUp.setupTermsAndConditionsViewtermsOfUse)
        termsOfUse.addAttributes([.font: AppFonts.mulishBold.withSize(10), .link: "goToTermsOfUse", .foregroundColor: greyColor], range: NSRange(location: 0, length: LSCollection.SignUp.setupTermsAndConditionsViewtermsOfUse.count))
        termsOfUse.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: greyColor], range: NSRange(location: 0, length: LSCollection.SignUp.setupTermsAndConditionsViewtermsOfUse.count))
        regularText.append(termsOfUse)
        let andText = NSMutableAttributedString(string: LSCollection.SignUp.setupTermsAndConditionsViewAndText, attributes: [NSAttributedString.Key.font: AppFonts.mulishRegular.withSize(10), NSAttributedString.Key.foregroundColor: greyColor])
        regularText.append(andText)
        let privacyPolicy = NSMutableAttributedString(string: LSCollection.SignUp.setupTermsAndConditionsViewPrivacyPolicy)
        privacyPolicy.addAttributes([.font: AppFonts.mulishBold.withSize(10), .link: "goToPrivacyPolicy", .foregroundColor: greyColor], range: NSRange(location: 0, length: LSCollection.SignUp.setupTermsAndConditionsViewPrivacyPolicy.count))
        privacyPolicy.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: greyColor], range: NSRange(location: 0, length: LSCollection.SignUp.setupTermsAndConditionsViewPrivacyPolicy.count))
        regularText.append(privacyPolicy)
        termsAndConditionsView.tintColor = greyColor
        termsAndConditionsView.isSelectable = true
        termsAndConditionsView.isUserInteractionEnabled = true
        
        termsAndConditionsView.attributedText = regularText
        termsAndConditionsView.textAlignment = .center
    }
    
    func showError(message: String, extraDelay: TimeInterval? = nil) {
        let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
        toast.show(message: message, view: self, extraDelay: extraDelay)
    }
    
    private func showMergeAlert() {
        appPopUp = AppPopUpView(frame: CGRect(x: 0, y: 0, width: self.width - AppPopUpView.HorizontalPadding, height: 0))
        appPopUp?.configure(message: LSCollection.SignUp.showMergeAlertConfigureMessage, leftButtonTitle: LSCollection.SignUp.cancel, rightButtonTitle: LSCollection.SignUp.continueText, container: self)
        appPopUp?.handleAction = { [weak self] in
            if $0 == .right {
                self?.handleViewActions?(.mergeData)
            }
        }
    }
    
}

extension SignUpView: UITextFieldDelegate {
        private func setupTextField() {
            phoneNumberTxtField.keyboardType = .phonePad
            phoneNumberTxtField.delegate = self
            phoneNumberTxtField.textContentType = UITextContentType(rawValue: "")
            phoneNumberTxtField.autocorrectionType = .no
            phoneNumberTxtField.autocapitalizationType = .none
            phoneNumberTxtField.spellCheckingType = .no
            phoneNumberTxtField.tintColor = AppColors.darkGray
            phoneNumberTxtField.placeholder = ""
            phoneNumberTxtField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
        
        @objc private func textFieldDidChange(_ textField: UITextField) {
            if (textField.text ?? "").count == 9 {
                textField.resignFirstResponder()
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let text: NSString = (textField.text ?? "") as NSString
            let newString = text.replacingCharacters(in: range, with: string)
            return self.validatePhoneNumber(newString, string)
        }
}

extension SignUpView {
    
    // MARK: API Handling
    func handleAPIRequest() {
        signUpButton.startBtnLoader(color: .white)
        [nameTFView, phoneNumberTxtField, emailTFView].forEach({ $0?.isUserInteractionEnabled = true })
    }
    
    func handleAPIResponse(isSuccess: Bool, errorMsg: String?, showMergeConflict: Bool = false) {
        mainThread {
            self.signUpButton.stopBtnLoader()
            
            if showMergeConflict {
                self.showMergeAlert()
                return
            }
            
            if isSuccess {
                
            } else {
                self.showError(message: errorMsg ?? "")
            }
        }
    }
    
}
