//
//  LocationServicesDeniedView.swift
//  Kudu
//
//  Created by Admin on 19/07/22.
//

import UIKit

class LocationServicesDeniedView: UIView {
    
    enum AlertButton {
        case left
        case right
    }
    
    enum AlertType {
        case locationServicesNotWorking
        case locationPermissionDenied
        
        var message: String {
            switch self {
            case .locationServicesNotWorking:
                return "Turn On Location Services to allow KUDU to determine your current location."
            case .locationPermissionDenied:
                return "Allow KUDU to access your location to determine your current location."
            }
        }
        
        var title: String {
            switch self {
            case .locationServicesNotWorking:
                return "Location Services Off"
            case .locationPermissionDenied:
                return "Location Permission Denied"
            }
        }
    }
    
    @IBOutlet private var mainContentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var rightBtn: AppButton!
    @IBOutlet private weak var leftBtn: AppButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var handleAction: ((AlertButton) -> Void)?
    static var Height: CGFloat { 336 }
    static var Width: CGFloat { 308 }
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
        Bundle.main.loadNibNamed("LocationServicesDeniedView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        leftBtn.handleBtnTap = {
            [weak self] in
            self?.handleAction?(.left)
            self?.removeFromContainer()
        }
        rightBtn.handleBtnTap = {
            [weak self] in
            self?.handleAction?(.right)
            self?.removeFromContainer()
        }
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
    
    func configure(type: AlertType, leftButtonTitle: String, rightButtonTitle: String, container view: UIView) {
        self.containerView = view
        let dimmedView = UIView(frame: view.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        view.addSubview(dimmedView)
        self.tag = Constants.CustomViewTags.alertTag
        self.center = view.center
        messageLabel.numberOfLines = 3
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.text = type.message
        titleLabel.text = type.title
        leftBtn.setTitle(leftButtonTitle, for: .normal)
        rightBtn.setTitle(rightButtonTitle, for: .normal)
        view.addSubview(self)
    }
}
