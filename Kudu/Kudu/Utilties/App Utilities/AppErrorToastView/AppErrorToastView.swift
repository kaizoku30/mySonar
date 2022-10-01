//
//  AppErrorToastView.swift
//  Kudu
//
//  Created by Admin on 27/06/22.
//

import UIKit

class AppErrorToastView: UIView {
    @IBOutlet private weak var mainContentView: UIView!
    @IBOutlet private weak var errorLabel: UILabel!
    private var toastVisible = false
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
        
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("AppErrorToastView", owner: self, options: nil)
        addSubview(mainContentView)
        self.isHidden = true
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.transform = CGAffineTransform(translationX: 0, y: -200)
    }
    
	func show(message: String, view: UIView, extraDelay: TimeInterval? = nil, completionBlock: (() -> Void)? = nil) {
        if DataManager.shared.showingToast { return }
        view.addSubview(self)
        DataManager.shared.showingToast = true
        self.center.x = view.center.x
        let textHeight = message.heightOfText(UIScreen.main.bounds.width - 32, font: AppFonts.mulishMedium.withSize(14))
        errorLabel.text = message
        self.isHidden = false
        self.height = textHeight + 40
        self.errorLabel.sizeToFit()
        self.setNeedsLayout()
        self.layoutIfNeeded()
        UIView.animate(withDuration: 1, animations: {
            if !self.toastVisible {
                self.transform = CGAffineTransform(translationX: 0, y: 40)
                self.toastVisible = true
            }
        }, completion: {
            if $0 {
                var delay: TimeInterval = 1
                if extraDelay.isNotNil {
                    delay += extraDelay!
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
					self.hideErrorToast(completionBlock: {
						completionBlock?()
					})
                })
            }
        })
        
    }
    
    private func hideErrorToast(completionBlock: (() -> Void)? = nil) {
        if !toastVisible {
            return
        }
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -200)
        }, completion: { _ in
            self.isHidden = true
            DataManager.shared.showingToast = false
            self.toastVisible = false
			completionBlock?()
        })
    }
}
