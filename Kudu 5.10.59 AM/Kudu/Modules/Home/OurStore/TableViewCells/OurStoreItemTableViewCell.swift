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
        let distance = (restaurant.distance ?? 0.0).round(to: 2).removeZerosFromEnd()
        let distanceAttributedString = NSMutableAttributedString(string: "\(distance) \(LocalizedStrings.SetRestaurant.km) away | ", attributes: [.foregroundColor: AppColors.OurStore.distanceLblColor])
        let openingTime = (restaurant.workingHoursStartTimeInMinutes ?? 0).convertMinutesToAMPM(smallcase: true)
        let closingTime = (restaurant.workingHoursEndTimeInMinutes ?? 0).convertMinutesToAMPM(smallcase: true)
        let timeString = NSAttributedString(string: "Open : \(openingTime) to \(closingTime)", attributes: [.foregroundColor: AppColors.OurStore.timeLblColor])
        distanceAttributedString.append(timeString)
        distanceLbl.attributedText = distanceAttributedString
        rushHourLabel.isHidden = !(restaurant.isRushHour ?? false)
        let isDelivery = restaurant.serviceDelivery ?? false
        deliveryAvailability.text = isDelivery ? LocalizedStrings.OurStore.DeliveryAvailable : LocalizedStrings.OurStore.DeliveryUnavailable
        deliveryAvailability.textColor = isDelivery ? AppColors.OurStore.deliveryAvailable : AppColors.OurStore.deliveryUnavailable
        
    }
}
