//
//  RepeatCustomisationView.swift
//  Kudu
//
//  Created by Admin on 25/08/22.
//
import UIKit

class RepeatCustomisationView: UIView {
    enum AlertButton {
        case repeatCustomisation
        case newCustomisation
    }
    
    @IBAction private func dismissButtonPressed(_ sender: Any) {
        self.removeFromContainer()
    }
    
    @IBOutlet private var mainContentView: UIView!
    @IBOutlet private weak var alertTitle: UILabel!
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
    static var VerticalPadding: CGFloat { 8 + 32 + 8 + 20 + 18 + 40 + 16}
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RepeatCustomisationView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        leftBtn.handleBtnTap = {
            [weak self] in
            self?.handleAction?(.repeatCustomisation)
            self?.removeFromContainer()
        }
        rightBtn.handleBtnTap = {
            [weak self] in
            self?.handleAction?(.newCustomisation)
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
    
    func configure(container view: UIView) {
        self.containerView = view
        let dimmedView = UIView(frame: view.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        view.addSubview(dimmedView)
        self.tag = Constants.CustomViewTags.alertTag
        let title = self.alertTitle.text
        let message = self.alertMessage.text ?? ""
//      var titleHeight: CGFloat = 0
//        if title.isNotNil {
//            titleHeight = title!.heightOfText(alertTitle.width, font: titleFont)
//        }
//        let messageHeight = message.heightOfText(alertMessage.width, font: messageFont)
        self.height = 212//AppPopUpView.VerticalPadding + titleHeight + messageHeight + 10
        self.layoutIfNeeded()
        self.center = view.center
        alertTitle.text = title
        alertMessage.text = message
        alertMessage.adjustsFontSizeToFitWidth = true
        view.addSubview(self)
    }
}
