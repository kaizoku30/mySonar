//
//  TableViewCell.swift
//  OurStroreTableView
//
//  Created by Admin on 08/08/22.
//

import UIKit

class OurStoreItemTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var storeName: UILabel!
    @IBOutlet private weak var distanceLbl: UILabel!
    @IBOutlet private weak var storeAddress: UILabel!
    @IBOutlet private weak var deliveryAvailability: UILabel!
    @IBOutlet weak var imageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        storeName.font = AppFonts.mulishBold.withSize(14)
        storeAddress.font = AppFonts.mulishRegular.withSize(10)
        deliveryAvailability.font = AppFonts.mulishBold.withSize(10)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func deliveryTitle(_ isDelivery: Bool) -> (String, UIColor ) {
        if isDelivery {
            return (LocalizedStrings.OurStore.DeliveryAvailable, AppColors.OurStore.deliveryAvailable)
        } else {
            return (LocalizedStrings.OurStore.DeliveryUnavailable, AppColors.OurStore.deliveryUnavailable)
        }
    }
    
    func configure(_ data: AllData) {
        storeName.text = data.storeName
        distanceLbl.attributedText = textSet(data.distance)
        storeAddress.text = data.storeAddress
      //  deliveryAvailability.text = deliveryTitle(data.isDelivery).0
        imageLabel.isHidden = data.statusView
       // deliveryAvailability.textColor = deliveryTitle(data.isDelivery).1
        
    }
    
    func textSet (_ disName: String) -> NSMutableAttributedString {
        let myAttribute = [ NSAttributedString.Key.font:  AppFonts.mulishBold.withSize(10) ]
        let myString = NSMutableAttributedString(string: disName, attributes: myAttribute )
        var loc = 0
        for (i, j) in disName.enumerated() {
            if j == "|" {loc = i + 1}
        }
        let myRange = NSRange(location: loc, length: disName.count - loc)
        myString.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColors.OurStore.timeLblColor, range: myRange)
        return myString
    }
}
