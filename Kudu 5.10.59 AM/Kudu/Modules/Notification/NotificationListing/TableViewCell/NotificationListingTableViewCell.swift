//
//  TableViewCell.swift
//  Kudu
//
//  Created by Admin on 01/08/22.
//

import UIKit

class NotificationListingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var notificationDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //     contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
    }
}
