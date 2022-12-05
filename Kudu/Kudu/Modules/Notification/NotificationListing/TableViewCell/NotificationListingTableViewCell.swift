//
//  TableViewCell.swift
//  Kudu
//
//  Created by Admin on 01/08/22.
//

import UIKit

class NotificationShimmerCell: UITableViewCell {
    @IBOutlet private weak var shimmerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerView.startShimmering()
    }
}

class NotificationListingTableViewCell: UITableViewCell {
    // MARK: IBOutlets.
    @IBOutlet private weak var notificationTitle: UILabel!
    @IBOutlet private weak var notificationSubtitle: UILabel!
    @IBOutlet private weak var notificationDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Private Functions.
    func configureCell(indexPath: IndexPath, data: NotificationList) {
        let lang = AppUserDefaults.selectedLanguage()
        notificationTitle.text = lang == .en ? data.subject : data.subjectAr
        notificationSubtitle.text = lang == .en ? data.description : data.descriptionAr
        let ts = data.created ?? 0
        let date = Date(timeIntervalSince1970: Double(ts)/1000)
        let uiTest = date.toString(dateFormat: Date.DateFormat.ddMMMyyyy.rawValue)
        notificationDate.text = uiTest
    }
}
