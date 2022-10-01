import UIKit

extension UIScrollView {
    
    /// Method to scroll to top
    /// - Parameter animated: Bool value which determine whether animated or not
    func scrollToTop(animated: Bool = true) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }

    /// Method to scroll to bottom
    /// - Parameter animated: Bool value which determine whether animated or not
    func scrollToBottom() {
        guard contentSize.height > bounds.height else { return }
        let offSetToSet = contentSize.height - (bounds.height + contentOffset.y)
        guard offSetToSet > 0 else { return }
        UIView.animate(withDuration: 0.5) {[weak self] in
            guard let self = self else { return }
            self.contentOffset = CGPoint(x: 0, y: offSetToSet + self.contentOffset.y)
        } completion: { _ in
            self.layoutIfNeeded()
        }
    }
    
    /// Method to scroll up to height
    /// - Parameters:
    ///   - height: height value for scroll
    ///   - animated: Bool value which determine whether animated or not
    func scrollUpToHeight(height: CGFloat, animated: Bool = true) {
        let bottomOffset = CGPoint(x: 0, y: height)
        setContentOffset(bottomOffset, animated: animated)
    }
    
    /// Method to scroll to right
    /// - Parameter animated: Bool value which determine whether animated or not
    func scrollToRight(animated: Bool = true) {
        let toSetContentOffset = CGPoint.init(x: self.contentSize.width - self.width, y: 0.0)
        self.setContentOffset(toSetContentOffset, animated: animated)
    }
    
    /// Scroll to a specific view so that it's top is at the top our scrollview
    /// - Parameters:
    ///   - view: view on which we scroll
    ///   - animated: Bool value which determine whether animated or not
    func scrollToView(view: UIView, animated: Bool = true) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x: 0, y: childStartPoint.y, width: 1, height: self.frame.height), animated: animated)
        }
    }
    
    func pauseScrolling() {
        let contentOffset = self.contentOffset
        self.setContentOffset(contentOffset, animated: false)
    }
}
