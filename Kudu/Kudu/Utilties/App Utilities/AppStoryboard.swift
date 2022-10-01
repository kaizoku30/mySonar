import Foundation
import UIKit

enum AppStoryboard: String {
    case Onboarding
    case Home
    case Address
    case Setting
    case Notification
	case CartPayment
    case Coupon
}

extension AppStoryboard {

    var instance: UIStoryboard {

        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }

    func viewController<T: UIViewController>(_ viewControllerClass: T.Type) -> T {

        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID

        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {

            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue)")
        }

        return scene
    }

    func initialViewController() -> UIViewController? {

        return instance.instantiateInitialViewController()
    }
}

extension UIViewController {
    // Not using static as it wont be possible to override to provide custom storyboardID then
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(self)
    }
    
    class var storyboardID: String {
        return "\(self)"
    }
}
