//
//  LanguageSelectionVC.swift
//  Kudu
//
//  Created by Admin on 10/05/22.
//

import UIKit
import LanguageManager_iOS

class LanguageSelectionVC: BaseVC {
    
    // MARK: Outlets
    @IBOutlet private weak var baseView: LanguageSelectionView!
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        handleActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        weak var weakSelf = self.navigationController as? BaseNavVC
        weakSelf?.disableSwipeBackGesture = true
    }
    
    // MARK: View Actions
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            guard let vc = self else { return }
            switch $0 {
            case .continueButtonPressed:
                Router.shared.goToTutorialVC(fromVC: vc, selectedLanguage: vc.baseView.currentLanguage)
            default:
                break
            }
        }
    }
}
