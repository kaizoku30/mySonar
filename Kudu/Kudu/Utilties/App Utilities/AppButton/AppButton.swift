//
//  AppBottomActionBtn.swift
//  KUDU
//
//  Created by Admin on 05/01/22.
//

import UIKit
import NVActivityIndicatorView

class AppButton: UIButton {

    var handleBtnTap:(() -> Void)?
    private var enabledBgColor: UIColor = .clear
    private var enabledFontColor: UIColor = .clear
    private var activityIndicator: NVActivityIndicatorView?
    var isButtonHighlighted: Bool = false
    
    enum ButtonState {
        case enabled
        case disabled
    }
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupSubviews()
    }
    
    // MARK: Life Cycle Functions
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayouts()
    }
}

extension AppButton {
    private func setupSubviews() {
        self.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        enabledFontColor = self.titleLabel?.textColor ?? .clear
        enabledBgColor = self.backgroundColor ?? .clear
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 25, height: 25), type: .lineSpinFadeLoader, color: .white)
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator!)
        activityIndicator?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicator?.stopAnimating()
    }
    
    private func setupLayouts() {
        // Set corner radius update here dynamically if needed
    }
}

extension AppButton {
    func toggleButtonState(_ state: ButtonState, enabledTitle: String = "", disabledTitle: String = "") {
        if state == .enabled {
            if !enabledTitle.isEmpty {
                self.setTitle(enabledTitle, for: .normal)
            }
            self.isUserInteractionEnabled = true
            self.backgroundColor = AppColors.LoginScreen.selectedBgButtonColor
            self.setTitleColor(.white, for: .normal)
        } else {
            if !disabledTitle.isEmpty {
                self.setTitle(disabledTitle, for: .normal)
            }
            self.isUserInteractionEnabled = false
            self.backgroundColor = AppColors.LoginScreen.unselectedButtonBg
            self.setTitleColor(AppColors.LoginScreen.unselectedButtonTextColor, for: .normal)
        }
    }
}

extension AppButton {
    @objc private func buttonAction() {
        handleBtnTap?()
    }
}

extension AppButton {
    func startBtnLoader(color: UIColor = .white, small: Bool = false) {
        if small {
            activityIndicator?.height = 12.5
            activityIndicator?.width = 12.5
            self.layoutIfNeeded()
        }
        self.activityIndicator?.color = color
        self.activityIndicator?.startAnimating()
        self.setTitleColorForAllMode(color: .clear)
        self.isUserInteractionEnabled = false
    }
    
    func stopBtnLoader(titleColor: UIColor = .white) {
        self.activityIndicator?.stopAnimating()
        self.setTitleColorForAllMode(color: titleColor)
        self.isUserInteractionEnabled = true
    }
}
