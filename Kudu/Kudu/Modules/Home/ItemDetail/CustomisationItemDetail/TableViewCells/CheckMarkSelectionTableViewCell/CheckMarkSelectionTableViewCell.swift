//
//  CheckMarkSelectionTableViewCell.swift
//  Kudu
//
//  Created by Admin on 24/08/22.
//

import UIKit
import Kingfisher

class CheckMarkSelectionTableViewCell: UITableViewCell {
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet weak var modifierImgView: UIImageView!
    @IBOutlet private weak var modifierTitleLabel: UILabel!
    @IBOutlet private weak var selectedButton: AppButton!
    
    @IBAction private func selectionTapped(_ sender: Any) {
        let newState = !(self.modifier.addedToTemplate ?? false)
		if allowAddingMore == false && newState == true { return }
        checkMarkPressed?(newState, modifier._id ?? "", modGroupId)
    }
    
    private var modifier: ModifierObject!
    private var modGroupId: String!
	private var allowAddingMore = true
    var checkMarkPressed: ((Bool, String, String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
	func configure(modifier: ModifierObject, modGroupId: String, allowAddingMore: Bool) {
		self.allowAddingMore = allowAddingMore
        self.modGroupId = modGroupId
        self.modifier = modifier
        modifierImgView.setImageKF(imageString: modifier.modifierImageUrl ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: true, loaderTintColor: .lightGray, completionHandler: nil)
        modifierTitleLabel.text = AppUserDefaults.selectedLanguage() == .en ? modifier.nameEnglish ?? "" : modifier.nameArabic ?? ""
        let image = modifier.addedToTemplate ?? false ? AppImages.AddAddress.checkBoxSelected : AppImages.AddAddress.checkBoxUnselected
        selectedButton.setImage(image, for: .normal)
        priceLabel.isHidden = (modifier.price.isNil || (modifier.price ?? 0.0 == 0.0))
        let price = (modifier.price ?? 0.0).round(to: 2).removeZerosFromEnd()
        priceLabel.text = "+SR\(price)"
    }
    
}
