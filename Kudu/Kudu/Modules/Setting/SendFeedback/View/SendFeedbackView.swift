//
//  SendFeedbackView.swift
//  Kudu
//
//  Created by Admin on 22/07/22.
//

import UIKit

class SendFeedbackView: UIView {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorToastView: AppErrorToastView!
    @IBOutlet weak var errorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var submitButton: AppButton!
    @IBOutlet weak var sendFeedbackLabel: UILabel!
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.handleViewActions?(.backButtonPressed)
    }
    
    enum Cells: Int, CaseIterable {
        case name = 0
        case number
        case email
		case queryType
        case textView
        case uploadImage
        case uploadedImage
    }
    
    enum ViewActions {
        case submitButtonPressed
        case backButtonPressed
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sendFeedbackLabel.text = LocalizedStrings.Setting.sendFeedback
        submitButton.setTitle(LocalizedStrings.Setting.submit, for: .normal)
        tableView.showsVerticalScrollIndicator = false
        submitButton.handleBtnTap = { [weak self] in
            self?.handleViewActions?(.submitButtonPressed)
        }
    }
    
    func showError(message: String, extraDelay: TimeInterval? = nil) {
        mainThread {
            let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            toast.show(message: message, view: self)
        }
    }
    
    func showSuccessPopUp(completion: (() -> Void)?) {
        let successPopUp = SuccessAlertView(frame: CGRect(x: 0, y: 0, width: self.width - SuccessAlertView.HorizontalPadding, height: SuccessAlertView.Height))
        successPopUp.configure(type: .feedbackSubmitted, container: self, displayTime: 2)
        successPopUp.handleDismissal = {
            completion?()
        }
    }
}
