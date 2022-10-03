//
//  CameraPermissionDeniedView.swift
//  Kudu
//
//  Created by Admin on 19/07/22.
//

import UIKit

class CameraPermissionDeniedView: AppPopUpViewType {
    
    enum AlertButton {
        case left
        case right
    }
    
    enum AlertType {
        case noGallery
        case noCamera
        
        var message: String {
            switch self {
            case .noGallery:
                return "Allow KUDU to access photos and media  on your mobile"
            case .noCamera:
                return "Allow KUDU to access your camera"
            }
        }
        
        var title: String {
            switch self {
            case .noGallery:
                return "Allow Gallery"
            case .noCamera:
                return "Allow Camera"
            }
        }
    }
    
    @IBOutlet private var mainContentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var rightBtn: AppButton!
    @IBOutlet private weak var leftBtn: AppButton!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    var handleAction: ((AlertButton) -> Void)?
    static var popUpHeight: CGFloat { 318 }
    static var popUpWidth: CGFloat { 308 }
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CameraPermissionDeniedView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        handleButtonTap()
    }
    
    private func removeFromContainer() {
        removeSelf()
    }
    
    private func handleButtonTap() {
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
    
    func configure(type: AlertType, leftButtonTitle: String, rightButtonTitle: String, container view: UIView) {
        self.containerView = view
        self.imageView.image = type == .noCamera ? AppImages.SendFeedback.cameraPermissionDenied : AppImages.SendFeedback.galleryPermissionDenied
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
