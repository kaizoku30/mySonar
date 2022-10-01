import UIKit
import Kingfisher

extension UIButton {
    
    /// Method to add right image with offset
    ///
    /// - Parameter image: UIImage to set in button image.
    /// - Parameter offset: CGFloat space beetwen image and title.
    func addRightImage(image: UIImage?, offset: CGFloat) {
        self.setImage(image, for: .normal)
        self.setImage(image, for: .highlighted)
        self.imageView?.translatesAutoresizingMaskIntoConstraints = false
        self.imageView?.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0.0).isActive = true
        self.imageView?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -offset).isActive = true
    }
    
    /// Method to add left image on button
    ///
    /// - Parameter image: UIImage to set in button image.
    func adjustLeftImage(image: UIImage) {
        self.tintColor = .white
        self.setImage(image, for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: (self.center.x/4)-10, bottom: 0, right: 0)
        self.contentHorizontalAlignment = .center
    }
    
    ///  Method to add shadow on button
    /// - Parameter cornerRadius: CGFloat corner radius to apply on view.
    /// - Parameter color: UIColor to set in button title color.
    /// - Parameter offset: CGSize shadow size.
    /// - Parameter opacity: Float opacity of radius.
    /// - Parameter shadowRadius: CGFloat radius of shadow.
    func addShadowOnButton(cornerRadius: CGFloat? = nil, color: UIColor = AppColors.gray, offset: CGSize = CGSize.init(width: 1.0, height: 1.0), opacity: Float = 1.0, shadowRadius: CGFloat = 7.0) {
        let buttonRadius = cornerRadius.isNil ? self.frame.height/2 : (cornerRadius ?? CGFloat.zero)
        self.addShadow(cornerRadius: buttonRadius, color: color, offset: offset, opacity: opacity, shadowRadius: shadowRadius)
    }
    
    /// Method to revere position Of the title and image
    ///
    func reverePositionOfTitleAndImage() {
        self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    
    /// Method to sets the styled title to use for the normal, highlighted and selected state.
    ///
    /// - Parameter title: NSAttributedString to set in button title.
    ///
    func setAttributedTitleAllMode(title: NSAttributedString?) {
        self.setAttributedTitle(title, for: .normal)
        self.setAttributedTitle(title, for: .highlighted)
        self.setAttributedTitle(title, for: .selected)
    }
    
    /// Method to sets the title to use for the normal, highlighted and selected state.
    ///
    /// - Parameter title: String to set in button title.
    ///
    func setTitleForAllMode(title: String?) {
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .highlighted)
        self.setTitle(title, for: .selected)
        self.setTitle(title, for: .focused)
        self.setTitle(title, for: .application)
//        self.setTitle(title, for: .disabled)
    }
    
    /// Method to set the title color to use for the normal, highlighted and selected state
    ///
    /// - Parameter color: UIColor to set in button title color.
    ///
    func setTitleColorForAllMode(color: UIColor?) {
        self.setTitleColor(color, for: .normal)
        self.setTitleColor(color, for: .highlighted)
        self.setTitleColor(color, for: .selected)
        self.setTitleColor(color, for: .focused)
        self.setTitleColor(color, for: .application)
//        self.setTitleColor(color, for: .disabled)
    }
    
    /// Method to set the image to use for the normal, highlighted and selected state.
    ///
    /// - Parameter image: UIImage to set in button image.
    ///
    func setImageForAllMode(image: UIImage?) {
        self.setImage(image, for: .normal)
        self.setImage(image, for: .highlighted)
        self.setImage(image, for: .selected)
        self.setImage(image, for: .focused)
        self.setImage(image, for: .application)
//        self.setImage(image, for: .disabled)
    }
    
    func setFont(_ font: UIFont) {
        self.titleLabel?.font = font
    }
}
