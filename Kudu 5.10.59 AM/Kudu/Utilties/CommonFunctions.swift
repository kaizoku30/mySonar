//
//  CommonFunctions.swift
//  Kudu
//
//  Created by Admin on 02/05/22.
//

import Foundation

final class CommonFunctions {
    static func hideToast() {
        mainThread {
            NotificationCenter.default.removeObserver(SKToast.shared)
            SKToast.shared.statusLabel?.removeFromSuperview()
            SKToast.shared.statusLabel = nil
            SKToast.shared.toastView?.removeFromSuperview()
            SKToast.shared.toastView = nil
        }
        
    }
}
