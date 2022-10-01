//
//  LocationServicesDeniedView.swift
//  Kudu
//
//  Created by Admin on 19/07/22.
//

import UIKit

class SuccessAlertView: UIView {
    
    enum AlertType {
        case addressAdded
        case addressUpdated
        case couponAdded(couponCode: String)
        
        var message: String {
            switch self {
            case .addressAdded:
                return LocalizedStrings.MyAddress.addressAddedMessage
            case .addressUpdated:
                return LocalizedStrings.MyAddress.addressUpdatedMessage
            case .couponAdded(_):
                return "Coupon has been applied successfully"
            }
        }
        
        var title: String {
            switch self {
            case .addressAdded:
                return LocalizedStrings.MyAddress.addressAddedTitle
            case .addressUpdated:
                return LocalizedStrings.MyAddress.addressUpdatedTitle
            case .couponAdded(let couponCode):
                return "\(couponCode) Applied Successfully!"
            }
        }
    }
    
    @IBOutlet private var mainContentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var handleDismissal: (() -> Void)?
    static var Height: CGFloat { 251 }
    static var HorizontalPadding: CGFloat { 2*40 }
    private weak var containerView: UIView?
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SuccessAlertView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func removeFromContainer() {
        self.containerView?.subviews.forEach({
            if $0.tag == Constants.CustomViewTags.alertTag {
                $0.removeFromSuperview()
            }
        })
        self.containerView?.subviews.forEach({
            if $0.tag == Constants.CustomViewTags.dimViewTag {
                $0.removeFromSuperview()
            }
        })
    }
    
    func configure(type: AlertType, container view: UIView, displayTime: TimeInterval) {
        self.containerView = view
        let dimmedView = UIView(frame: self.containerView!.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        view.addSubview(dimmedView)
        self.tag = Constants.CustomViewTags.alertTag
        self.center = view.center
        messageLabel.numberOfLines = 3
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.text = type.message
        titleLabel.text = type.title
        view.addSubview(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + displayTime, execute: { [weak self] in
            self?.handleDismissal?()
            self?.removeFromContainer()
        })
    }
}
