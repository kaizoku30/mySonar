//
//  CartCouponListView.swift
//  Kudu
//
//  Created by Admin on 26/09/22.
//

import UIKit

class CartCouponListView: UIView {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var couponCodeTF: AppTextFieldView!
    @IBOutlet private weak var applyButton: AppButton!
    @IBAction private func applyButtonPressed(_ sender: Any) {
        if applyButton.titleColor(for: .normal) == .black, couponCodeTF.currentText.isEmpty == false {
            startLoader()
            handleViewActions?(.applyButtonPressed(couponCode: couponCodeTF.currentText))
        }
    }
    @IBAction private func backButtonPressed(_ sender: Any) {
        handleViewActions?(.backButtonPressed)
    }
    enum ViewAction {
        case backButtonPressed
        case applyButtonPressed(couponCode: String)
    }
    @IBOutlet private weak var textFieldContainer: UIView!
    
    var handleViewActions: ((ViewAction) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        handleTF()
        couponCodeTF.textFieldType = .couponCode
        couponCodeTF.placeholderText = "Enter Coupon Code"
        couponCodeTF.font = AppFonts.mulishMedium.withSize(14)
        couponCodeTF.textColor = .black
    }
    
    private func startLoader() {
        self.applyButton.startBtnLoader(color: .black)
        self.prepareForCouponApplication()
    }
    
    func prepareForCouponApplication() {
        self.tableView.isUserInteractionEnabled = false
        self.textFieldContainer.isUserInteractionEnabled = false
    }
    
    private func enableViews() {
        self.tableView.isUserInteractionEnabled = true
        self.textFieldContainer.isUserInteractionEnabled = true
        self.tableView.reloadData()
    }
    
    func stopButtonLoader() {
        mainThread {
            self.applyButton.stopBtnLoader(titleColor: .black)
            self.enableViews()
        }
    }
    
    func showError(msg: String, completionBlock: (() -> Void)?) {
        mainThread {
            let error = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            error.show(message: msg, view: self, extraDelay: 1.75, completionBlock: completionBlock)
        }
    }
    
    func showSuccessPopUp(_ type: SuccessAlertView.AlertType, completion: (() -> Void)?) {
        let successPopUp = SuccessAlertView(frame: CGRect(x: 0, y: 0, width: self.width - SuccessAlertView.HorizontalPadding, height: SuccessAlertView.Height))
        successPopUp.configure(type: type, container: self, displayTime: 2)
        successPopUp.handleDismissal = {
            completion?()
        }
    }
    
    private func handleTF() {
        couponCodeTF.textFieldDidChangeCharacters = { [weak self] in
            if let text = $0, !text.isEmpty {
                self?.applyButton.setTitleColor(.black, for: .normal)
            } else {
                self?.applyButton.setTitleColor(AppColors.Coupon.applyCouponCodeDisabled, for: .normal)
            }
        }
    }
    
    func refreshTable() {
        mainThread {
            self.tableView.reloadData()
        }
    }
    
    func reloadRow(index: Int) {
        mainThread {
            self.tableView.reloadData()
            //self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
}
