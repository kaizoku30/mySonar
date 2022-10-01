//
//  RestauratCollectionViewCell.swift
//  Kudu
//
//  Created by Admin on 12/09/22.
//

import UIKit

class RestaurantCollectionViewCell: UICollectionViewCell {
	@IBOutlet private weak var ourStoreView: UIView!
	@IBOutlet private weak var restNameLabel: UILabel!
	@IBOutlet private weak var distanceLabel: UILabel!
	@IBOutlet private weak var restAddressLabel: UILabel!
	@IBOutlet private weak var openCloseLabel: UILabel!
	@IBOutlet private weak var closeTimingStackView: UIStackView!
	@IBOutlet private weak var closeTimingLabel: UILabel!
	@IBOutlet private weak var shimmerView: UIView!
	@IBOutlet private weak var containerInfoStackView: UIStackView!
	@IBOutlet private weak var pickUpButton: UIButton!
	@IBOutlet private weak var curbsideButton: AppButton!
	@IBOutlet private weak var storeName: UILabel!
	@IBOutlet private weak var distanceLbl: UILabel!
	@IBOutlet private weak var storeAddress: UILabel!
	@IBOutlet private weak var deliveryAvailability: UILabel!
	@IBOutlet private weak var rushHourLabel: UILabel!
	@IBOutlet private weak var openingTimeLabel: UILabel!
	@IBOutlet private weak var noResultFoundView: NoResultFoundView!
	
	private var index: Int = 0
	
	var didSelectRestaurant: ((Int) -> Void)?
	var curbsidePressed: ((Int) -> Void)?
	var pickupPressed: ((Int) -> Void)?
	
	@IBAction private func curbsideTapped(_ sender: Any) {
		curbsidePressed?(index)
	}
	
	@IBAction private func pickupTapped(_ sender: Any) {
		pickupPressed?(index)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		containerInfoStackView.isHidden = true
		shimmerView.isHidden = true
		ourStoreView.isHidden = true
		noResultFoundView.isHidden = true
		shimmerView.stopShimmering()
		noResultFoundView.contentType = .noResultFound
		contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped)))
	}
	
	@objc private func containerTapped() {
		didSelectRestaurant?(self.index)
	}
	
	func configure(_ restaurant: RestaurantListItem, ourStoreFlow: Bool, index: Int, selected: Bool, type: APIEndPoints.ServicesType?) {
		[noResultFoundView, shimmerView, ourStoreView, containerInfoStackView].forEach({ $0?.isHidden = true })
		self.index = index
		if ourStoreFlow == false && type.isNotNil {
			setInfoDataForRestaurant(item: restaurant, type: type!)
		} else {
			setOurStoreViewData(item: restaurant)
		}
		contentView.cornerRadius = 4
		contentView.borderWidth = 1
		contentView.borderColor = selected ? AppColors.kuduThemeYellow : AppColors.black.withAlphaComponent(0.12)
	}
	
	private func setOurStoreViewData(item: RestaurantListItem) {
		let selectedLang = AppUserDefaults.selectedLanguage()
		storeName.text = selectedLang == .en ? item.nameEnglish : item.nameArabic
		storeAddress.text = selectedLang == .en ? item.restaurantLocation?.areaNameEnglish : item.restaurantLocation?.areaNameArabic
		let openingTime = (item.workingHoursStartTimeInMinutes ?? 0).convertMinutesToAMPM(smallcase: false)
		let closingTime = (item.workingHoursEndTimeInMinutes ?? 0).convertMinutesToAMPM(smallcase: false)
		let currentTime = Date().totalMinutes
		let isOpen = currentTime >= (item.workingHoursStartTimeInMinutes ?? 0) && currentTime <= (item.workingHoursEndTimeInMinutes ?? 0)
		var timeString = NSAttributedString(string: "Open : \(openingTime) to \(closingTime)", attributes: [.foregroundColor: AppColors.OurStore.timeLblColor])
		var openingTimeString = timeString
		let distance = (item.distance ?? 0.0).round(to: 2).removeZerosFromEnd()
		let distanceAttributedString = NSMutableAttributedString(string: "\(distance) \(LocalizedStrings.SetRestaurant.km) away \(isOpen ? "" : "| ")", attributes: [.foregroundColor: AppColors.OurStore.distanceLblColor])
		
		if !isOpen {
			timeString = NSAttributedString(string: "Closed Now", attributes: [.foregroundColor: AppColors.RestaurantListCell.closedRed])
			distanceAttributedString.append(timeString)
			openingTimeString = NSAttributedString(string: "Open : \(openingTime) to \(closingTime)", attributes: [.foregroundColor: AppColors.OurStore.distanceLblColor])
		}
		openingTimeLabel.attributedText = openingTimeString
		distanceLabel.attributedText = distanceAttributedString
		rushHourLabel.isHidden = !(item.isRushHour ?? false)
		var isDelivery = item.serviceDelivery ?? false
		if item.isRushHour ?? false || isOpen == false {
			isDelivery = false
		}
		deliveryAvailability.text = isDelivery ? LocalizedStrings.OurStore.DeliveryAvailable : LocalizedStrings.OurStore.DeliveryUnavailable
		deliveryAvailability.textColor = isDelivery ? AppColors.OurStore.deliveryAvailable : AppColors.OurStore.deliveryUnavailable
		var curbSideEnabled = (item.serviceCurbSide ?? false)
		var servicePickupEnabled = (item.servicePickup ?? false)
		if isOpen == false {
			curbSideEnabled = false
			servicePickupEnabled = false
		}
		curbsideButton.backgroundColor = curbSideEnabled ? AppColors.kuduThemeBlue : AppColors.LoginScreen.unselectedButtonBg
		pickUpButton.backgroundColor = servicePickupEnabled ? AppColors.kuduThemeBlue : AppColors.LoginScreen.unselectedButtonBg
		curbsideButton.setTitleColor(curbSideEnabled ? AppColors.white : AppColors.LoginScreen.unselectedButtonTextColor, for: .normal)
		pickUpButton.setTitleColor(servicePickupEnabled ? AppColors.white : AppColors.LoginScreen.unselectedButtonTextColor, for: .normal)
		ourStoreView.isHidden = false
	}
	
	private func setInfoDataForRestaurant(item: RestaurantListItem, type: APIEndPoints.ServicesType) {
		let item = item
		let name = AppUserDefaults.selectedLanguage() == .en ? item.nameEnglish ?? "" : item.nameArabic ?? ""
		let areaName = AppUserDefaults.selectedLanguage() == .en ? (item.restaurantLocation?.areaNameEnglish ?? "") : (item.restaurantLocation?.areaNameArabic ?? "")
		restNameLabel.text = name
		let distance = (item.distance ?? 0.0).round(to: 2).removeZerosFromEnd()
		distanceLbl.text = distance + LocalizedStrings.SetRestaurant.km
		restAddressLabel.text = areaName
		let closingMinutes = type == .pickup ? (item.pickupTimingToInMinutes.isNotNil ? item.pickupTimingToInMinutes! : item.workingHoursEndTimeInMinutes ?? 0) : (item.curbSideTimingToInMinutes.isNotNil ? item.curbSideTimingToInMinutes! : item.workingHoursEndTimeInMinutes ?? 0)
		let openingMinutes = type == .pickup ? (item.pickupTimingFromInMinutes.isNotNil ? item.pickupTimingFromInMinutes! : item.workingHoursStartTimeInMinutes ?? 0) : (item.curbSideTimingFromInMinutes.isNotNil ? item.curbSideTimingFromInMinutes! : item.workingHoursStartTimeInMinutes ?? 0)
		let currentMinuteTimeStamp = Date().totalMinutes
		let isOpen = currentMinuteTimeStamp >= openingMinutes && currentMinuteTimeStamp <= closingMinutes
		closeTimingStackView.isHidden = !isOpen
		closeTimingLabel.text = "\(LocalizedStrings.SetRestaurant.closed) " + closingMinutes.convertMinutesToAMPM()
		closeTimingLabel.font = AppFonts.mulishBold.withSize(14)
		openCloseLabel.text = isOpen ? LocalizedStrings.SetRestaurant.open : LocalizedStrings.SetRestaurant.closed
		openCloseLabel.textColor = isOpen ? AppColors.RestaurantListCell.openGreen : AppColors.RestaurantListCell.closedRed
		openCloseLabel.font = isOpen ? AppFonts.mulishBold.withSize(14) : AppFonts.mulishBold.withSize(12)
		containerInfoStackView.isHidden = false
	}
	
	func shimmer() {
		[noResultFoundView, ourStoreView, containerInfoStackView].forEach({ $0?.isHidden = true })
		shimmerView.isHidden = false
		contentView.cornerRadius = 4
		shimmerView.startShimmering()
		contentView.borderWidth = 0
	}
	
	func noResult() {
		[shimmerView, ourStoreView, containerInfoStackView].forEach({ $0?.isHidden = true })
		noResultFoundView.isHidden = false
		contentView.borderWidth = 0
	}
}
