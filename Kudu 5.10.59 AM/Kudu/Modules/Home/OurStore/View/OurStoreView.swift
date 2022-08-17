//
//  OurStoreView.swift
//  Kudu
//
//  Created by Admin on 16/08/22.
//

import UIKit

class OurStoreView: UIView {
    
    @IBOutlet private weak var noResultView: NoResultFoundView!
    @IBOutlet private weak var storeNearYouLabel: UILabel!
    @IBOutlet private weak var clearButton: AppButton!
    @IBOutlet private weak var storeSearchTF: AppTextFieldView!
    @IBOutlet private weak var searchBarContainer: UIView!
    @IBOutlet private weak var mapButton: AppButton!
    @IBOutlet private weak var ourStoreTitleLabel: UILabel!
    @IBAction private func backButtonPressed(_ sender: Any) {
        self.handleViewActions?(.backButtonPressed)
    }
    @IBAction private func mapButtonPressed(_ sender: Any) {
        self.handleViewActions?(.openMap)
    }
    @IBAction private func clearButtonPressed(_ sender: Any) {
        self.storeSearchTF.currentText = ""
        self.storeSearchTF.unfocus()
        self.viewState = .detailedList
        self.fetchingRestaurants = false
        self.handleViewActions?(.clearButtonPressed)
    }
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    private func initialSetup() {
        clearButton.isHidden = true
        storeSearchTF.textFieldType = .address
        storeSearchTF.placeholderText = "Search store"
        storeSearchTF.font = AppFonts.mulishBold.withSize(14)
        storeSearchTF.textColor = .black
        searchBarContainer.roundTopCorners(cornerRadius: 4)
        tableView.registerCell(with: OurStoreItemTableViewCell.self)
        tableView.registerCell(with: AutoCompleteLoaderCell.self)
        tableView.showsVerticalScrollIndicator = false
        ourStoreTitleLabel.text = LocalizedStrings.Profile.ourStore
        searchBarContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusTF)))
        noResultView.contentType = .noResultFound
        tableView.isHidden = true
        storeNearYouLabel.isHidden = true
        mapButton.setAttributedTitle(NSAttributedString(string: LocalizedStrings.SetRestaurant.map, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]), for: .normal)
        mapButton.layer.applySketchShadow(color: .black, alpha: 0.14, x: 0, y: 2, blur: 10, spread: 0)
    }
    
    @objc private func focusTF() {
        storeSearchTF.focus()
    }
    
    enum ViewState {
        case noResultFound
        case detailedList
    }
    
    enum ViewActions {
        case openSettings
        case backButtonPressed
        case editingStarted
        case searchTextChanged(updatedText: String)
        case clearButtonPressed
        case openMap
    }
    
    enum APICalled {
        case restaurantListing
    }
    
    private var fetchingRestaurants = false
    private var viewState: ViewState = .detailedList {
        didSet {
        debugPrint(viewState)
    }}

    var handleViewActions: ((ViewActions) -> Void)?
    var isFetchingRestaurants: Bool { fetchingRestaurants }
    var currenState: ViewState { viewState }
    
    func showLocationServicesAlert(type: LocationServicesDeniedView.LocationAlertType) {
        let alert = LocationServicesDeniedView(frame: CGRect(x: 0, y: 0, width: LocationServicesDeniedView.locationPopUpWidth, height: LocationServicesDeniedView.locationPopUpHeight))
        alert.configureLocationView(type: type, leftButtonTitle: LocalizedStrings.SetRestaurant.cancel, rightButtonTitle: LocalizedStrings.SetRestaurant.settings, container: self)
        alert.handleActionOnLocationView = { [weak self] in
            if $0 == .right {
                self?.handleViewActions?(.openSettings)
            } else {
                self?.handleViewActions?(.backButtonPressed)
            }
        }
    }
    
    func setupView() {
        handleTextField()
        self.handleAPIRequest(.restaurantListing)
    }
    
    func syncSearchTextFromMap(text: String) {
        let previousText = storeSearchTF.currentText
        storeSearchTF.currentText = text
        self.viewState = .detailedList
        if text.isEmpty {
            self.fetchingRestaurants = false
            self.handleViewActions?(.clearButtonPressed)
        } else {
            if text != previousText {
                self.handleViewActions?(.searchTextChanged(updatedText: storeSearchTF.currentText))
            }
        }
    }
    
    func toggleViewInteraction(enabled: Bool) {
        self.tableView.isUserInteractionEnabled = enabled
        self.storeSearchTF.isUserInteractionEnabled = enabled
        self.mapButton.isUserInteractionEnabled = enabled
    }

}

extension OurStoreView {
    private func handleTextField() {
        storeSearchTF.textFieldDidBeginEditing = { [weak self] in
            self?.viewState = .detailedList
            self?.clearButton.isHidden = false
            self?.tableView.reloadData()
        }
        
        storeSearchTF.textFieldDidChangeCharacters = { [weak self] (updatedText) in
            self?.viewState = .detailedList
            self?.clearButton.isHidden = false
            self?.storeNearYouLabel.isHidden = false
            self?.handleViewActions?(.searchTextChanged(updatedText: updatedText ?? ""))
        }
    }
}

extension OurStoreView {
    func handleAPIRequest(_ api: APICalled) {
        mainThread({
            self.mapButton.isUserInteractionEnabled = false
            self.fetchingRestaurants = true
            self.tableView.isUserInteractionEnabled = false
            self.storeNearYouLabel.isHidden = true
            self.tableView.reloadData()
            self.tableView.isHidden = false
        })
    }
    
    func handleAPIResponse( _ api: APICalled, resultCount: Int, isSuccess: Bool, errorMsg: String?) {
        mainThread {
            self.mapButton.isUserInteractionEnabled = true
            self.tableView.isUserInteractionEnabled = true
            self.fetchingRestaurants = false
            if let errorMsg = errorMsg {
                let error = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
                error.show(message: errorMsg, view: self)
                self.viewState = .noResultFound
                self.noResultView.isHidden = false
                self.tableView.isHidden = true
                self.tableView.reloadData()
                return
            }
            if !self.storeSearchTF.currentText.isEmpty && resultCount == 0 {
                self.viewState = .noResultFound
                self.noResultView.isHidden = false
                self.tableView.isHidden = true
                self.tableView.reloadData()
                return
            }
            self.storeNearYouLabel.text = LocalizedStrings.SetRestaurant.xStoreNearYou.replace(string: CommonStrings.numberPlaceholder, withString: "\(resultCount)")
            self.storeNearYouLabel.isHidden = false
            self.tableView.reloadData()
            self.tableView.isHidden = false
        }
    }
}
