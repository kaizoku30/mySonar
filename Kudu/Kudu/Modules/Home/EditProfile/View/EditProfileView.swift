//
//  EditProfileView.swift
//  Kudu
//
//  Created by Admin on 10/08/22.
//

import UIKit

class EditProfileView: UIView {

    @IBOutlet private weak var editPhoneNumberButton: AppButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nameTFView: AppTextFieldView!
    @IBOutlet private weak var phoneNumberTF: UITextField!
    @IBOutlet private weak var emailTFView: AppTextFieldView!
    @IBOutlet private weak var updateButton: AppButton!
    @IBOutlet private weak var nameContainer: UIView!
    @IBOutlet private weak var phoneContainer: UIView!
    @IBOutlet private weak var emailContainer: UIView!
    @IBOutlet private weak var editNameButton: AppButton!
    @IBOutlet private weak var countryCodeMarker: UILabel!
    @IBOutlet private weak var editEmailButton: AppButton!
    @IBOutlet private weak var phoneTFContainer: AppTextFieldView!
    @IBAction private func updateButtonPressed(_ sender: Any) {
        self.handleViewActions?(.updateProfile)
    }
    @IBAction func editPhoneNumberPressed(_ sender: Any) {
        self.handleViewActions?(.editPhoneNumberFlow)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.handleViewActions?(.backButtonPressed)
    }
    
    @IBAction func editNamePressed(_ sender: Any) {
        editNameButton.isHidden = true
        nameTFView.focus()
    }
    
    @IBAction func editEmailPressed(_ sender: Any) {
        editEmailButton.isHidden = true
        emailTFView.focus()
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    
    enum ViewActions {
        case updateProfile
        case editPhoneNumberFlow
        case backButtonPressed
        case nameUpdated(updatedText: String)
        case emailUpdated(updatedText: String)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    private func initialSetup() {
        titleLabel.text = LSCollection.EditProfile.editProfile
        setupTextfields()
    }
    
    func setupView(name: String, phoneNum: String, email: String) {
        nameTFView.currentText = name
        phoneNumberTF.text = phoneNum
        emailTFView.currentText = email
    }
    
    func handleEmailConflict() {
        editEmailButton.isHidden = true
        //emailTFView.currentText = ""
        emailTFView.focus()
    }
    
    func showError(msg: String) {
        let errorView = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
        mainThread {
            errorView.show(message: msg, view: self)
        }
    }
    
}

extension EditProfileView {
    private func setupTextfields() {
        updateButton.setTitle(LSCollection.EditProfile.updateButton, for: .normal)
        editPhoneNumberButton.semanticContentAttribute = .forceLeftToRight
        phoneTFContainer.semanticContentAttribute = .forceLeftToRight
        countryCodeMarker.semanticContentAttribute = .forceLeftToRight
        //phoneContainer.isUserInteractionEnabled = false
        countryCodeMarker.isUserInteractionEnabled = false
        phoneNumberTF.isUserInteractionEnabled = false
        phoneNumberTF.textColor = .black
        phoneContainer.semanticContentAttribute = .forceLeftToRight
        phoneNumberTF.semanticContentAttribute = .forceLeftToRight
        [nameTFView, emailTFView].forEach({
            $0?.backgroundColor = .clear
            $0?.font = AppFonts.mulishMedium.withSize(14)
            $0?.isUserInteractionEnabled = false
        })
        nameTFView.textFieldType = .name
        emailTFView.textFieldType = .email
        nameTFView.placeholderText = LSCollection.AddNewAddress.enterYourName
        emailTFView.placeholderText = LSCollection.SignUp.enterYourEmailOptional
        nameTFView.textFieldDidChangeCharacters = { [weak self] in
            self?.handleViewActions?(.nameUpdated(updatedText: $0 ?? ""))
        }
        emailTFView.textFieldDidBeginEditing = { [weak self] in
            self?.emailTFView.isUserInteractionEnabled = true
        }
        emailTFView.textFieldDidChangeCharacters = { [weak self] in
            self?.handleViewActions?(.emailUpdated(updatedText: $0 ?? ""))
        }
        nameTFView.textFieldFinishedEditing = { [weak self] _ in
            self?.emailTFView.isUserInteractionEnabled = false
            self?.editNameButton.isHidden = false
        }
        emailTFView.textFieldFinishedEditing = { [weak self] _ in
            self?.editEmailButton.isHidden = false
        }
    }
}

extension EditProfileView {
    
    func handleAPIRequest() {
        self.updateButton.startBtnLoader(color: .white)
        self.nameContainer.isUserInteractionEnabled = false
        self.emailContainer.isUserInteractionEnabled = false
    }
    
    func handleAPIResponse(errorMsg: String?, errorCode: Int?) {
        mainThread {
            self.nameContainer.isUserInteractionEnabled = true
            self.emailContainer.isUserInteractionEnabled = true
            self.updateButton.stopBtnLoader(titleColor: .white)
            
            if let errorCode = errorCode, errorCode == 400 {
                self.showAlreadyAssociatedAlert()
                return
            }
            
            if let errorMsg = errorMsg {
                self.showError(msg: errorMsg)
                return
            }
        }
    }
    
    func showAlreadyAssociatedAlert() {
        let appAlert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: self.width -  AppPopUpView.HorizontalPadding, height: 0))
        appAlert.configure(title: LSCollection.EditProfile.emailAlreadyVerified, message: LSCollection.EditProfile.emailAlreadyAssociated, leftButtonTitle: LSCollection.EditProfile.cancel, rightButtonTitle: LSCollection.EditProfile.updateButton, container: self)
        appAlert.handleAction = { [weak self] (action) in
            if action == .right {
                self?.editEmailButton.isHidden = true
                //self?.emailTFView.currentText = ""
                self?.emailTFView.focus()
            }
        }
    }
    
}
