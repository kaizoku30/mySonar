//
//  AddressLabelCell.swift
//  Kudu
//
//  Created by Admin on 13/07/22.
//

import UIKit

class AddressLabelCell: UITableViewCell {

    @IBOutlet private weak var staticLabel: UILabel!
    @IBOutlet private weak var textfieldView: AppTextFieldView!
    @IBOutlet private weak var buttonContainer: UIView!
    @IBOutlet private weak var textFieldContainer: UIView!
    @IBOutlet private weak var workButton: AppButton!
    @IBOutlet private weak var homeButton: AppButton!
    @IBOutlet private weak var otherButtonConstraint: NSLayoutConstraint!
    @IBOutlet private weak var otherButton: AppButton!
    
    @IBAction private func otherTapped(_ sender: Any) {
        self.selectionType = .OTHER
        self.selectionUpdated?(self.selectionType, self.otherLabel)
            self.updateUI(selectionType: self.selectionType, otherAddressLabel: self.otherLabel, initialSetup: false)
    }
    @IBAction func homeTapped(_ sender: Any) {
        self.selectionType = .HOME
        otherLabel = nil
        self.selectionUpdated?(self.selectionType, self.otherLabel)
        self.updateUI(selectionType: self.selectionType, otherAddressLabel: self.otherLabel, initialSetup: false)
    }
    
    @IBAction func workTapped(_ sender: Any) {
        otherLabel = nil
        self.selectionType = .WORK
        self.selectionUpdated?(self.selectionType, self.otherLabel)
        self.selectionType = .WORK
            self.updateUI(selectionType: self.selectionType, otherAddressLabel: self.otherLabel, initialSetup: false)
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        otherLabel = nil
        updateUI(selectionType: .HOME, otherAddressLabel: otherLabel)
    }
    
    typealias SelectionType = APIEndPoints.AddressLabelType
    private var selectionType: SelectionType = .HOME
    private var otherLabel: String?
    
    var selectionUpdated: ((SelectionType, String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        setupTextField()
        homeButton.setTitle(LSCollection.AddNewAddress.home, for: .normal)
        workButton.setTitle(LSCollection.AddNewAddress.work, for: .normal)
        otherButton.setTitle(LSCollection.AddNewAddress.other, for: .normal)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupTextField() {
        self.textfieldView.textFieldType = .address
        self.textfieldView.placeholderText = ""
        self.textfieldView.textColor = .black
        self.textfieldView.font = AppFonts.mulishSemiBold.withSize(12)
        self.textfieldView.textFieldFinishedEditing = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.otherLabel = $0
            debugPrint("Text field ended : \($0 ?? "")")
            strongSelf.selectionUpdated?(strongSelf.selectionType, strongSelf.otherLabel)
        }
    }
    
    func configure(selectionType: SelectionType, otherLabel: String?) {
        self.selectionType = selectionType
        self.otherLabel = otherLabel
        self.updateUI(selectionType: selectionType, otherAddressLabel: otherLabel, initialSetup: true)
    }
    
    private func updateUI(selectionType: SelectionType, otherAddressLabel: String?, initialSetup: Bool = false) {
        var otherButtons: [AppButton] = []
        var buttonSelected: AppButton = homeButton
        switch selectionType {
        case .HOME:
            otherButtons = [workButton, otherButton]
            buttonSelected = homeButton
        case .OTHER:
            otherButtons = [homeButton, workButton]
            buttonSelected = otherButton
        case .WORK:
            otherButtons = [homeButton, otherButton]
            buttonSelected = workButton
        }
        otherButtons.forEach({ (button) in
                button.borderWidth = 1
                button.borderColor = AppColors.kuduThemeBlue
                button.backgroundColor = .white
                button.setTitleColor(AppColors.kuduThemeBlue, for: .normal)
            })
        buttonSelected.borderWidth = 0
        buttonSelected.backgroundColor = AppColors.kuduThemeBlue
        buttonSelected.setTitleColor(.white, for: .normal)
        self.textfieldView.currentText = otherAddressLabel ?? ""
        self.animateAndShowTextfield(show: selectionType == .OTHER, initialSetup: initialSetup)
    }
    
    private func animateAndShowTextfield(show: Bool, initialSetup: Bool) {
            if show {
                self.homeButton.isHidden = true
                self.workButton.isHidden = true
                self.otherButtonConstraint.constant = 0
            } else {
                
                self.otherButtonConstraint.constant = 172
                self.homeButton.isHidden = false
                self.workButton.isHidden = false
            }
            self.textFieldContainer.isHidden = !show
        if show && initialSetup == false {
            self.textfieldView.focus()
        } else {
            self.textfieldView.unfocus()
        }
    }
}
