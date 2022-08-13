//
//  MapPinVC.swift
//  Kudu
//
//  Created by Admin on 11/07/22.
//

import GoogleMaps
import SwiftLocation

class MapPinVC: BaseVC {
    
    @IBOutlet private weak var baseView: MapPinView!
    private var debouncer = Debouncer(delay: 1)
    var prefillCallback: ((LocationInfoModel) -> Void)?
    var viewModel: MapPinVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.setupView(delegate: self)
        viewModel?.fetchInitialPointInMap()
        handleDebouncer()
        handleActions()
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            guard let `self` = self, let viewModel = self.viewModel else { return }
            switch $0 {
            case .confirmLocationPressed:
                guard let data = viewModel.getPrefillData else { return }
                self.prefillCallback?(data)
                self.pop()
            case .backButtonPressed:
                self.pop()
            case .recenterMap:
                self.viewModel?.fetchInitialPointInMap()
            }
        }
    }
    
    private func handleDebouncer() {
        debouncer.callback = { [weak self] in
            guard let lat = self?.viewModel?.getCurrentCoordinates.latitude, let long = self?.viewModel?.getCurrentCoordinates.longitude else {
                return
            }
            self?.baseView.updateAddressLabel(top: "", bottom: "")
            self?.viewModel?.handleReverseGeocoding(lat: lat, long: long)
        }
    }
}

extension MapPinVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.viewModel?.updateLocation(position.target)
        debouncer.call()
    }
}

extension MapPinVC: MapPinVMDelegate {
    
    func currentLocationFetched(cameraPosition: GMSCameraPosition) {
        mainThread {
            self.baseView.setMapCamera(cameraPosition)
        }
    }
    
    func failedToFetchLocation(reason: String) {
        mainThread {
            self.baseView.updateAddressLabel(top: "", bottom: reason)
        }
    }
    
    func reverseGeocodingSuccess(trimmedAddress: String, cityStateText: String) {
        mainThread {
            self.baseView.updateAddressLabel(top: trimmedAddress, bottom: cityStateText)
        }
    }
    
    func reverseGeocodingFailed(reason: String) {
        mainThread {
            self.baseView.updateAddressLabel(top: reason, bottom: "")
        }
    }
    
}
