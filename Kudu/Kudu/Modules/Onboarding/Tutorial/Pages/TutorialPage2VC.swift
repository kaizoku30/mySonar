//
//  TutorialPage2VC.swift
//  Kudu
//
//  Created by Admin on 13/06/22.
//

import UIKit

class TutorialPage2VC: BaseVC {
    // MARK: IBOutlets
    @IBOutlet private weak var skipButton: UIButton!
    // MARK: IBActions
    @IBAction func skipButtonPressed(_ sender: Any) {
        NotificationCenter.postNotificationForObservers(.endTutorialFlow)
    }
    // MARK: Properties
    var selectedLanguage: LanguageSelectionView.LanguageButtons = .english
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedLanguage == .arabic {
            skipButton.setTitle("تخطي", for: .normal)
        }
    }
    
}
