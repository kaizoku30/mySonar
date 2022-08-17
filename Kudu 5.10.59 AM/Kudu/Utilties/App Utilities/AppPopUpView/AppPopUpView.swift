//
//  VIDAAlertView.swift
//  VIDA
//
//  Created by Admin on 21/02/22.
//

import UIKit

class AppPopUpView: UIView {

    enum AlertButton {
        case left
        case right
    }
    
    enum ButtonConfiguration {
        case gray
        case yellow
        case blueOutline
        
        var borderColor: UIColor {
            switch self {
            case .gray, .yellow:
                return UIColor.clear
            case .blueOutline:
                return AppColors.buttonBorderGrey
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .gray:
                return AppColors.LoginScreen.unselectedButtonBg
            case .yellow:
                return AppColors.kuduThemeYellow
            case .blueOutline:
                return AppColors.white
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .blueOutline:
                return 1
            default:
                return 0
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .blueOutline:
                return AppColors.kuduThemeBlue
            default:
                return .white
            }
        }
    }
    
    @IBOutlet private var mainContentView: UIView!
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet private weak var alertMessage: UILabel!
    @IBOutlet private weak var rightBtn: AppButton!
    @IBOutlet private weak var leftBtn: AppButton!
    private let titleFont = AppFonts.mulishBold.withSize(14)
    private let messageFont = AppFonts.mulishMedium.withSize(12)
    private weak var containerView: UIView?
    var handleAction: ((AlertButton) -> Void)?
    var rightButtonBgColor: UIColor = AppColors.kuduThemeYellow {
        didSet {
            rightBtn.backgroundColor = rightButtonBgColor
        }
    }
    static var HorizontalPadding: CGFloat { 2*28 }
    static var VerticalPadding: CGFloat { 24 + 12 + 24 + 40 + 20 }
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("AppPopUpView", owner: self, options: nil)
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
    
    func setButtonConfiguration(for button: AlertButton, config: ButtonConfiguration) {
        let button = button == .right ? rightBtn : leftBtn
        button?.borderColor = config.borderColor
        button?.borderWidth = config.borderWidth
        button?.backgroundColor = config.backgroundColor
        button?.setTitleColor(config.textColor, for: .normal)
    }
    
    func configure(title: String? = nil, message: String, leftButtonTitle: String, rightButtonTitle: String, container view: UIView) {
        self.containerView = view
        let dimmedView = UIView(frame: view.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        view.addSubview(dimmedView)
        self.tag = Constants.CustomViewTags.alertTag
        var titleHeight: CGFloat = 0
        if title.isNotNil {
            titleHeight = title!.heightOfText(alertTitle.width, font: titleFont)
        }
        let messageHegiht = message.heightOfText(alertMessage.width, font: messageFont)
        self.height = AppPopUpView.VerticalPadding + titleHeight + messageHegiht + 10
        self.layoutIfNeeded()
        self.center = view.center
        alertTitle.text = title
        alertMessage.text = message
        alertMessage.adjustsFontSizeToFitWidth = true
        leftBtn.setTitle(leftButtonTitle, for: .normal)
        rightBtn.setTitle(rightButtonTitle, for: .normal)
        view.addSubview(self)
    }

}
