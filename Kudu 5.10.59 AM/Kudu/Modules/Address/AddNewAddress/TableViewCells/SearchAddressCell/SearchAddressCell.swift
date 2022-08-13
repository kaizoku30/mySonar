//
//  SearchAddressCell.swift
//  Kudu
//
//  Created by Admin on 13/07/22.
//

import UIKit

class SearchAddressCell: UITableViewCell {
    @IBOutlet private weak var containerView: UIView!
  //  @IBOutlet private weak var searchLocationTFView: AppTextFieldView!
    @IBOutlet private weak var searchLabel: UILabel!
    @IBOutlet private weak var searchFieldContainerView: UIView!
    @IBAction private func mapButtonPressed(_ sender: Any) {
        self.openMap?()
    }
    
    var openMap: (() -> Void)?
    var openAutocomplete: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
        searchLabel.text = LocalizedStrings.AddNewAddress.searchLocation
        searchLabel.textColor = AppColors.AddNewAddress.disabledTextColor
        // Initialization code
    }
    
    private func initialSetup() {
        self.selectionStyle = .none
        searchFieldContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped)))
    }
    
    func configure(address: String) {
        if address.isEmpty { searchLabel.text = LocalizedStrings.AddNewAddress.searchLocation; searchLabel.textColor = AppColors.AddNewAddress.disabledTextColor;  return}
        searchLabel.text = address
        searchLabel.textColor = .black
    }
    
    @objc private func containerTapped() {
        self.openAutocomplete?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
