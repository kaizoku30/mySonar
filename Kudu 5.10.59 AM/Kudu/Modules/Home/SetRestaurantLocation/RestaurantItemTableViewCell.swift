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
        distanceLabel.text = distance + LocalizedStrings.SetRestaurant.kmt
        restAddressLabel.text = areaName
        let isOpen = self.checkRestaurantIsOpen(item: item, type: type)
        closeTimingStackView.isHidden = !isOpen
        let closingTime = type == .pickup ? ((item.pickupTimingTo.isNil ? (item.workingHoursEndTime ?? "") : (item.pickupTimingTo ?? ""))) : (((item.curbSideTimingTo.isNil ? (item.workingHoursEndTime ?? "") : (item.curbSideTimingTo ?? ""))))
        closeTimingLabel.text = "\(LocalizedStrings.SetRestaurant.closed) \(closingTime.replace(string: "AM", withString: LocalizedStrings.SetRestaurant.amString).replace(string: "PM", withString: LocalizedStrings.SetRestaurant.pmString))"
        setConfirmButton(enabled: isOpen)
        openCloseLabel.text = isOpen ? LocalizedStrings.SetRestaurant.open : LocalizedStrings.SetRestaurant.closed
        openCloseLabel.textColor = isOpen ? AppColors.RestaurantListCell.openGreen : AppColors.RestaurantListCell.closedRed
    }
    
    private func setConfirmButton(enabled: Bool) {
        confirmButton.setTitleColor(enabled ? .white : AppColors.RestaurantListCell.unselectedButtonTextColor, for: .normal)
        confirmButton.backgroundColor = enabled ? AppColors.kuduThemeYellow : AppColors.RestaurantListCell.unselectedButtonBg
        confirmButton.isUserInteractionEnabled = enabled
        
    }
    
    private func checkRestaurantIsOpen(item: RestaurantListItem, type: HomeVM.SectionType) -> Bool {
        let start = type == .pickup ? ((item.pickupTimingFrom.isNil ? (item.workingHoursStartTime ?? "") : (item.pickupTimingFrom ?? ""))) : (((item.curbSideTimingFrom.isNil ? (item.workingHoursStartTime ?? "") : (item.curbSideTimingFrom ?? ""))))
        let end = type == .pickup ? ((item.pickupTimingTo.isNil ? (item.workingHoursEndTime ?? "") : (item.pickupTimingTo ?? ""))) : (((item.curbSideTimingTo.isNil ? (item.workingHoursEndTime ?? "") : (item.curbSideTimingTo ?? ""))))
        debugPrint("Start Time : \(start), End Time : \(end)")
        let startDate = start.toDate(dateFormat: Date.DateFormat.hmmazzz.rawValue)
        let endDate = end.toDate(dateFormat: Date.DateFormat.hmmazzz.rawValue)
        let currentTime = Date().toString(dateFormat: Date.DateFormat.hmmazzz.rawValue)
        let currentDate = currentTime.toDate(dateFormat: Date.DateFormat.hmmazzz.rawValue)
        guard let dateStart = startDate, let dateEnd = endDate, let currentDate = currentDate else {
            debugPrint("Date parsing failed")
            return false
        }
        let debugString = "Date parsing success \(dateStart) \(dateEnd)"
        debugPrint(debugString)
        return (currentDate.unixTimestamp >= dateStart.unixTimestamp) && (currentDate.unixTimestamp <= dateEnd.unixTimestamp)
    }

}
