//
//  MapPinView.swift
//  Kudu
//
//  Created by Admmyin on 14/07/22.
//

import UIKit
import GoogleMaps

class MapPinView: UIView {
    @IBOutlet private weak var mapView: GMSMapView!
    @IBOutlet private weak var customMarkerView: UIView!
    @IBOutlet private weak var addressContainerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var topAddressLabel: UILabel!
    @IBOutlet private weak var bottomAddressLabel: UILabel!
    @IBOutlet private weak var confirmLocationButton: UIButton!
    @IBOutlet private weak var movePinLabel: UILabel!
    
    @IBAction private func recenterMap(_ sender: Any) {
        handleViewActions?(.recenterMap)
    }
    
    @IBAction private func backButtonPressed(_ sender: Any) {
        handleViewActions?(.backButtonPressed)
    }
    @IBAction private func confirmLocationButtonPressed(_ sender: Any) {
        handleViewActions?(.confirmLocationPressed)
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    
    enum ViewActions {
        case backButtonPressed
        case confirmLocationPressed
        case recenterMap
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        movePinLabel.text = LocalizedStrings.MapPin.movePinLabel
        movePinLabel.adjustsFontSizeToFitWidth = true
        confirmLocationButton.setTitle(LocalizedStrings.MapPin.confirmLocation, for: .normal)
        addressContainerView.roundTopCorners(cornerRadius: 32)
        titleLabel.text = LocalizedStrings.MapPin.setLocationTitle
    }
    
    func setupView(delegate: MapPinVC) {
        mapView.delegate = delegate
    }
    
    func updateAddressLabel(top: String, bottom: String) {
        topAddressLabel.text = top
        bottomAddressLabel.text = bottom
    }
    
    func setMapCamera(_ camera: GMSCameraPosition) {
        mapView.camera = camera
    }
}
