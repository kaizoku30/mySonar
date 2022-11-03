//
//  PhoneVerificationView.swift
//  Kudu
//
//  Created by Admin on 17/05/22.
//

import UIKit
import OTPFieldView
import KDCircularProgress

class PhoneVerificationView: UIView {
    @IBOutlet private weak var verifyPhoneTitleLabel: UILabel!
    @IBOutlet private weak var pleaseEnterTheOtpCodeLbl: UILabel!
    @IBOutlet private weak var resendOtpButton: AppButton!
    @IBOutlet private weak var verifyButton: AppButton!
    @IBOutlet private weak var noOtpReceivedView: UIView!
    @IBOutlet private weak var errorLabelHeightAnchor: NSLayoutConstraint!
    @IBOutlet private weak var dontReceiveTheOtpLbl: UILabel!
    @IBOutlet private weak var mobileLabel: UILabel!
    @IBOutlet private weak var differentNumberLabel: UILabel!
    @IBOutlet private weak var circularProgressView: KDCircularProgress!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var otpView: RTOtpView!
    @IBOutlet private weak var otpTimerLabel: UILabel!
    @IBOutlet private weak var verifyButtonBottomConstraint: NSLayoutConstraint!
    
    @IBAction private func resendOtpPressed(_ sender: Any) {
        numberOfTriesRemaining -= 1
        var errorString = ""
        if numberOfTriesRemaining == 1 {
            errorString = LocalizedStrings.PhoneVerification.youHaveXNumberAttemptRemaining.replace(string: CommonStrings.numberPlaceholder, withString: "1")
        } else {
            errorString = LocalizedStrings.PhoneVerification.youHaveXNumberAttemptsRemaining.replace(string: CommonStrings.numberPlaceholder, withString: "\(numberOfTriesRemaining)")
        }
        toggleErrorLabel(errorMsg: errorString, show: true, shake: false, toggleBorder: false)
        self.handleViewActions?(.resendOtpPressed)
    }
    
    @IBAction private func dismissButtonPressed(_ sender: Any) {
        self.handleViewActions?(.dismissVC)
    }
    
    @IBAction private func verifyButtonPressed(_ sender: Any) {
        self.handleViewActions?(.verifyButtonPressed(otpString: self.otpView.getCurrentOtp))
    }
    
    private var timer: Timer?
    private var otpCounter: Int = 120
    private var timeRefForBackground: Date = Date()
    private var numberOfTriesRemaining = 5
    var handleViewActions: ((ViewActions) -> Void)?
        
    enum APICalled {
        case verifyMobileOtpAPI
        case resendOtp
    }
    
    enum ViewActions {
        case verifyButtonPressed(otpString: String)
        case resendOtpPressed
        case dismissVC
        case differentLabelPressed
    }
    
    private enum ButtonState {
        case enabled
        case disabled
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
        addKeyboardObservers()
        dontReceiveTheOtpLbl.text = LocalizedStrings.PhoneVerification.didntReceiveTheOTPCode
        pleaseEnterTheOtpCodeLbl.text = LocalizedStrings.PhoneVerification.pleaseEnterTheOtpCodeSentTo
    }
    
    private func initialSetup() {
        otpView.semanticContentAttribute = .forceLeftToRight
        verifyButton.setTitle(LocalizedStrings.PhoneVerification.verify, for: .normal)
        verifyPhoneTitleLabel.text = LocalizedStrings.PhoneVerification.verifyPhoneNumber
        NotificationCenter.default.addObserver(self, selector: #selector(enteredForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(movedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.mobileLabel.text = ""
        self.otpTimerLabel.text = ""
        let attributedText = NSAttributedString(string: LocalizedStrings.PhoneVerification.resendCode, attributes: [.font: AppFonts.mulishMedium.withSize(12), .foregroundColor: AppColors.PhoneVerificationScreen.resendButtonColor, .underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: AppColors.PhoneVerificationScreen.resendButtonColor])
        self.resendOtpButton.setAttributedTitle(attributedText, for: .normal)
    }
    
    func setupView(mobileNum: String, email: String?) {
        setupCircularView()
        setupOTPField()
        if let email = email {
            self.mobileLabel.text = email
            self.verifyPhoneTitleLabel.text = LocalizedStrings.PhoneVerification.verifyEmailAddress
            setDifferentNumberLabel(emailFlow: true)
        } else {
            self.mobileLabel.text = "+966 \(mobileNum)"
            setDifferentNumberLabel()
        }
        startTimer()
    }
    
    func focusOTP() {
        self.otpView.focusOTPField()
    }
    
    private func setDifferentNumberLabel(emailFlow: Bool = false) {
        let differentString = emailFlow ? LocalizedStrings.PhoneVerification.differentEmail : LocalizedStrings.PhoneVerification.differentNumber
        let underLinedText = NSAttributedString(string: differentString, attributes: [.font: AppFonts.mulishBold.withSize(12), .foregroundColor: AppColors.PhoneVerificationScreen.differentNumLabel, .underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: AppColors.PhoneVerificationScreen.differentNumLabel])
        differentNumberLabel.attributedText = underLinedText
        differentNumberLabel.isUserInteractionEnabled = true
        differentNumberLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(differentNumTapped)))
    }
    
    @objc private func differentNumTapped() {
        self.handleViewActions?(.differentLabelPressed)
    }
    
    private func setupCircularView() {
        circularProgressView.startAngle = -90
        circularProgressView.progressThickness = 0.3
        circularProgressView.trackThickness = (3/4)*0.3
        circularProgressView.clockwise = false
        circularProgressView.roundedCorners = true
        circularProgressView.glowMode = .noGlow
        circularProgressView.trackColor = AppColors.PhoneVerificationScreen.trackColorGrey
        circularProgressView.progressColors = [AppColors.PhoneVerificationScreen.progressColorYellow]
        circularProgressView.progress = 0
    }
    
    func getTime() -> String {
        var stringOtp = ""
        if self.otpCounter < 10 {
            stringOtp = "0:0\(self.otpCounter)"
        } else if self.otpCounter < 60 {
            stringOtp = "0:\(self.otpCounter)"
        } else if self.otpCounter == 60 {
            stringOtp = "1:00"
        } else if self.otpCounter < 70 {
            stringOtp = "1:0\(self.otpCounter-60)"
        } else if self.otpCounter < 120 {
            stringOtp = "1:\(self.otpCounter-60)"
        } else {
            stringOtp = "2:00"
        }
        
        return stringOtp
    }
    
    func startTimer(time: Int = 120) {
        self.timer?.invalidate()
        self.otpCounter = time
        self.noOtpReceivedView.isHidden = true
        self.circularProgressView.progress = Double(self.otpCounter)/120
        self.circularProgressView.isHidden = false
        
        self.otpTimerLabel.text = "\(getTime())"
        self.otpTimerLabel.isHidden = false
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.otpCounter != 0 {
                strongSelf.otpCounter -= 1
                strongSelf.circularProgressView.progress = Double(strongSelf.otpCounter)/120
                strongSelf.otpTimerLabel.text = "\(strongSelf.getTime())"
            } else {
                strongSelf.stopTimer()
            }
        })
        self.timer?.fire()
    }
    
    func stopTimer() {
        if numberOfTriesRemaining == 0 {
            self.handleViewActions?(.dismissVC)
            return
        }
        self.otpTimerLabel.isHidden = true
        self.circularProgressView.isHidden = true
        self.noOtpReceivedView.isHidden = false
        self.timer?.invalidate()
    }
    
    private func setupButton(state: ButtonState) {
        if state == .enabled {
            verifyButton.isUserInteractionEnabled = true
            verifyButton.backgroundColor = AppColors.LoginScreen.selectedBgButtonColor
            verifyButton.setTitleColor(.white, for: .normal)
        } else {
            verifyButton.isUserInteractionEnabled = false
            verifyButton.backgroundColor = AppColors.LoginScreen.unselectedButtonBg
            verifyButton.setTitleColor(AppColors.LoginScreen.unselectedButtonTextColor, for: .normal)
        }
    }
    
    private func toggleErrorLabel(errorMsg: String, show: Bool, shake: Bool = true, toggleBorder: Bool = true) {
        if show == true {
            errorLabel.text = errorMsg
            errorLabel.isHidden = false
            errorLabelHeightAnchor.constant = 18
            if toggleBorder {
                otpView.toggleErrorState(show: true)
            }
            self.layoutIfNeeded()
        } else {
            if toggleBorder {
                otpView.toggleErrorState(show: false)
            }
            errorLabel.isHidden = true
            errorLabelHeightAnchor.constant = 0
            self.layoutIfNeeded()
        }
    }
    
    private func setupOTPField() {
        otpView.otpEntered = {
            self.toggleErrorLabel(errorMsg: "", show: false)
            debugPrint(" OTP ENTERED : \($0)")
            if $0.count == 6 {
                self.setupButton(state: .enabled)
            } else {
                self.setupButton(state: .disabled)
            }
        }
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
//        animateWithKeyboard(notification: notification, animations: { [weak self] (keyboardRect) in
//            mainThread {
//                guard let strongSelf = self else { return }
//
//                strongSelf.verifyButton.isHidden = true
//                strongSelf.verifyButtonBottomConstraint.constant = keyboardRect.height + 16 - strongSelf.safeAreaInsets.bottom
//                strongSelf.layoutIfNeeded()
//                let noOtpFrame = strongSelf.noOtpReceivedView.frame
//                let buttonFrame = strongSelf.verifyButton.frame
//                let bottomPoint = noOtpFrame.origin.y + noOtpFrame.height + 20
//                if bottomPoint >= buttonFrame.origin.y {
//                    strongSelf.verifyButton.isHidden = true
//                } else {
//                    strongSelf.verifyButton.isHidden = false
//                }
//            }
//        })
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
//        animateWithKeyboard(notification: notification) { [weak self] (_) in
//            mainThread {
//                guard let strongSelf = self else { return }
//                strongSelf.verifyButton.isHidden = false
//                strongSelf.verifyButtonBottomConstraint.constant = 32
//                //self.textViewBottomC.constant = 95
//                strongSelf.layoutIfNeeded()
//            }}
    }
}

extension PhoneVerificationView {
    // MARK: Handling Background/Foreground Mgmt
    @objc func movedToBackground() {
        debugPrint("Moved to background at \(Date().toString(dateFormat: Date.DateFormat.hmmazzz.rawValue))")
        timeRefForBackground = Date()
        self.stopTimer()
    }
    
    @objc func enteredForeground() {
        debugPrint("Entered foreground at \(Date().toString(dateFormat: Date.DateFormat.hmmazzz.rawValue))")
        let timeElapsed = Date().secondsFrom(timeRefForBackground)
        if otpCounter - timeElapsed > 0 {
            otpCounter -= timeElapsed
            self.startTimer(time: self.otpCounter)
        } else {
            otpCounter = 0
            self.stopTimer()
        }
    }
}

extension PhoneVerificationView {
    func handleAPIRequest(_ api: APICalled) {
        switch api {
        case .verifyMobileOtpAPI:
            toggleErrorLabel(errorMsg: "", show: false)
            verifyButton.startBtnLoader(color: .white)
            otpView.isUserInteractionEnabled = false
        case .resendOtp:
            noOtpReceivedView.isHidden = true
            startTimer()
        }
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, errorMsg: String?) {
        switch api {
        case .verifyMobileOtpAPI:
            self.verifyButton.stopBtnLoader()
            self.otpView.isUserInteractionEnabled = true
            if isSuccess {
                
            } else {
                self.setupButton(state: .disabled)
                self.toggleErrorLabel(errorMsg: errorMsg ?? "", show: true)
            }
        case .resendOtp:
            break
        }
    }
}
