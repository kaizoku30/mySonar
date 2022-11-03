//
//  CVVInfoVC.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit

class CVVInfoVC: BaseVC {
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var tapGestureView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBAction func okayButtonPressed(_ sender: Any) {
        dismissPopup?()
    }
    var dismissPopup: (() -> Void)?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.roundTopCorners(cornerRadius: 32)
        tapGestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapToDismiss)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardImageView.animationImages = AppGifs.cvvAnim.animationImages
        cardImageView.animationDuration = 1.5
        cardImageView.animationRepeatCount = Int.max
        cardImageView.startAnimating()
    }
    
    @objc private func tapToDismiss() {
        dismissPopup?()
    }
}
