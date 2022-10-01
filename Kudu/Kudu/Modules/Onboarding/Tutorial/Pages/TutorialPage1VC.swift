//
//  TutorialPage1VC.swift
//  Kudu
//
//  Created by Admin on 13/06/22.
//

import UIKit

class TutorialPage1VC: BaseVC {
    // MARK: IBOutlets
    @IBOutlet private weak var skipButton: UIButton!
    // MARK: IBActions
    @IBAction private func skipButtonPressed(_ sender: Any) {
        NotificationCenter.postNotificationForObservers(.endTutorialFlow)
    }
    // MARK: Properties
    var selectedLanguage: LanguageSelectionView.LanguageButtons = .english

    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedLanguage == .arabic {
            skipButton.setTitle("تخطي", for: .normal)
        }
    }
}
