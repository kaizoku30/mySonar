import Foundation

extension BaseVC {
    func observeFor(_ type: Constants.NotificationObservers, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name.init(rawValue: type.rawValue), object: nil)
    }
}
extension NotificationCenter {
    static func postNotificationForObservers(_ type: Constants.NotificationObservers, object: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: type.rawValue), object: nil, userInfo: object)
    }
}
extension BaseTabBarVC {
    func observeFor(_ type: Constants.NotificationObservers, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name.init(rawValue: type.rawValue), object: nil)
    }
}

extension BaseNavVC {
    func observeFor(_ type: Constants.NotificationObservers, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name.init(rawValue: type.rawValue), object: nil)
    }
}
