//
//  NotificationPrefTableViewCell.swift
//  Kudu
//
//  Created by Admin on 10/08/22.
//

import UIKit

class NotificationPrefTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var preferenceSwitch: AppButton!
    
    @IBAction private func switchPressed(_ sender: Any) {
        isOn = !isOn
        preferenceSwitch.setImage(isOn ? AppImages.NotificationPref.switchSelected : AppImages.NotificationPref.switchUnselected, for: .normal)
        switchChanged?(isOn, self.type)
    }
    
    typealias PrefType = NotificationPrefView.NotificationPrefType
    private var isOn: Bool = true
    private var type: PrefType = .pushNotifications
    var switchChanged: ((Bool, PrefType) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configure(type: PrefType, value: Bool) {
        self.type = type
        titleLabel.text = type.title
        subtitleLabel.text = type.subtitle
        isOn = value
        preferenceSwitch.setImage(isOn ? AppImages.NotificationPref.switchSelected : AppImages.NotificationPref.switchUnselected, for: .normal)
    }
    
}
