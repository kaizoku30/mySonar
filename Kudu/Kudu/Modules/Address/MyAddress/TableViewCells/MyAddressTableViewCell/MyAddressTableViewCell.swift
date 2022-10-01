//
//  MyAddressTableViewCell.swift
//  Kudu
//
//  Created by Admin on 13/07/22.
//

import UIKit
//119 Height
class MyAddressTableViewCell: UITableViewCell {
    @IBOutlet weak var deleteButton: AppButton!
    @IBOutlet weak var editButton: AppButton!
    @IBOutlet private weak var bottomPadding: NSLayoutConstraint!
    @IBOutlet private weak var contentContainer: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    
    @IBAction private func editButtonPressed(_ sender: Any) {
        if let item = self.item {
            editAddress?(item)
        }
    }
    
    @IBAction private func deleteButtonPressed(_ sender: Any) {
        if let item = self.item {
            deleteAddress?(item)
        }
    }
    
    var deleteAddress: ((MyAddressListItem) -> Void)?
    var editAddress: ((MyAddressListItem) -> Void)?
    private var item: MyAddressListItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        editButton.setTitle(LocalizedStrings.MyAddress.edit, for: .normal)
        deleteButton.setTitle(LocalizedStrings.MyAddress.delete, for: .normal)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(item: MyAddressListItem) {
        mainThread { [weak self] in
            self?.bottomPadding.constant = (item.isDefault ?? false) == true ? 0 : 16
            self?.layoutIfNeeded()
        }
        self.item = item
        let labelType = APIEndPoints.AddressLabelType.init(rawValue: item.addressLabel ?? "")
        switch labelType {
        case .HOME:
            titleLabel.text = LocalizedStrings.AddNewAddress.home
        case .WORK:
            titleLabel.text = LocalizedStrings.AddNewAddress.work
        default:
            titleLabel.text = item.otherAddressLabel ?? ""
        }
        let address = "\(item.buildingName ?? ""), \(item.cityName ?? ""), \(item.stateName ?? "")"
        addressLabel.text = address
    }
    
}
