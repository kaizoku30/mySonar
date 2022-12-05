//
//  SupportDetailsView.swift
//  Kudu
//
//  Created by Admin on 23/07/22.
//

import UIKit
import NVActivityIndicatorView

class SupportDetailsView: UIView {
    @IBOutlet private weak var errorToastView: AppErrorToastView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var loader: NVActivityIndicatorView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var phoneView: UIView!
    @IBOutlet private weak var emailView: UIView!
    @IBOutlet private weak var callUsLabel: UILabel!
    @IBOutlet private weak var supportMobileNo: UILabel!
    @IBOutlet private weak var mailUsLabel: UILabel!
    @IBOutlet private weak var supportMailId: UILabel!
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.handleViewActions?(.backButtonPressed)
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    
    enum ViewActions {
        case backButtonPressed
        case call
        case mail
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizers()
        titleLabel.text = LSCollection.Setting.support
        infoLabel.text = LSCollection.Setting.itLooksLikeYouAreExperiencingProblems
        callUsLabel.text = LSCollection.Setting.callUs
        mailUsLabel.text = LSCollection.Setting.emailUs
    }
    
    private func addGestureRecognizers() {
        phoneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(phoneViewTapped)))
        emailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emailViewTapped)))
    }
    @objc private func phoneViewTapped() {
        self.handleViewActions?(.call)
    }
    
    @objc private func emailViewTapped() {
        self.handleViewActions?(.mail)
    }
    
    func showLoader(show: Bool) {
        mainThread {
            if show {
                self.loader.startAnimating()
            } else {
                self.loader.isHidden = true
                self.loader.stopAnimating()
            }
        }
    }
    
    func showErrorToast(message: String, extraDelay: TimeInterval = 0) {
        mainThread {
            let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            toast.show(message: message, view: self)
        }
    }
    
    func showDetails(data: SupportDetailsData) {
        mainThread { [weak self] in
            self?.supportMobileNo.text = "+966-" + "\(data.contactNumber ?? "")"
            self?.supportMailId.text = "\(data.email ?? "")"
            self?.supportMobileNo.adjustsFontSizeToFitWidth = true
            self?.supportMailId.adjustsFontSizeToFitWidth = true
            self?.loader.isHidden = true
            self?.loader.stopAnimating()
            self?.stackView.isHidden = false
        }
    }

}
