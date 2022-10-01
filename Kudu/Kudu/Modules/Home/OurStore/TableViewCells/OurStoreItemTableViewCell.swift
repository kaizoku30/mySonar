//
//  TableViewCell.swift
//  OurStroreTableView
//
//  Created by Admin on 08/08/22.
//

import UIKit

class OurStoreItemTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var mapImageView: UIImageView!
    @IBOutlet private weak var pickUpButton: UIButton!
    @IBOutlet private weak var curbsideButton: AppButton!
    @IBOutlet private weak var storeName: UILabel!
    @IBOutlet private weak var distanceLbl: UILabel!
    @IBOutlet private weak var storeAddress: UILabel!
    @IBOutlet private weak var deliveryAvailability: UILabel!
    @IBOutlet private weak var rushHourLabel: UILabel!
    @IBOutlet private weak var openingTimeLabel: UILabel!
    
    @IBAction func curbsideButtonTapped(_ sender: Any) {
        guard let restaurantItem = restaurantItem else { return }
        curbsideTapped?(restaurantItem)
    }
    
    @IBAction func pickUpButtonTapped(_ sender: Any) {
        guard let restaurantItem = restaurantItem else { return }
        pickUpTapped?(restaurantItem)
    }
    
    private var restaurantItem: RestaurantListItem?
    var curbsideTapped: ((RestaurantListItem) -> Void)?
    var pickUpTapped: ((RestaurantListItem) -> Void)?
    var deliveryTapped: ((RestaurantListItem) -> Void)?
    var openMapWithSelection: ((RestaurantListItem) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        initialSetup()
    }
    
    private func initialSetup() {
        rushHourLabel.isHidden = true
        mapImageView.isUserInteractionEnabled = true
        mapImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMapWithSelectedRestaurant)))
        deliveryAvailability.isUserInteractionEnabled = true
        deliveryAvailability.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deliveryLabelTapped)))
        rushHourLabel.roundTopCorners(cornerRadius: 4)
    }
    
    @objc private func deliveryLabelTapped() {
        if restaurantItem?.serviceDelivery ?? false == true, let restaurant = self.restaurantItem {
            deliveryTapped?(restaurant)
        }
    }
    
    @objc private func openMapWithSelectedRestaurant() {
        if let restaurantItem = restaurantItem {
            openMapWithSelection?(restaurantItem)
        }
    }
    
    func configure(restaurant: RestaurantListItem) {
        self.restaurantItem = restaurant
        let selectedLang = AppUserDefaults.selectedLanguage()
        storeName.text = selectedLang == .en ? restaurant.nameEnglish : restaurant.nameArabic
        storeAddress.text = selectedLang == .en ? restaurant.restaurantLocation?.areaNameEnglish : restaurant.restaurantLocation?.areaNameArabic
        let openingTime = (restaurant.workingHoursStartTimeInMinutes ?? 0).convertMinutesToAMPM(smallcase: false)
        let closingTime = (restaurant.workingHoursEndTimeInMinutes ?? 0).convertMinutesToAMPM(smallcase: false)
        let currentTime = Date().totalMinutes
        let isOpen = currentTime >= (restaurant.workingHoursStartTimeInMinutes ?? 0) && currentTime <= (restaurant.workingHoursEndTimeInMinutes ?? 0)
        var timeString = NSAttributedString(string: "Open : \(openingTime) to \(closingTime)", attributes: [.foregroundColor: AppColors.OurStore.timeLblColor])
        var openingTimeString = timeString
        let distance = (restaurant.distance ?? 0.0).round(to: 2).removeZerosFromEnd()
        let distanceAttributedString = NSMutableAttributedString(string: "\(distance) \(LocalizedStrings.SetRestaurant.km) away \(isOpen ? "" : "| ")", attributes: [.foregroundColor: AppColors.OurStore.distanceLblColor])
        if !isOpen {
            timeString = NSAttributedString(string: "Closed Now", attributes: [.foregroundColor: AppColors.RestaurantListCell.closedRed])
            distanceAttributedString.append(timeString)
            openingTimeString = NSAttributedString(string: "Open : \(openingTime) to \(closingTime)", attributes: [.foregroundColor: AppColors.OurStore.distanceLblColor])
        }
        openingTimeLabel.attributedText = openingTimeString
        distanceLbl.attributedText = distanceAttributedString
        rushHourLabel.isHidden = !(restaurant.isRushHour ?? false)
        var isDelivery = restaurant.serviceDelivery ?? false
        if restaurant.isRushHour ?? false || isOpen == false {
            isDelivery = false
        }
        deliveryAvailability.text = isDelivery ? LocalizedStrings.OurStore.DeliveryAvailable : LocalizedStrings.OurStore.DeliveryUnavailable
        deliveryAvailability.textColor = isDelivery ? AppColors.OurStore.deliveryAvailable : AppColors.OurStore.deliveryUnavailable
        var curbSideEnabled = (restaurant.serviceCurbSide ?? false)
        var servicePickupEnabled = (restaurant.servicePickup ?? false)
        if isOpen == false {
            curbSideEnabled = false
            servicePickupEnabled = false
        }
        curbsideButton.backgroundColor = curbSideEnabled ? AppColors.kuduThemeBlue : AppColors.LoginScreen.unselectedButtonBg
        pickUpButton.backgroundColor = servicePickupEnabled ? AppColors.kuduThemeBlue : AppColors.LoginScreen.unselectedButtonBg
        curbsideButton.setTitleColor(curbSideEnabled ? AppColors.white : AppColors.LoginScreen.unselectedButtonTextColor, for: .normal)
        pickUpButton.setTitleColor(servicePickupEnabled ? AppColors.white : AppColors.LoginScreen.unselectedButtonTextColor, for: .normal)
        
    }
}
