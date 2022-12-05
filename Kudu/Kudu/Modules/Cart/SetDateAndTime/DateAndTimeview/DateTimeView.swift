//
//  DateTimeView.swift
//  Kudu
//
//  Created by Mohd Wasiq on 27/09/22.
//

import UIKit

class DateTimeView: UIView {

    @IBOutlet private weak var setDateAndTimeBtnOutlet: UIButton!
    @IBOutlet weak var setTimeLabel: UILabel!
    @IBOutlet weak var setDateLabel: UILabel!
    @IBOutlet private weak var viewOutlet: UIView!
    enum ViewAction {
        case calenderBtnPressed
        case timeClockBtnPressed
        case closeBtnPressed
        case setDeliveryDateTime
    }
    var handleViewActions: ((ViewAction) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.semanticContentAttribute = .forceLeftToRight
        viewOutlet.roundTopCorners(cornerRadius: 32)
    }
    
    func setDateLabel(text: String) {
        self.setDateLabel.text = text
        self.setDateLabel.textColor = .black
        if text.isEmpty {
            setDateLabel.text = "Set Date"
            setDateLabel.textColor = UIColor(r: 114, g: 114, b: 114, alpha: 0.6)
        }
    }
    
    func setTimeLabel(text: String) {
        self.setTimeLabel.text = text
        self.setTimeLabel.textColor = .black
        if text.isEmpty {
            setTimeLabel.text = "Set Time"
            setTimeLabel.textColor = UIColor(r: 114, g: 114, b: 114, alpha: 0.6)
        }
    }
    
    func enableSetDateTimeButton(enable: Bool) {
        setDateAndTimeBtnOutlet.backgroundColor = enable ? AppColors.kuduThemeYellow : AppColors.unselectedButtonBg
        setDateAndTimeBtnOutlet.setTitleColor(enable ? AppColors.white : AppColors.unselectedButtonTextColor, for: .normal)
    }
    
    @IBAction private func calenderBtnPressed(_ sender: UIButton) {
        handleViewActions?(.calenderBtnPressed)
    }
    
    @IBAction private func timeClockBtnPressed(_ sender: UIButton) {
        handleViewActions?(.timeClockBtnPressed)
    }
    @IBAction private func setDateAndTimeBtnPressed(_ sender: UIButton) {
        handleViewActions?(.setDeliveryDateTime)
    }
    @IBAction private func closeBtnPressed(_ sender: UIButton) {
        handleViewActions?(.closeBtnPressed)
    }
}
