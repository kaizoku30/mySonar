//
//  AppMediaPickerView.swift
//  Kudu
//
//  Created by Admin on 22/07/22.
//

import UIKit

class AppMediaPickerView: AppPopUpViewType {
    
    enum MediaFlow {
        case camera
        case gallery
    }
    
    @IBOutlet private var mainContentView: UIView!
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet private weak var leftButtonLabel: UILabel!
    @IBOutlet private weak var rightButtonLabel: UILabel!
    @IBOutlet private weak var leftBtnView: UIView!
    @IBOutlet private weak var rightBtnView: UIView!
    
    var handleAction: ((MediaFlow) -> Void)?
    @IBAction func dismissButtonPressed(_ sender: Any) {
        removeFromContainer()
    }
    
    static var Width: CGFloat { 288 }
    static var Height: CGFloat { 193 }
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("AppMediaPickerView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        [leftBtnView, rightBtnView].forEach({ $0?.isUserInteractionEnabled = true })
        leftBtnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftButtonTapped)))
        rightBtnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightButtonTapped)))
    }
    
    @objc private func leftButtonTapped() {
        self.handleAction?(.camera)
        removeFromContainer()
    }
    
    @objc private func rightButtonTapped() {
        self.handleAction?(.gallery)
        removeFromContainer()
    }
    
    @objc private func dimissSelf() {
        removeFromContainer()
    }
                                         
    private func removeFromContainer() {
        removeSelf()
    }
    
    func configure(container view: UIView) {
        self.containerView = view
        let dimmedView = UIView(frame: view.frame)
        dimmedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimissSelf)))
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        view.addSubview(dimmedView)
        self.tag = Constants.CustomViewTags.alertTag
        self.layoutIfNeeded()
        self.center = view.center
        view.addSubview(self)
    }

}
