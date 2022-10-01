//
//  NoInternetConnectionView.swift
//  Kudu
//
//  Created by Admin on 28/07/22.
//

import UIKit
import Reachability

class NoInternetConnectionView: UIView {

    @IBOutlet var mainContentView: UIView!
    @IBOutlet weak var errorSubTitleLabel: UILabel!
    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var tryAgainButton: AppButton!
    
    private let reachability = try? Reachability()
    
    @IBAction func tryAgain(_ sender: Any) {
        if reachability?.connection ?? .unavailable != .unavailable {
            NotificationCenter.postNotificationForObservers(.internetConnectionFound)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    private func commonInit() {
        Bundle.main.loadNibNamed("NoInternetConnectionView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        errorTitleLabel.font = AppFonts.mulishBold.withSize(16)
        errorSubTitleLabel.font = AppFonts.mulishSemiBold.withSize(16)
        localizationCall()
    }
    private func localizationCall() {
        errorTitleLabel.text = LocalizedStrings.NoInternetConnection.somethingWentWrong
        errorSubTitleLabel.text = LocalizedStrings.NoInternetConnection.pleaseCheckYourInternetconnection
        tryAgainButton.setTitle(LocalizedStrings.NoInternetConnection.tryAgain, for: .normal)
    }
}
