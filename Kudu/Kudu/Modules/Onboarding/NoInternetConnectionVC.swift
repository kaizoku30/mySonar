//
//  NoInternetConnectionVC.swift
//  Kudu
//
//  Created by Admin on 29/07/22.
//

import UIKit

class NoInternetConnectionVC: BaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeFor(.internetConnectionFound, selector: #selector(internetRetry))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view = NoInternetConnectionView(frame: self.view.frame)
    }
    
    @objc private func internetRetry() {
        DataManager.shared.setnoInternetViewAdded(false)
        self.popToSpecificViewController(kindOf: HomeVC.self)
    }
}
