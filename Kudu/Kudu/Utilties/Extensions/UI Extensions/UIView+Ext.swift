import Foundation
import UIKit
import AVFoundation

///Gradient Direction
enum GradientAlign {
    case horizontal
    case vertical
}

extension UIView {
    
    // Example use: myView.addBorder(toSide: .Left, withColor: UIColor.redColor().CGColor, andThickness: 1.0)
    
    enum ViewSide {
        case Left, Right, Top, Bottom
    }
    
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .Left:
            border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height)
        case .Right:
            border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height)
        case .Top:
            border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness)
        case .Bottom:
            border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness)
        }
        
        layer.addSublayer(border)
    }
}

// MARK: - UIView extension to create traingle
extension UIView {

    enum Border {
        case left
        case right
        case top
        case bottom
    }

    var width: CGFloat {
        get { return self.frame.size.width }
        set { self.frame.size.width = newValue }
    }
    var height: CGFloat {
        get { return self.frame.size.height }
        set { self.frame.size.height = newValue }
    }
    var top: CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }
    var right: CGFloat {
        get { return self.frame.origin.x + self.width }
        set { self.frame.origin.x = newValue - self.width }
    }
    var bottom: CGFloat {
        get { return self.frame.origin.y + self.height }
        set { self.frame.origin.y = newValue - self.height }
    }
    var left: CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }
    var centerX: CGFloat {
        get { return self.center.x }
        set { self.center = CGPoint(x: newValue, y: self.centerY) }
    }
    var centerY: CGFloat {
        get { return self.center.y }
        set { self.center = CGPoint(x: self.centerX, y: newValue) }
    }
    var origin: CGPoint {
        get { return self.frame.origin }
        set { self.frame.origin = newValue }
    }
    var size: CGSize {
        get { return self.frame.size }
        set { self.frame.size = newValue }
    }

    ///Returns the parent view controller ( if any ) of the view
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            parentResponder = responder.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    ///Adds the slope in view
    var addSlope: Void {

        // Make path to draw traingle
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()

        // Add path to the mask
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath

        self.layer.mask = mask

        // Adding shape to view's layer
        let shape = CAShapeLayer()
        shape.frame = self.bounds
        shape.path = path.cgPath
        shape.fillColor = UIColor.gray.cgColor

        self.layer.insertSublayer(shape, at: 1)
    }

    ///Sets the corner radius of the view
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    ///Sets the border width of the view
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

        ///Sets the border color of the view
        @IBInspectable var borderColor: UIColor? {
            get {
                let color = UIColor(cgColor: layer.borderColor!)
                return color
            }
            set {
                layer.borderColor = newValue?.cgColor
            }
        }

    ///Sets the shadow color of the view
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
        set {
            layer.shadowColor = newValue!.cgColor
        }
    }

    ///Sets the shadow opacity of the view
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    ///Sets the shadow offset of the view
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    ///Sets the circle shadow in the view
    func setCircleShadow(shadowRadius: CGFloat = 2,
                         shadowOpacity: Float = 0.3,
                         shadowColor: CGColor = UIColor.gray.cgColor,
                         shadowOffset: CGSize = CGSize.zero) {
        layer.cornerRadius = frame.size.height / 2
        layer.masksToBounds = false
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
    }

    ///Rounds the given corner based on the given radius
    func roundCorner(_ corner: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corner,
                                    cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }

    ///Rounds all the corners of the view
    func roundCorners() {
        roundCorner(.allCorners, radius: self.bounds.width/2.0)
    }

    func round() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = height/2
    }

    func round(radius: CGFloat) {
        self.layer.masksToBounds = true
        self.layoutIfNeeded()
        self.layer.cornerRadius = radius
    }

    func setBorder(width: CGFloat, color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    func setUnderline(border: UIView.Border, weight: CGFloat, color: UIColor ) {

        let lineView = UIView()
        addSubview(lineView)
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false

        switch border {

        case .left:
            lineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            lineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            lineView.widthAnchor.constraint(equalToConstant: weight).isActive = true

        case .right:
            lineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            lineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            lineView.widthAnchor.constraint(equalToConstant: weight).isActive = true

        case .top:
            lineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            lineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            lineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            lineView.heightAnchor.constraint(equalToConstant: weight).isActive = true

        case .bottom:
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            lineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            lineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            lineView.heightAnchor.constraint(equalToConstant: weight).isActive = true
        }
    }

    /// adds shadow in the view
    func drawShadow(shadowColor: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.798828125), shadowOpacity: Float = 0.14, shadowPath: UIBezierPath? = nil, shadowRadius: Float = 5, cornerRadius: Float = 6.0, offset: CGSize = CGSize(width: -1, height: 1)) {

        var shdwpath = shadowPath
        if shadowPath == nil {
            shdwpath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        }
        self.layer.masksToBounds = false
        self.layer.shadowColor  = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowPath   = shdwpath!.cgPath
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = CGFloat(shadowRadius)
        self.layer.cornerRadius = CGFloat(cornerRadius)
    }

    var globalPoint: CGPoint? {
        return self.superview?.convert(self.frame.origin, to: nil)
    }

    var globalFrame: CGRect? {
        return self.superview?.convert(self.frame, to: nil)
    }
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

/**
 A UIView extension that makes adding basic animations, like fades and bounces, simple.
 */
public extension UIView {

    /**
     Edge of the view's parent that the animation should involve
     - none: involves no edge
     - top: involves the top edge of the parent
     - bottom: involves the bottom edge of the parent
     - left: involves the left edge of the parent
     - right: involves the right edge of the parent
     */
    enum SimpleAnimationEdge {
        case none
        case top
        case bottom
        case left
        case right
    }

    /**
     Fades this view in. This method can be chained with other animations to combine a fade with
     the other animation, for instance:
     ```
     view.fadeIn().slideIn(from: .left)
     ```
     - Parameters:
     - duration: duration of the animation, in seconds
     - delay: delay before the animation starts, in seconds
     - completion: block executed when the animation ends
     */
    @discardableResult
    func fadeInOnView(duration: TimeInterval = 0.25, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) -> UIView {
        isHidden = false
        alpha = 0
        UIView.animate(
            withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
                self.alpha = 1
            }, completion: completion)
        return self
    }

    /**
     Fades this view out. This method can be chained with other animations to combine a fade with
     the other animation, for instance:
     ```
     view.fadeOut().slideOut(to: .right)
     ```
     - Parameters:
     - duration: duration of the animation, in seconds
     - delay: delay before the animation starts, in seconds
     - completion: block executed when the animation ends
     */
    @discardableResult
    func fadeOutOnView(duration: TimeInterval = 0.25, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) -> UIView {
            UIView.animate(
                withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
                    self.alpha = 0
                }, completion: completion)
            return self
        }

    /**
     Fades the background color of a view from existing bg color to a specified color without using alpha values.
     
     - Parameters:
     - toColor: the final color you want to fade to
     - duration: duration of the animation, in seconds
     - delay: delay before the animation starts, in seconds
     - completion: block executed when the animation ends
     */
    @discardableResult func fadeColor(toColor: UIColor = UIColor.red,
                                      duration: TimeInterval = 0.25,
                                      delay: TimeInterval = 0,
                                      completion: ((Bool) -> Void)? = nil) -> UIView {
        UIView.animate(
            withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
                self.backgroundColor = toColor
        }, completion: completion)
        return self
    }

    /**
     Slides this view into position, from an edge of the parent (if "from" is set) or a fixed offset
     away from its position (if "x" and "y" are set).
     - Parameters:
     - from: edge of the parent view that should be used as the starting point of the animation
     - x: horizontal offset that should be used for the starting point of the animation
     - y: vertical offset that should be used for the starting point of the animation
     - duration: duration of the animation, in seconds
     - delay: delay before the animation starts, in seconds
     - completion: block executed when the animation ends
     */
    @discardableResult func slideIn(from edge: SimpleAnimationEdge = .none,
                                    x: CGFloat = 0,
                                    y: CGFloat = 0,
                                    duration: TimeInterval = 0.4,
                                    delay: TimeInterval = 0,
                                    completion: ((Bool) -> Void)? = nil) -> UIView {
        let offset = offsetFor(edge: edge)
        transform = CGAffineTransform(translationX: offset.x + x, y: offset.y + y)
        isHidden = false
        UIView.animate(
            withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2,
            options: .curveEaseOut, animations: {
                self.transform = .identity
                self.alpha = 1
        }, completion: completion)
        return self
    }

    /**
     Slides this view out of its position, toward an edge of the parent (if "to" is set) or a fixed
     offset away from its position (if "x" and "y" are set).
     - Parameters:
     - to: edge of the parent view that should be used as the ending point of the animation
     - x: horizontal offset that should be used for the ending point of the animation
     - y: vertical offset that should be used for the ending point of the animation
     - duration: duration of the animation, in seconds
     - delay: delay before the animation starts, in seconds
     - completion: block executed when the animation ends
     */
    @discardableResult func slideOut(to edge: SimpleAnimationEdge = .none,
                                     x: CGFloat = 0,
                                     y: CGFloat = 0,
                                     duration: TimeInterval = 0.25,
                                     delay: TimeInterval = 0,
                                     completion: ((Bool) -> Void)? = nil) -> UIView {
        let offset = offsetFor(edge: edge)
        let endTransform = CGAffineTransform(translationX: offset.x + x, y: offset.y + y)
        UIView.animate(
            withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
                self.transform = endTransform
        }, completion: completion)
        return self
    }

    /**
     Moves this view into position, with a bounce at the end, either from an edge of the parent (if
     "from" is set) or a fixed offset away from its position (if "x" and "y" are set).
     - Parameters:
     - from: edge of the parent view that should be used as the starting point of the animation
     - x: horizontal offset that should be used for the starting point of the animation
     - y: vertical offset that should be used for the starting point of the animation
     - duration: duration of the animation, in seconds
     - delay: delay before the animation starts, in seconds
     - completion: block executed when the animation ends
     */
    @discardableResult func bounceIn(from edge: SimpleAnimationEdge = .none,
                                     x: CGFloat = 0,
                                     y: CGFloat = 0,
                                     duration: TimeInterval = 0.5,
                                     delay: TimeInterval = 0,
                                     completion: ((Bool) -> Void)? = nil) -> UIView {
        let offset = offsetFor(edge: edge)
        transform = CGAffineTransform(translationX: offset.x + x, y: offset.y + y)
        isHidden = false
        UIView.animate(
            withDuration: duration, delay: delay, usingSpringWithDamping: 0.58, initialSpringVelocity: 3,
            options: .curveEaseOut, animations: {
                self.transform = .identity
                self.alpha = 1
        }, completion: completion)
        return self
    }

    /**
     Moves this view out of its position, starting with a bounce. The view moves toward an edge of
     the parent (if "to" is set) or a fixed offset away from its position (if "x" and "y" are set).
     - Parameters:
     - to: edge of the parent view that should be used as the ending point of the animation
     - x: horizontal offset that should be used for the ending point of the animation
     - y: vertical offset that should be used for the ending point of the animation
     - duration: duration of the animation, in seconds
     - delay: delay before the animation starts, in seconds
     - completion: block executed when the animation ends
     */
    @discardableResult func bounceOut(to edge: SimpleAnimationEdge = .none,
                                      x: CGFloat = 0,
                                      y: CGFloat = 0,
                                      duration: TimeInterval = 0.35,
                                      delay: TimeInterval = 0,
                                      completion: ((Bool) -> Void)? = nil) -> UIView {
        let offset = offsetFor(edge: edge)
        let delta = CGPoint(x: offset.x + x, y: offset.y + y)
        let endTransform = CGAffineTransform(translationX: delta.x, y: delta.y)
        let prepareTransform = CGAffineTransform(translationX: -delta.x * 0.2, y: -delta.y * 0.2)
        UIView.animateKeyframes(
            withDuration: duration, delay: delay, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                    self.transform = prepareTransform
                }
                UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
                    self.transform = prepareTransform
                }
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                    self.transform = endTransform
                }
        }, completion: completion)
        return self
    }

    /**
     Moves this view into position, as though it were popping out of the screen.
     - Parameters:
     - fromScale: starting scale for the view, should be between 0 and 1
     - duration: duration of the animation, in seconds
     - delay: delay before the animation starts, in seconds
     - completion: block executed when the animation ends
     */
    @discardableResult func popIn(fromScale: CGFloat = 0.5,
                                  duration: TimeInterval = 0.5,
                                  delay: TimeInterval = 0,
                                  completion: ((Bool) -> Void)? = nil) -> UIView {
        isHidden = false
        alpha = 0
        transform = CGAffineTransform(scaleX: fromScale, y: fromScale)
        UIView.animate(
            withDuration: duration, delay: delay, usingSpringWithDamping: 0.55, initialSpringVelocity: 3,
            options: .curveEaseOut, animations: {
                self.transform = .identity
                self.alpha = 1
        }, completion: completion)
        return self
    }

    /**
     Moves this view out of position, as though it were withdrawing into the screen.
     - Parameters:
     - toScale: ending scale for the view, should be between 0 and 1
     - duration: duration of the animation, in seconds
     - delay: delay before the animation starts, in seconds
     - completion: block executed when the animation ends
     */
    @discardableResult func popOut(toScale: CGFloat = 0.5,
                                   duration: TimeInterval = 0.3,
                                   delay: TimeInterval = 0,
                                   completion: ((Bool) -> Void)? = nil) -> UIView {
        let endTransform = CGAffineTransform(scaleX: toScale, y: toScale)
        let prepareTransform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animateKeyframes(
            withDuration: duration, delay: delay, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                    self.transform = prepareTransform
                }
                UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.3) {
                    self.transform = prepareTransform
                }
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                    self.transform = endTransform
                    self.alpha = 0
                }
        }, completion: completion)
        return self
    }

    private func offsetFor(edge: SimpleAnimationEdge) -> CGPoint {
        if let parentSize = self.superview?.frame.size {
            switch edge {
            case .none: return CGPoint.zero
            case .top: return CGPoint(x: 0, y: -frame.maxY)
            case .bottom: return CGPoint(x: 0, y: parentSize.height - frame.minY)
            case .left: return CGPoint(x: -frame.maxX, y: 0)
            case .right: return CGPoint(x: parentSize.width - frame.minX, y: 0)
            }
        }
        return .zero
    }

    func shakeView() {
        let keyFrame = CAKeyframeAnimation(keyPath: "position")
        let point = self.layer.position
        keyFrame.values = [NSValue(cgPoint: CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x - 10), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x + 10), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x - 10), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x + 10), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x - 10), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x + 10), y: CGFloat(point.y))),
                           NSValue(cgPoint: point)]

        keyFrame.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        keyFrame.duration = 0.7
        self.layer.position = point
        self.layer.add(keyFrame, forKey: keyFrame.keyPath)
    }
    
    /// Method to make a view circular
    func makeCircular(borderWidth: CGFloat = 0.0, borderColor: UIColor = .clear) {
        self.cropCorner(radius: self.frame.size.height / 2.0, borderWidth: borderWidth, borderColor: borderColor)
    }
    
    /// Method to give corner a view
    func cropCorner(radius: CGFloat, borderWidth: CGFloat = 0.0, borderColor: UIColor = .clear) {
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.masksToBounds = true
    }
    
    func addShadow(cornerRadius: CGFloat, maskedCorners: CACornerMask = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], color: UIColor, offset: CGSize, opacity: Float, shadowRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = maskedCorners
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = shadowRadius
    }
    
    func dropShadow(scale: Bool = true, color: UIColor = .black) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func makeRoundToCorner(cornerRadius: CGFloat, maskedCorners: CACornerMask = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = maskedCorners
    }
    
    func roundTopCorners(cornerRadius: CGFloat) {
        self.clipsToBounds = true
        self.addShadow(cornerRadius: cornerRadius, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], color: .clear, offset: .zero, opacity: 0.0, shadowRadius: 0.0)
    }
    
    func roundBottomCorners(cornerRadius: CGFloat) {
        self.clipsToBounds = true
        self.addShadow(cornerRadius: cornerRadius, maskedCorners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], color: .clear, offset: .zero, opacity: 0.0, shadowRadius: 0.0)
    }
    
    func roundLeftCorners(cornerRadius: CGFloat) {
        self.clipsToBounds = true
        self.addShadow(cornerRadius: cornerRadius, maskedCorners: [.layerMinXMinYCorner, .layerMinXMaxYCorner], color: .clear, offset: .zero, opacity: 0.0, shadowRadius: 0.0)
    }
    
    func roundRightCorners(cornerRadius: CGFloat) {
        self.clipsToBounds = true
        self.addShadow(cornerRadius: cornerRadius, maskedCorners: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner], color: .clear, offset: .zero, opacity: 0.0, shadowRadius: 0.0)
    }

}

extension UIView {

    var getCollectionView: UICollectionView? {

        var subviewClass = self

        while !(subviewClass is UICollectionView) {

            guard let view = subviewClass.superview else { return nil }

            subviewClass = view
        }
        return subviewClass as? UICollectionView
    }

    var getTableView: UITableView? {

        var subviewClass = self

        while !(subviewClass is UITableView) {

            guard let view = subviewClass.superview else { return nil }

            subviewClass = view
        }
        return subviewClass as? UITableView
    }

    var tableViewCell: UITableViewCell? {

        var subviewClass = self

        while !(subviewClass is UITableViewCell) {

            guard let view = subviewClass.superview else { return nil }

            subviewClass = view
        }
        return subviewClass as? UITableViewCell
    }

    func tableViewIndexPath(_ tableView: UITableView) -> IndexPath? {

        if let cell = self.tableViewCell {

            return tableView.indexPath(for: cell)

        }
        return nil
    }

    var collectionViewCell: UICollectionViewCell? {

        var subviewClass = self

        while !(subviewClass is UICollectionViewCell) {

            guard let view = subviewClass.superview else { return nil }

            subviewClass = view
        }

        return subviewClass as? UICollectionViewCell
    }

    func collectionViewIndexPath(_ collectionView: UICollectionView) -> IndexPath? {

        if let cell = self.collectionViewCell {

            return collectionView.indexPath(for: cell)

        }
        return nil
    }
}
//sanju
extension UIView {
    func pushTransition(_ duration: CFTimeInterval) {
        let animation: CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromBottom
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.push.rawValue)
    }
}

extension UIView {
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let img = image else {
            return UIImage()
        }
        return img
    }
    func applyGradient(colours: [UIColor]) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.locations = [0.1, 0.9]
        self.layer.insertSublayer(gradient, at: 0)
    }
    func setGradientBorder(firstColor: UIColor, secondColor: UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
        gradient.colors = [firstColor.cgColor, secondColor.cgColor]
        
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(rect: self.bounds).cgPath
        shape.strokeColor = AppColors.black.cgColor
        shape.fillColor = AppColors.clear.cgColor
        gradient.mask = shape
        
        self.layer.addSublayer(gradient)
    }
}

// for chat
public extension UIView {
    
    class var nibName: String {
        let name = "\(self)".components(separatedBy: CommonStrings.dot).first ?? CommonStrings.emptyString
        return name
    }
    class var nib: UINib? {
        if Bundle.main.path(forResource: nibName, ofType: "nib") != nil {
            return UINib(nibName: nibName, bundle: nil)
        } else {
            return nil
        }
    }
}
extension UIView {
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: CommonStrings.dot).last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}

extension UIView {
    
    ///Add Gradient
    func addGradient(alignCase: GradientAlign = GradientAlign.vertical, colorArray: [CGColor] = [UIColor.colorRGB(r: 0, g: 0, b: 0, alpha: 0.9).cgColor,
                                                                                                 UIColor.colorRGB(r: 0, g: 0, b: 0, alpha: 0.25).cgColor,
                                                                                                 UIColor.colorRGB(r: 0, g: 0, b: 0, alpha: 0.0).cgColor,
                                                                                                 UIColor.colorRGB(r: 0, g: 0, b: 0, alpha: 0.0).cgColor,
                                                                                                 UIColor.colorRGB(r: 0, g: 0, b: 0, alpha: 0.25).cgColor,
                                                                                                 UIColor.colorRGB(r: 0, g: 0, b: 0, alpha: 0.5).cgColor,
                                                                                                 UIColor.colorRGB(r: 0, g: 0, b: 0, alpha: 1.0).cgColor]) {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.startPoint = CGPoint.zero
        gradient.endPoint =  CGPoint(x: 0, y: 1)
        if alignCase == GradientAlign.horizontal {
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint =  CGPoint(x: 1, y: 0)
        }
        
        gradient.frame = self.bounds
        gradient.colors = colorArray
        
        // Test Code for Mesh Gradient issue
        self.layer.sublayers?.forEach({ (layer) in
            if layer.isKind(of: CAGradientLayer.self) {
                layer.removeFromSuperlayer()
            }
        })
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func addGradientWithLocations(locations: [NSNumber] = [0.0, 1.0], colors: [CGColor] = [UIColor.clear.cgColor, UIColor.black.cgColor]) {
        let gradient: CAGradientLayer = CAGradientLayer()
        CATransaction.begin()
        gradient.frame = self.superview?.bounds ?? .null
        gradient.colors = colors
        gradient.locations = locations
        self.superview?.layer.mask = gradient
        self.backgroundColor = .clear
        self.superview?.isOpaque = false
        CATransaction.commit()

    }
    
    func animateZoomBouncingIn() {
        self.transform = self.transform.scaledBy(x: 0.001, y: 0.001)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
        }, completion: nil)
        
    }
    
    func animateView(view: UIView, hideStatus: Bool) {
        //           self.frame = CGRect(x: self.frame.origin.x, y: self.frame.y + 100, width: self.frame.width, height: self.frame.height)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: {
                if hideStatus {
                    //                    self.frame = CGRect(x: self.frame.origin.x, y: self.frame.y + 100, width: self.frame.width, height: self.frame.height)
                    self.alpha = 0.0
                } else {
                    //                    self.frame = CGRect(x: self.frame.origin.x, y: self.frame.y - 100, width: self.frame.width, height: self.frame.height)
                    self.alpha = 1.0
                    
                }
                //                self.isHidden = hideStatus
                view.layoutIfNeeded()
        },
            completion: nil
        )
    }
    
    func slideY(y: CGFloat) {
        
        let xPosition = self.frame.origin.x
        
        let height = self.frame.height
        let width = self.frame.width
        
        UIView.animate(withDuration: 0.33, animations: {
            self.frame = CGRect(x: xPosition, y: y, width: width, height: height)
        })
    }
    
    /// SHOW VIEW
    func showViewWithFade(withDuration: TimeInterval = 0.5) {
        self.alpha = 0.0
        UIView.animate(withDuration: withDuration, animations: { [weak self] in
            guard let sSelf = self else { return }
            sSelf.alpha = 0.0
            }, completion: { [weak self] (_: Bool) -> Void in
                guard let sSelf = self else { return }
                sSelf.alpha = 1.0
                CATransaction.begin()
                let transition = CATransition()
                transition.duration = withDuration
                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                transition.type = CATransitionType.fade
                sSelf.layer.add(transition, forKey: nil)
                sSelf.isHidden = false
                CATransaction.commit()
        })
    }
    
    /// HIDE VIEW
    func hideViewWithFade(withDuration: TimeInterval = 0.5) {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1.0
        }, completion: { (_: Bool) -> Void in
            self.alpha = 0.0
            CATransaction.begin()
            let transition = CATransition()
            transition.duration = withDuration
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.fade
            self.layer.add(transition, forKey: nil)
            self.isHidden = true
            CATransaction.commit()
        })
    }
}

extension UIView {
  func addTopBorderWithColor(color: UIColor, height: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: height)
    self.layer.addSublayer(border)
  }

  func addRightBorderWithColor(color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
    self.layer.addSublayer(border)
  }

  func addBottomBorderWithColor(color: UIColor, height: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: self.frame.size.height - height, width: self.frame.size.width, height: height)
    self.layer.addSublayer(border)
  }

  func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
    self.layer.addSublayer(border)
  }
    
    ///Adds Child View Controller to Parent View Controller
    func add(childViewController: UIViewController) {
        self.parentViewController?.addChild(childViewController)
        childViewController.view.frame = self.bounds
        self.addSubview(childViewController.view)
        childViewController.didMove(toParent: self.parentViewController)
    }
}

extension UIStackView {
    func setBackgroundColor(_ color: UIColor) {
        let backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = color
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(backgroundView, at: 0)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
    }
    
    func fillSuperview(padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewTopAnchor = superview?.topAnchor {
            topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
        }
        
        if let superviewBottomAnchor = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
        }
        
        if let superviewLeadingAnchor = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
        }
        
        if let superviewTrailingAnchor = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
        }
    }
    
    func fillWithView(view: UIView, padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.bottom).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.right).isActive = true
    }
    
    func centerInSuperview(size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
        
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
        
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
    
}

extension UIView {
    
    func fadeIn(_ duration: TimeInterval = 0.33, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration,
                       animations: { self.alpha = 1 },
                       completion: { _ in
                        if let complete = onCompletion { complete() }
        })
    }
    
    func fadeOut(_ duration: TimeInterval = 0.33, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       animations: { self.alpha = 0 },
                       completion: { _ in
                        self.isHidden = true
            if let complete = onCompletion {
                complete() }
        })
    }
    
}

extension UIView {
    func overlaps(other view: UIView, in viewController: UIViewController) -> Bool {
        let frame = self.convert(self.bounds, to: viewController.view)
        let otherFrame = view.convert(view.bounds, to: viewController.view)
        return frame.intersects(otherFrame)
    }
    
    func overlaps(other view: UIView, in containerView: UIView) -> Bool {
        let frame = self.convert(self.bounds, to: containerView)
        let otherFrame = view.convert(view.bounds, to: containerView)
        return frame.intersects(otherFrame)
    }
    
    func distanceFromBottomToTheTopOfUIView(_ view: UIView, in viewController: UIViewController) -> CGFloat {
        let frame = self.convert(self.bounds, to: viewController.view)
        let otherFrame = view.convert(view.bounds, to: viewController.view)
        return otherFrame.minY - frame.maxY
    }
    
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIView {
    func animateWithKeyboard(
        notification: NSNotification,
        animations: ((_ keyboardFrame: CGRect) -> Void)?
    ) {
        // Extract the duration of the keyboard animation
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let duration = notification.userInfo![durationKey] as! Double
        
        // Extract the final frame of the keyboard
        let frameKey = UIResponder.keyboardFrameEndUserInfoKey
        let keyboardFrameValue = notification.userInfo![frameKey] as! NSValue
        
        // Extract the curve of the iOS keyboard animation
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
        let curveValue = notification.userInfo![curveKey] as! Int
        let curve = UIView.AnimationCurve(rawValue: curveValue)!

        // Create a property animator to manage the animation
        let animator = UIViewPropertyAnimator(
            duration: duration,
            curve: curve
        ) {
            // Perform the necessary animation layout updates
            animations?(keyboardFrameValue.cgRectValue)
            
            // Required to trigger NSLayoutConstraint changes
            // to animate
            self.layoutIfNeeded()
        }
        
        // Start the animation
        animator.startAnimation()
    }
}
