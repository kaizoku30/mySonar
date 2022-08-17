//
//  RestaurantItemTableViewCell.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit

class RestaurantItemTableViewCell: UITableViewCell {
    @IBOutlet private weak var restNameLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var confirmButton: AppButton!
    @IBOutlet private weak var restAddressLabel: UILabel!
    @IBOutlet private weak var openCloseLabel: UILabel!
    @IBOutlet private weak var closeTimingStackView: UIStackView!
    @IBOutlet private weak var closeTimingLabel: UILabel!
    
    @IBAction func confirmLocationTapped(_ sender: Any) {
        if item.isNil { return }
        confirmLocationTapped?(item!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        confirmButton.setTitle(LocalizedStrings.SetRestaurant.confirmlocationSmall, for: .normal)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    private var item: RestaurantListItem?
    var confirmLocationTapped: ((RestaurantListItem) -> Void)?
    
    func configure(item: RestaurantListItem, type: HomeVM.SectionType) {
        self.item = item
        let name = AppUserDefaults.selectedLanguage() == .en ? item.nameEnglish ?? "" : item.nameArabic ?? ""
        let areaName = AppUserDefaults.selectedLanguage() == .en ? (item.restaurantLocation?.areaNameEnglish) ?? "" : (item.restaurantLocation?.areaNameArabic) ?? ""
        restNameLabel.text = name
        let distance = (item.distance ?? 0.0).round(to: 2).removeZerosFromEnd()
        distanceLabel.text = distance + LocalizedStrings.SetRestaurant.km
        restAddressLabel.text = areaName
        let closingTime = type == .pickup ? (item.pickupTimingToInMinutes.isNotNil ? item.pickupTimingToInMinutes! : item.workingHoursEndTimeInMinutes ?? 0) : (item.curbSideTimingToInMinutes.isNotNil ? item.curbSideTimingToInMinutes! : item.workingHoursEndTimeInMinutes ?? 0)
        let openingTime = type == .pickup ? (item.pickupTimingFromInMinutes.isNotNil ? item.pickupTimingFromInMinutes! : item.workingHoursStartTimeInMinutes ?? 0) : (item.curbSideTimingFromInMinutes.isNotNil ? item.curbSideTimingFromInMinutes! : item.workingHoursStartTimeInMinutes ?? 0)
        let currentTime = Date().totalMinutes
        let isOpen = currentTime >= openingTime && currentTime <= closingTime
        closeTimingStackView.isHidden = !isOpen
        closeTimingLabel.text = "\(LocalizedStrings.SetRestaurant.closed) " + closingTime.convertMinutesToAMPM()
        debugPrint(Date().totalMinutes.convertMinutesToAMPM())
        setConfirmButton(enabled: isOpen)
        openCloseLabel.text = isOpen ? LocalizedStrings.SetRestaurant.open : LocalizedStrings.SetRestaurant.closed
        openCloseLabel.textColor = isOpen ? AppColors.RestaurantListCell.openGreen : AppColors.RestaurantListCell.closedRed
    }
    
    private func setConfirmButton(enabled: Bool) {
        confirmButton.setTitleColor(enabled ? .white : AppColors.RestaurantListCell.unselectedButtonTextColor, for: .normal)
        confirmButton.backgroundColor = enabled ? AppColors.kuduThemeYellow : AppColors.RestaurantListCell.unselectedButtonBg
        confirmButton.isUserInteractionEnabled = enabled
        
    }
}
