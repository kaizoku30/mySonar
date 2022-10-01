//
//  AddModTypeTableViewCell.swift
//  Kudu
//
//  Created by Admin on 24/08/22.
//

import UIKit

class AddModTypeTableViewCell: UITableViewCell {
    @IBOutlet weak var modifierImgView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var incrementButton: AppButton!
    @IBOutlet private weak var decrementButton: AppButton!
    @IBOutlet private weak var countLabelButton: AppButton!
    @IBOutlet private weak var incrementorView: UIStackView!
    @IBOutlet private weak var addButton: AppButton!
    
    @IBAction private func decrementButtonPressed(_ sender: Any) {
        if currentModifierCount == modifierMin && modifierMin != 0 {
            currentModifierCount = 0
            self.modifierCountAltered?(currentModifierCount, modifier._id ?? "", modGroupId)
        } else {
            if currentModifierCount != 0 {
                currentModifierCount -= 1
                self.modifierCountAltered?(currentModifierCount, modifier._id ?? "", modGroupId)
            }
        }
    }
    
    @IBAction private func incrementButtonPressed(_ sender: Any) {
        if currentModifierCount != modifierMax || modifierMax == 0 {
            if currentModifierCount == 0 && modifierMin != 0 {
                currentModifierCount = modifierMin
            } else {
                currentModifierCount += 1
            }
            self.modifierCountAltered?(currentModifierCount, modifier._id ?? "", modGroupId)
        }
    }
    
    @IBAction private func addButtonPressed(_ sender: Any) {
		if !allowOperation { return }
        currentModifierCount = modifierMin == 0 ? 1 : modifierMin
        self.modifierCountAltered?(currentModifierCount, modifier._id ?? "", modGroupId)
    }
    
    var modifierCountAltered: ((Int, String, String) -> Void)?
    private var modifier: ModifierObject!
    private var modGroupId: String!
    private var modifierMax: Int!
    private var modifierMin: Int!
	private var allowOperation: Bool = true
    private var currentModifierCount: Int! {
        didSet {
            setButtonState()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
	func configure(modifier: ModifierObject, modGroupId: String, allowOperation: Bool) {
		self.allowOperation = allowOperation
        self.modGroupId = modGroupId
        self.modifier = modifier
        self.modifierMin = modifier.minimum ?? 0
        self.modifierMax = modifier.maximum ?? 0
        debugPrint(modifier.modifierImageUrl ?? "no url")
        modifierImgView.setImageKF(imageString: modifier.modifierImageUrl ?? "", placeHolderImage: AppImages.MainImages.fixedPlaceholder, loader: true, loaderTintColor: .lightGray, completionHandler: nil)
        titleLabel.text = AppUserDefaults.selectedLanguage() == .en ? modifier.nameEnglish ?? "" : modifier.nameArabic ?? ""
        priceLabel.isHidden = (modifier.price.isNil || (modifier.price ?? 0.0 == 0.0))
        let price = (modifier.price ?? 0.0).round(to: 2).removeZerosFromEnd()
        priceLabel.text = "+SR\(price)"
        self.currentModifierCount = modifier.count ?? 0
    }
    
    private func setButtonState() {
        self.countLabelButton.setTitle("\(currentModifierCount ?? 0)", for: .normal)
        let decrementImg = currentModifierCount == modifierMin || currentModifierCount == 1 ? AppImages.Customise.delete : AppImages.Customise.minus
        let incrementImg = currentModifierCount == modifierMax ? AppImages.Customise.disabledPlus : AppImages.Customise.activePlus
        self.decrementButton.setImage(decrementImg, for: .normal)
        self.incrementButton.borderColor = currentModifierCount == modifierMax ? AppColors.Customise.disabledBorderForAdd : AppColors.Customise.enabledBorderForAdd
        self.incrementButton.setImage(incrementImg, for: .normal)
        self.addButton.isHidden = currentModifierCount != 0
        self.incrementorView.isHidden = currentModifierCount == 0
        self.countLabelButton.isHidden = currentModifierCount == 0
    }
    
}
