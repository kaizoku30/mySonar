//
//  TableViewCell.swift
//  OurStroreTableView
//
//  Created by Admin on 08/08/22.
//

import UIKit

class TableViewCell: UITableViewCell {

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
    
    func deliveryTitle(_ isDelivery : Bool) -> (String , UIColor ){
        if isDelivery {
            return ("Delivery available" , UIColor.green)
        }
        else {
            return ("Delivery unavailable", UIColor.red)
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
    
    func textSet( _ disName : String)  -> NSMutableAttributedString {
        let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "Futura", size: 14.0)! ]
        let myString = NSMutableAttributedString(string: disName, attributes: myAttribute )
        var loc = 0
        for (i,j) in disName.enumerated() {
            if j == "|" { loc = i + 1}
        }
        let myRange = NSRange(location: loc, length: disName.count - loc)
        myString.addAttribute(NSAttributedString.Key.foregroundColor,value: UIColor(named: "grrenCustom") , range: myRange)
        return myString
    }
}




