//
//  CommonFunctions.swift
//  Kudu
//
//  Created by Admin on 02/05/22.
//

import Foundation
import UIKit

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
    
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
   
}
