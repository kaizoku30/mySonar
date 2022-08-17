//
//  CustomizeCheckBoxItemCell.swift
//  Kudu
//
//  Created by Admin on 12/08/22.
//

import UIKit

class CustomizeCheckBoxItemCell: UITableViewCell {
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var checkBoxBtn: UIButton!
    
    var checkBoxFlag: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        itemNameLabel.font = AppFonts.mulishRegular.withSize(12)
        
    }

    @IBAction func checkBoxBtnPressed(_ sender: UIButton) {
        if !checkBoxFlag {
            checkBoxBtn.setImage(UIImage(named: "k_selectedCheckBox"), for: .normal)
            checkBoxFlag = !checkBoxFlag
            
        } else {
            checkBoxBtn.setImage(UIImage(named: "k_unselectedCheckBox"), for: .normal)
            checkBoxFlag = !checkBoxFlag
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
