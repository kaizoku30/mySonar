import AVFoundation
import UIKit

// MARK: - UIDEVICE
extension UIDevice {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
    static var bounds: CGRect {
        return UIScreen.main.bounds
    }
    
    static var size: CGSize {
        return UIScreen.main.bounds.size
    }
    
    static var height: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var bottomSafeArea: CGFloat {
        if #available(iOS 13.0, *) {
            return Router.shared.appWindow?.safeAreaInsets.bottom ?? 0.0
        }
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        }
        return 0.0
    }
    
    static var topSafeArea: CGFloat {
        if #available(iOS 13.0, *) {
            return Router.shared.appWindow?.safeAreaInsets.top ?? 0.0
        }
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0
        }
        return 0.0
    }
    
    static func vibrate() {
        let feedback = UIImpactFeedbackGenerator.init(style: UIImpactFeedbackGenerator.FeedbackStyle.heavy)
        feedback.prepare()
        feedback.impactOccurred()
    }
}
