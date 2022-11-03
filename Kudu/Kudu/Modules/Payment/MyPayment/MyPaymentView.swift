//
//  MyPaymentView.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit

class MyPaymentView: UIView {
    @IBOutlet private weak var tableView: UITableView!
    
    @IBAction func backButtonPressed(_ sender: Any) {
   popVC?()
    }
    @IBOutlet private weak var savedCardsLabel: UILabel!
    
    var popVC: (() -> Void)?
    
    func refreshTable() {
        mainThread({
            self.tableView.reloadData()
        })
    }
    
    func hideTableView(hide: Bool) {
        mainThread({
            self.savedCardsLabel.isHidden = hide
            self.tableView.isHidden = hide
        })
    }
    
    func showError(msg: String) {
        mainThread({
            let appErrorToast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            appErrorToast.show(message: msg, view: self)
        })
    }
    
    func showDeletePopUp(deleteCard: @escaping (() -> Void)) {
        mainThread {
            let popUpAlert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 0))
            //popUpAlert.rightButtonBgColor = AppColors.MyAddressScreen.deleteBtnColor
            popUpAlert.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: .left)
            popUpAlert.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: nil)
            popUpAlert.configure(message: "Are you sure you want to delete this Card?", leftButtonTitle: LocalizedStrings.MyAddress.delete, rightButtonTitle: LocalizedStrings.MyAddress.cancel, container: self, setMessageAsTitle: true)
            popUpAlert.handleAction = {
                if $0 == .right { return }
                deleteCard()
            }
        }
    }
}
