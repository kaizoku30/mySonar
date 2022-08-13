//
//  TutorialPage3VC.swift
//  Kudu
//
//  Created by Admin on 13/06/22.
//

import UIKit

class TutorialPage3VC: BaseVC {
    // MARK: IBOutlets
    @IBOutlet private weak var pageControlView: UIImageView!
    @IBOutlet private weak var getStartedButton: UIButton!
    // MARK: Properties
    @IBAction func getStartedButtonPressed(_ sender: Any) {
        NotificationCenter.postNotificationForObservers(.endTutorialFlow)
    }
    var selectedLanguage: LanguageSelectionView.LanguageButtons = .english
    
    // MARK: View Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if selectedLanguage == .arabic {
            getStartedButton.setTitle("ابدأ", for: .normal)
        }
        if pageControlView.overlaps(other: getStartedButton, in: self) {
            pageControlView.isHidden = true
        }
    }
}
