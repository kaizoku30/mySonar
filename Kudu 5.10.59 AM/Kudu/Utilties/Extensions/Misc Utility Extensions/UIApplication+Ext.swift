import Foundation
import UIKit

extension UIApplication {

    ///Opens Settings app
    @nonobjc class var openSettingsApp: Void {

        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }

    ///Disables the ideal timer of the application
    @nonobjc class var disableApplicationIdleTimer: Void {
        self.shared.isIdleTimerDisabled = true
    }

    ///Enables the ideal timer of the application
    @nonobjc class var enableApplicationIdleTimer: Void {
        self.shared.isIdleTimerDisabled = false
    }

    ///Can get & set application icon badge number
    @nonobjc class var appIconBadgeNumber: Int {
        get {
          return UIApplication.shared.applicationIconBadgeNumber
        }
        set {
            UIApplication.shared.applicationIconBadgeNumber = newValue
        }
    }
}
