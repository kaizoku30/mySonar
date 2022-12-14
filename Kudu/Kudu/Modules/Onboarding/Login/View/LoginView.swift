//
//  LoginView.swift
//  Kudu
//
//  Created by Admin on 12/05/22.
//

import UIKit

class LoginView: UIView {
    
    // MARK: Constraints
    @IBOutlet private weak var errorLabelHeightConstraint: NSLayoutConstraint!
    
    // MARK: Outlets
    @IBOutlet private weak var pleaseEnterPhoneNumberLbl: UILabel!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var errorImgView: UIImageView!
    @IBOutlet private weak var countryCodeView: UIView!
    @IBOutlet private weak var phoneNumberView: UIView!
    @IBOutlet private weak var getOtpButton: AppButton!
    @IBOutlet private weak var signUpTextView: TappableTextView!
    @IBOutlet private weak var bottomContainer: UIView!
    @IBOutlet private weak var phoneNumberTxtField: UITextField!
    @IBOutlet private weak var orContinueWithLbl: UILabel!
    @IBOutlet private weak var loginLbl: UILabel!
    @IBOutlet private weak var loginToUnlockAwesomeFeatureLbl: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var appleLoginView: UIView!
    @IBOutlet private weak var googleLoginView: UIView!
    // MARK: Actions
    @IBAction private func continueWithGoogle(_ sender: Any) {
        self.handleViewActions?(.googleLogin)
    }
    
    @IBAction private func backButtonPressed(_ sender: Any) {
        GuestUserCache.shared.clearCache()
        self.handleViewActions?(.backButtonPressed)
    }
    
    @IBAction private func continueWithTwitter(_ sender: Any) {
        self.handleViewActions?(.twitterLogin)
    }
    
    @IBAction private func continueWithFB(_ sender: Any) {
        self.handleViewActions?(.facebookLogin)
    }
    
    @IBAction private func continueWithApple(_ sender: Any) {
        self.handleViewActions?(.appleLogin)
    }
    
    @IBAction private func getOtpButtonPressed(_ sender: Any) {
        self.handleViewActions?(.loginButtonPressed)
    }
    
    @objc private func googleLogin() {
        self.handleViewActions?(.googleLogin)
    }
    
    @objc private func appleLogin() {
        self.handleViewActions?(.appleLogin)
    }
    
    // MARK: Variables
    var getMobileNumberEntered: String { phoneNumberTxtField.text ?? "" }
    var handleViewActions: ((ViewActions) -> Void)?
    
    enum ViewActions {
        case loginButtonPressed
        case googleLogin
        case twitterLogin
        case facebookLogin
        case appleLogin
        case backButtonPressed
    }
    
    enum APICalled {
        case loginAPI
        case socialAPI
    }
    
    private enum ButtonState {
        case enabled
        case disabled
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    // MARK: Setup Functions
    
    private func initialSetup() {
        phoneNumberView.semanticContentAttribute = .forceLeftToRight
        countryCodeView.semanticContentAttribute = .forceLeftToRight
        errorImgView.semanticContentAttribute = .forceLeftToRight
        phoneNumberTxtField.semanticContentAttribute = .forceLeftToRight
        phoneNumberTxtField.textAlignment = .left
        bottomContainer.roundTopCorners(cornerRadius: 32)
        errorImgView.isUserInteractionEnabled = true
        errorImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(errorImgViewTapped)))
        loginToUnlockAwesomeFeatureLbl.text = LSCollection.Login.loginToUnlockAwesomeFeatures
        backButton.isHidden = false
        googleLoginView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(googleLogin)))
        appleLoginView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(appleLogin)))
    }
    
    func setupView(delegate: LoginVC) {
        getOtpButton.setTitle(LSCollection.Login.getOtp, for: .normal)
        pleaseEnterPhoneNumberLbl.text = LSCollection.Login.pleaseEnterYourPhoneNumber
        orContinueWithLbl.text = LSCollection.Login.orContinueWith
        loginLbl.text = LSCollection.Login.login
        signUpTextView.delegate = delegate
        setUpSignUpLabel()
        setupTextField()
    }
    
    private func setupButton(state: ButtonState) {
        if state == .enabled {
            getOtpButton.setTitle(LSCollection.Login.getOtp, for: .normal)
            getOtpButton.isUserInteractionEnabled = true
            getOtpButton.backgroundColor = AppColors.LoginScreen.selectedBgButtonColor
            getOtpButton.setTitleColor(.white, for: .normal)
        } else {
            getOtpButton.setTitle(LSCollection.Login.getOtp, for: .normal)
            getOtpButton.isUserInteractionEnabled = false
            getOtpButton.backgroundColor = AppColors.LoginScreen.unselectedButtonBg
            getOtpButton.setTitleColor(AppColors.LoginScreen.unselectedButtonTextColor, for: .normal)
        }
    }
    
    private func setUpSignUpLabel() {
        let regularText = NSMutableAttributedString(string: LSCollection.Login.dontHaveAnAccount, attributes: [NSAttributedString.Key.font: AppFonts.mulishRegular.withSize(12), NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.6)])
        let tappableText = NSMutableAttributedString(string: LSCollection.Login.signUp)
        tappableText.addAttributes([.font: AppFonts.mulishRegular.withSize(12), .link: "SignUp", .foregroundColor: AppColors.kuduThemeBlue], range: NSRange(location: 0, length: LSCollection.Login.signUp.count))
        signUpTextView.tintColor = AppColors.kuduThemeBlue
        signUpTextView.isSelectable = true
        signUpTextView.isUserInteractionEnabled = true
        regularText.append(tappableText)
        signUpTextView.attributedText = regularText
        signUpTextView.textAlignment = .center
    }
}

extension LoginView {
    
    // MARK: Error Handling
    
    func resetLoginField(msg: String) {
        getOtpButton.stopBtnLoader()
        setupButton(state: .disabled)
        phoneNumberTxtField.text = ""
		if msg != "" {
			toggleErrorLabel(msg, show: true, excludeErrorImg: true)
			return
		} else {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
				self.phoneNumberTxtField.becomeFirstResponder()
			})
		}
    }
    
    private func toggleErrorLabel(_ msg: String, show: Bool, excludeErrorImg: Bool = false) {
        DispatchQueue.main.async {
            self.layoutIfNeeded()
            self.errorLabel.text = msg
            self.errorLabel.adjustsFontSizeToFitWidth = true
            self.errorLabelHeightConstraint.constant = show == true ? 18 : 0
            if excludeErrorImg == false {
                self.errorImgView.image = show == true ? AppImages.LoginScreen.failureCircle : AppImages.LoginScreen.successCircle
                self.errorImgView.isHidden = true
            }
            if show {
                UIView.animate(withDuration: 1.0, animations: {
                     self.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc private func errorImgViewTapped() {
        phoneNumberTxtField.text = ""
        phoneNumberTxtField.becomeFirstResponder()
        setupButton(state: .disabled)
    }
    
}

extension LoginView: UITextFieldDelegate {
    // MARK: Textfield Handling
    
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.toggleErrorLabel("", show: false)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if (textField.text ?? "").count == 9 {
            textField.resignFirstResponder()
            self.setupButton(state: .enabled)
        } else {
            self.setupButton(state: .disabled)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text: NSString = (textField.text ?? "") as NSString
        let userNumber = text.replacingCharacters(in: range, with: string)
        return self.validatePhoneNumber(userNumber, string)
    }
}

extension LoginView {
    
    // MARK: API Handling
    
    func handleAPIRequest(_ api: APICalled) {
        self.isUserInteractionEnabled = false
        switch api {
        case .loginAPI:
            self.toggleErrorLabel("", show: false)
            self.getOtpButton.startBtnLoader(color: .white)
        case .socialAPI:
            self.toggleErrorLabel("", show: false)
            self.getOtpButton.startBtnLoader(color: .white)
        }
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, errorMsg: String?) {
        self.isUserInteractionEnabled = true
        switch api {
        case .loginAPI:
            self.getOtpButton.stopBtnLoader()
            if isSuccess {
                self.toggleErrorLabel("", show: false)
                self.getOtpButton.stopBtnLoader()
            } else {
                self.toggleErrorLabel(errorMsg ?? "", show: true)
            }
        case .socialAPI:
            self.getOtpButton.stopBtnLoader()
            if errorMsg.isNotNil {
                self.toggleErrorLabel(errorMsg ?? "", show: true, excludeErrorImg: true)
            }
        }
    }
}
