//
//  SettingTableViewCell.swift
//  Kudu
//
//  Created by Admin on 19/07/22.
//

import UIKit
import NVActivityIndicatorView

class SettingTableViewCell: UITableViewCell {
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var settingName: UILabel!
    @IBOutlet weak var imageArrow: UIImageView!
    @IBOutlet weak var viewLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func toggleLoading(loading: Bool) {
            if loading {
                self.settingName.isHidden = true
                self.activityIndicator.startAnimating()
                self.activityIndicator.isHidden = false
            } else {
                stopLoading()
            }
    }
    
    private func stopLoading() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.stopAnimating()
        self.settingName.isHidden = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
