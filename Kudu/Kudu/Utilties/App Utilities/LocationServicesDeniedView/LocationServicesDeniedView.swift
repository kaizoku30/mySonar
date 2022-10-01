//
//  LocationServicesDeniedView.swift
//  Kudu
//
//  Created by Admin on 19/07/22.
//

import UIKit

class LocationServicesDeniedView: UIView {
    
    enum LocationAlertButton {
        case left
        case right
    }
    
    enum LocationAlertType {
        case locationServicesNotWorking
        case locationPermissionDenied
		case couldNotFetchLocation
        
        var message: String {
            switch self {
            case .locationServicesNotWorking:
                return "Turn On Location Services to allow KUDU to determine your current location."
            case .locationPermissionDenied:
                return "Allow KUDU to access your location to determine your current location."
			case .couldNotFetchLocation:
				return "Could not fetch your location. Please try again."
			}
        }
        
        var title: String {
            switch self {
            case .locationServicesNotWorking:
                return "Location Services Off"
            case .locationPermissionDenied:
                return "Location Permission Denied"
			case .couldNotFetchLocation:
				return "Could not fetch location"
			}
        }
    }
    
    @IBOutlet private var locationContentView: UIView!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var rightButton: AppButton!
    @IBOutlet private weak var leftButton: AppButton!
    @IBOutlet private weak var messageLbl: UILabel!
    
    var handleActionOnLocationView: ((LocationAlertButton) -> Void)?
    static var locationPopUpHeight: CGFloat { 336 }
    static var locationPopUpWidth: CGFloat { 308 }
    private weak var locationPopUpContainerView: UIView?
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         intitialiseLocationView()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         intitialiseLocationView()
     }
    
    private func intitialiseLocationView() {
        Bundle.main.loadNibNamed("LocationServicesDeniedView", owner: self, options: nil)
        addSubview(locationContentView)
        locationContentView.frame = self.bounds
        locationContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        handleLocationButtonTap()
    }
    
    private func removeLocationPopUpFromContainer() {
        self.locationPopUpContainerView?.subviews.forEach({
            if $0.tag == Constants.CustomViewTags.alertTag {
                $0.removeFromSuperview()
            }
        })
        self.locationPopUpContainerView?.subviews.forEach({
            if $0.tag == Constants.CustomViewTags.dimViewTag {
                $0.removeFromSuperview()
            }
        })
    }
    
    private func handleLocationButtonTap() {
        leftButton.handleBtnTap = {
            [weak self] in
            self?.handleActionOnLocationView?(.left)
            self?.removeLocationPopUpFromContainer()
        }
        rightButton.handleBtnTap = {
            [weak self] in
            self?.handleActionOnLocationView?(.right)
            self?.removeLocationPopUpFromContainer()
        }
    }
    
    func configureLocationView(type: LocationAlertType, leftButtonTitle: String, rightButtonTitle: String, container view: UIView) {
        self.locationPopUpContainerView = view
        let dimmedView = UIView(frame: view.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        view.addSubview(dimmedView)
        self.tag = Constants.CustomViewTags.alertTag
        self.center = view.center
        messageLbl.numberOfLines = 3
        messageLbl.adjustsFontSizeToFitWidth = true
        messageLbl.text = type.message
        title.text = type.title
        leftButton.setTitle(leftButtonTitle, for: .normal)
        rightButton.setTitle(rightButtonTitle, for: .normal)
        view.addSubview(self)
    }
}
