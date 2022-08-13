//
//  TableViewCell.swift
//  OurStroreTableView
//
//  Created by Admin on 08/08/22.
//

import UIKit

class StoreTableViewCell: UITableViewCell {

    @IBOutlet private weak var storeName: UILabel!
    @IBOutlet private weak var distanceLbl: UILabel!
    @IBOutlet private weak var storeAddress: UILabel!
    @IBOutlet private weak var deliveryAvailability: UILabel!
    @IBOutlet weak var imageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ data: AllData) {
        storeName.text = data.storeName
        distanceLbl.attributedText = textSet(data.distance)
        storeAddress.text = data.storeAddress
        deliveryAvailability.text = data.delivery
        imageLabel.isHidden = data.statusView
        
    }
    
    func textSet( _ disName : String)  -> NSMutableAttributedString {
        let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "Futura", size: 14.0)! ]
        let myString = NSMutableAttributedString(string: disName, attributes: myAttribute )
        var loc = 0
        for (i,j) in disName.enumerated() {
            if j == "|" { loc = i + 1}
        }
        let myRange = NSRange(location: loc, length: disName.count - loc)
        myString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "grrenCustom"), range: myRange)
        return myString
    }

    

}



