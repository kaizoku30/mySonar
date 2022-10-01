//
//  AddressOptionTableCell.swift
//  Kudu
//
//  Created by Admin on 19/07/22.
//

import UIKit

class AddressOptionTableCell: UITableViewCell {
    @IBOutlet weak var radioImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    private var isDefault = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    private func updateUI() {
        radioImgView.image = isDefault ? AppImages.AddAddress.radioSelected : AppImages.AddAddress.radioUnselected
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(item: MyAddressListItem) {
        self.isDefault = item.isDefault ?? false
        updateUI()
        let labelType = APIEndPoints.AddressLabelType.init(rawValue: item.addressLabel ?? "")
        switch labelType {
        case .HOME:
            titleLabel.text = "Home"
        case .WORK:
            titleLabel.text = "Work"
        default:
            titleLabel.text = item.otherAddressLabel ?? ""
        }
        let address = "\(item.buildingName ?? ""), \(item.cityName ?? ""), \(item.stateName ?? "")"
        addressLabel.text = address
    }
    
}
