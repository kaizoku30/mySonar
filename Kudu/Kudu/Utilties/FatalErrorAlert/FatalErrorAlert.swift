//
//  FatalErrorAlert.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import UIKit

func fatalErrorAlert(reason: String) -> UIAlertController {
    let alertVC = UIAlertController(title: "FATAL ERROR: Report to dev", message: reason, preferredStyle: .alert)
    let actionAlert = UIAlertAction(title: "Close App", style: .destructive, handler: { _ in
        fatalError()
    })
    alertVC.addAction(actionAlert)
    return alertVC
}
