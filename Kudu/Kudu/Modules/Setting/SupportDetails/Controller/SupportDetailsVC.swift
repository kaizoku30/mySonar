//
//  SupportVC.swift
//  Kudu
//
//  Created by Admin on 19/07/22.
//

import UIKit

class SupportDetailsVC: BaseVC {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var baseView: SupportDetailsView!
    private let viewModel = SupportDetailsVM()
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    private func initialSetup() {
        baseView.showLoader(show: true)
        baseView.handleViewActions = { [weak self] (action) in
            mainThread {
                switch action {
                case .backButtonPressed:
                    self?.pop()
                case .mail:
                    self?.mail()
                case .call:
                    self?.call()
                }
            }
        }
        viewModel.delegate = self
        viewModel.getDetails()
    }

    private func call() {
        let mobileNo = self.viewModel.getDetailData?.contactNumber ?? ""
        if let url = NSURL(string: "tel://\(mobileNo)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL)
        }
    }
    
    private func mail() {
        let email = self.viewModel.getDetailData?.email ?? ""
        UIApplication.shared.open(URL(string: "mailto:\(email)")! as URL, options: [:], completionHandler: nil)
    }
}

extension SupportDetailsVC: SupportDetailsVMDelegate {
    func supportDetailsAPIResponse(responseType: Result<String, Error>) {
        mainThread {
            switch responseType {
            case .success(let message):
                debugPrint(message)
                self.baseView.showLoader(show: false)
                guard let data = self.viewModel.getDetailData else { return }
                self.baseView.showDetails(data: data)
            case .failure(let error):
                debugPrint(error.localizedDescription)
                self.baseView.showLoader(show: false)
                self.baseView.showErrorToast(message: error.localizedDescription)
            }
        }
    }
}
