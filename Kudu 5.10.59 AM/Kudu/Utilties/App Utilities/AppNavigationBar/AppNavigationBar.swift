//
//  AppNavigationBar.swift
//  KUDU
//
//  Created by Admin on 17/01/22.
//

import UIKit

enum NavigationButtons {
    case vidaLogo
    case leftBackChevron
    case shareTxtButton
    case previewTxtButton
    case crossDismiss
    case experienceFilterHome
    case saveTxtButton
    case locSave
    case locPin
    case locLike
    case locShare
    case locUnlike
    case none
    case saveCoverImage
    case updateTextButton
}

class AppNavigationBar: UIView {

    @IBOutlet var mainContentView: UIView!
    @IBOutlet weak var fourthRightImgButton: AppButton!
    @IBOutlet weak var thirdRightImgButton: AppButton!
    @IBOutlet weak var secondRightImgButton: AppButton!
    @IBOutlet weak var firstRightImgButton: AppButton!
    @IBOutlet weak var firstLeftButtonContainerView: UIView!
    @IBOutlet weak var secondBtnContainerView: UIView!
    @IBOutlet weak var firstBtnContainerView: UIView!
    @IBOutlet weak var firstLeftButton: AppButton!
    @IBOutlet weak var firstRightButton: AppButton!
    @IBOutlet weak var secondRightButton: AppButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var widthFirstIcon: NSLayoutConstraint!
    
    var navigationItemPressed: ((NavigationButtons) -> Void)?
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var titleFont: UIFont? {
        didSet {
            titleLabel.font = titleFont
        }
    }
    
    var buttons: [NavigationButtons] = [.vidaLogo] {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
        
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
}

extension AppNavigationBar {
    private func commonInit() {
        Bundle.main.loadNibNamed("AppNavigationBar", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // firstLeftButton.isUserInteractionEnabled = false
    }
    
    private func updateUI() {
        [firstRightImgButton, secondRightImgButton, thirdRightImgButton, fourthRightImgButton, firstRightButton, secondRightButton].forEach({$0?.isHidden = true})
        buttons.iteratorFunction({ [weak self] (index) in
                
            guard let navigatioBar = self else { return }
            
            switch index {
            case 0:
                navigatioBar.setButton(type: navigatioBar.buttons[0], buttonOutlet: navigatioBar.firstLeftButton, container: firstLeftButtonContainerView)
            case navigatioBar.buttons.count - 1 :
                navigatioBar.setButton(type: navigatioBar.buttons[navigatioBar.buttons.count - 1], buttonOutlet: navigatioBar.firstRightButton, container: firstBtnContainerView)
            case navigatioBar.buttons.count - 2 :
                navigatioBar.setButton(type: navigatioBar.buttons[navigatioBar.buttons.count - 2], buttonOutlet: navigatioBar.secondRightButton, container: secondBtnContainerView)
            case navigatioBar.buttons.count - 3 :
                navigatioBar.setButton(type: navigatioBar.buttons[navigatioBar.buttons.count - 3], buttonOutlet: navigatioBar.thirdRightImgButton)
            case navigatioBar.buttons.count - 4 :
                navigatioBar.setButton(type: navigatioBar.buttons[navigatioBar.buttons.count - 4], buttonOutlet: navigatioBar.fourthRightImgButton)
            default:
                break
            }
        })
    }
    
    private func setButton(type: NavigationButtons, buttonOutlet: AppButton, container: UIView? = nil) {
        widthFirstIcon.constant = 40
        buttonOutlet.isHidden = false
        buttonOutlet.alpha = 1
        buttonOutlet.layer.cornerRadius = 0
        container?.gestureRecognizers?.forEach({
            container?.removeGestureRecognizer($0)
        })
        // switch here on the basis of type
        debugPrint("Type is :\(type)")
    }
}

extension AppNavigationBar {
    
    @objc func previewTextPressed() {
        self.navigationItemPressed?(.previewTxtButton)
    }
    
    @objc func shareTextPressed() {
        self.navigationItemPressed?(.shareTxtButton)
    }
    
    @objc func saveTextPressed() {
        self.navigationItemPressed?(.saveTxtButton)
    }
    
    @objc func vidaLogoPressed() {
        self.navigationItemPressed?(.vidaLogo)
    }
    
    @objc func crossDismissPressed() {
        self.navigationItemPressed?(.crossDismiss)
    }
    
    @objc func leftChevronPressed() {
        self.navigationItemPressed?(.leftBackChevron)
    }
    
    @objc func saveCoverImagePressed() {
        self.navigationItemPressed?(.saveCoverImage)
    }
}

extension AppNavigationBar {
    func figmaShadowForRoundNavButtons(toView imageView: UIView) {
        imageView.layer.shadowRadius = 20
        imageView.layer.shadowOffset = .zero
        imageView.layer.shadowOpacity = 0.1
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowPath = UIBezierPath(rect: imageView.bounds).cgPath
        imageView.layer.masksToBounds = false
    }
}
