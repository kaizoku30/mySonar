//
//  DefaultAddressCell.swift
//  Kudu
//
//  Created by Admin on 13/07/22.
//

import UIKit

class DefaultAddressCell: UITableViewCell {
    @IBOutlet private weak var checkBoxImgView: UIImageView!
    @IBOutlet private weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
        label.text = LSCollection.AddNewAddress.setAsDefaultAddress
    }
    
    private var isDefault: Bool = false
    
    var defaultChoiceUpdated: ((Bool) -> Void)?
    
    private func initialSetup() {
        self.selectionStyle = .none
        checkBoxImgView.image = AppImages.AddAddress.checkBoxUnselected
        checkBoxImgView.isUserInteractionEnabled = true
        checkBoxImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleCheckBox)))
    }
    
    @objc private func toggleCheckBox() {
        debugPrint("OLD STATE")
        debugPrint(isDefault)
        isDefault = !isDefault
        debugPrint("NEW STATE")
        debugPrint(isDefault)
        checkBoxImgView.image = isDefault ? AppImages.AddAddress.checkBoxSelected :
        AppImages.AddAddress.checkBoxUnselected
        defaultChoiceUpdated?(isDefault)
    }
    
    func configure(isDefault: Bool, forcedDefault: Bool) {
        self.isDefault = isDefault
        checkBoxImgView.isUserInteractionEnabled = !forcedDefault
        checkBoxImgView.image = isDefault || forcedDefault ? AppImages.AddAddress.checkBoxSelected : AppImages.AddAddress.checkBoxUnselected
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
