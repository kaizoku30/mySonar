//
//  NotificationPrefVC.swift
//  Kudu
//
//  Created by Admin on 09/08/22.
//

import UIKit

class NotificationPrefVC: BaseVC {
    @IBOutlet private var baseView: NotificationPrefView!
    var viewModel: NotificationPrefVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleActions()
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] (action) in
            guard let `self` = self else { return }
            switch action {
            case .backButtonPressed:
                self.pop()
            case .updateSettings:
                self.baseView.handleAPIRequest(.notificationPrefAPI)
                self.viewModel?.updateSettingsOnServer()
            }
        }
    }
}

extension NotificationPrefVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NotificationPrefView.NotificationPrefType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = NotificationPrefView.NotificationPrefType(rawValue: indexPath.row), let viewModel = self.viewModel else { return UITableViewCell() }
        let cell = tableView.dequeueCell(with: NotificationPrefTableViewCell.self)
        cell.configure(type: type, value: viewModel.getPref(type: type))
        cell.switchChanged = { [weak self] (isOn, prefType) in
            guard let viewModel = self?.viewModel else { return }
            viewModel.updatePref(type: prefType, value: isOn)
        }
        return cell
    }
}

extension NotificationPrefVC: NotificationPrefVMDelegate {
    
    func prefAPIResponse(responseType: Result<String, Error>) {
        switch responseType {
        case .success(let string):
            debugPrint(string)
            self.baseView.handleAPIResponse(.notificationPrefAPI, isSuccess: true, errorMsg: nil)
        case .failure(let string):
            self.baseView.handleAPIResponse(.notificationPrefAPI, isSuccess: false, errorMsg: string.localizedDescription)
        }
    }
}
