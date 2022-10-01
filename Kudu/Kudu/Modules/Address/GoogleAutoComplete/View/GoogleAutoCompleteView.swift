//
//  GoogleAutoCompleteView.swift
//  Kudu
//
//  Created by Admin on 15/07/22.
//

import UIKit

class GoogleAutoCompleteView: UIView {
    
    @IBOutlet private weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraintMapButton: NSLayoutConstraint! // 22
    @IBOutlet private weak var recentSearchesTableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchTFView: AppTextFieldView!
    @IBOutlet private weak var searchBarContainerView: UIView!
    @IBOutlet private weak var noResultView: NoResultFoundView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var errorToastView: AppErrorToastView!
    @IBOutlet private weak var errorTopAnchor: NSLayoutConstraint!
    @IBOutlet private weak var errorHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pinMapBtn: AppButton!
    @IBOutlet private weak var clearBtn: AppButton!
    
    @IBAction private func backButtonPressed(_ sender: Any) {
        self.handleViewActions?(.backButtonPressed)
    }
    
    @IBAction private func clearButtonPressed(_ sender: Any) {
        searchTFView.currentText = ""
        clearBtn.isHidden = true
        self.handleViewActions?(.clearButtonPressed)
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    private var flow: GoogleAutoCompleteVM.FlowType = .myAddress
    
    enum SetDeliveryLocationSection: Int, CaseIterable {
        case recentlySearched = 0
        case savedAddresses
        
        var title: String {
            switch self {
            case .recentlySearched:
                return LocalizedStrings.GoogleAutoComplete.recentSearches
            case .savedAddresses:
                return LocalizedStrings.GoogleAutoComplete.savedAddresses
            }
        }
    }
    
    enum ViewActions {
        case searchTextChanged(updatedText: String)
        case backButtonPressed
        case clearButtonPressed
        case fetchAddressList
        case openMap
        case openSettings
    }
    
    enum APICalled {
        case autoComplete
        case reverseGeocoding
        case addressListFetched
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clearBtn.isHidden = true
        noResultView.contentType = .noResultFound
        searchTFView.textFieldType = .address
        searchTFView.placeholderText = LocalizedStrings.GoogleAutoComplete.typeAddressToSearch
        searchTFView.font = AppFonts.mulishBold.withSize(14)
        searchTFView.textColor = .black
        searchBarContainerView.roundTopCorners(cornerRadius: 4)
        tableView.registerCell(with: AutoCompleteLoaderCell.self)
        tableView.registerCell(with: AutoCompleteResultCell.self)
        recentSearchesTableView.registerCell(with: RecentSearchSectionTitleCell.self)
        recentSearchesTableView.registerCell(with: AutoCompleteResultCell.self)
        recentSearchesTableView.registerCell(with: AutoCompleteLoaderCell.self)
		recentSearchesTableView.registerCell(with: SuggestionShimmerCell.self)
		tableView.registerCell(with: SuggestionShimmerCell.self)
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        recentSearchesTableView.bounces = false
        titleLabel.text = LocalizedStrings.GoogleAutoComplete.setLocationTitle
    }
    
    func setupView(flow: GoogleAutoCompleteVM.FlowType = .myAddress) {
        self.flow = flow
        if self.flow == .setDeliveryLocation {
            self.handleViewActions?(.fetchAddressList)
            self.searchTFView.placeholderText = LocalizedStrings.GoogleAutoComplete.searchYourLocation
            self.buttonHeightConstraint.constant = 24
            self.layoutIfNeeded()
        }
        setTitle()
        handleTextField()
        addKeyboardObservers()
    }
    
    func focusTF() {
        mainThread {
            self.searchTFView.focus()
        }
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        animateWithKeyboard(notification: notification, animations: { [weak self] (keyboardRect) in
            mainThread {
                guard let strongSelf = self else { return }

                strongSelf.bottomConstraintMapButton.constant = keyboardRect.height + 16 - strongSelf.safeAreaInsets.bottom
                strongSelf.layoutIfNeeded()
                
            }
        })
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        animateWithKeyboard(notification: notification) { [weak self] (_) in
            mainThread {
                guard let strongSelf = self else { return }
                strongSelf.bottomConstraintMapButton.constant = 22
                //self.textViewBottomC.constant = 95
                strongSelf.layoutIfNeeded()
            }}
    }
    
    func showRecentSearches(_ tableView: UITableView) -> Bool {
        if tableView == recentSearchesTableView && flow == .setDeliveryLocation {
            return true
        } else {
            return false
        }
    }
    
    private func setTitle() {
        if flow == .setDeliveryLocation {
            titleLabel.text = LocalizedStrings.GoogleAutoComplete.setDeliveryLocation
            pinMapBtn.isHidden = false
            pinMapBtn.handleBtnTap = { [weak self] in
                self?.handleViewActions?(.openMap)
            }
        }
    }
    
    private func handleTextField() {
        searchTFView.textFieldDidChangeCharacters = { [weak self] in
            guard let strongSelf = self, let text = $0 else { return }
            strongSelf.clearBtn.isHidden = text.isEmpty
            strongSelf.handleViewActions?(.searchTextChanged(updatedText: text))
        }
    }
    
    private func toggleNoResult(show: Bool, noItemFound: Bool? = nil) {
        mainThread {
            self.tableView.isHidden = show
            if self.flow == .setDeliveryLocation {
                if noItemFound.isNotNil {
                    self.recentSearchesTableView.isHidden = true
                    self.noResultView.isHidden = !noItemFound!
                    self.noResultView.show = noItemFound!
                } else {
                    self.noResultView.isHidden = true
                    self.recentSearchesTableView.isHidden = !show
                }
                return
            } else {
                self.noResultView.isHidden = !show
                self.noResultView.show = show
            }
        }
    }
    
    func clearAllPressed() {
        toggleNoResult(show: true)
    }
    
    func refreshRecentSearches() {
        self.recentSearchesTableView.reloadData()
    }
    
    func showError(message: String, extraDelay: TimeInterval? = nil) {
        mainThread {
            let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            toast.show(message: message, view: self)
        }
    }
    
    func showLocationServicesAlert(type: LocationServicesDeniedView.LocationAlertType) {
        let alert = LocationServicesDeniedView(frame: CGRect(x: 0, y: 0, width: LocationServicesDeniedView.locationPopUpWidth, height: LocationServicesDeniedView.locationPopUpHeight))
        alert.configureLocationView(type: type, leftButtonTitle: LocalizedStrings.GoogleAutoComplete.cancel, rightButtonTitle: LocalizedStrings.GoogleAutoComplete.settings, container: self)
        alert.handleActionOnLocationView = { [weak self] in
            if $0 == .right {
                self?.handleViewActions?(.openSettings)
            }
        }
    }
    
}

extension GoogleAutoCompleteView {
    func handleAPIRequest(_ api: APICalled) {
        mainThread {
            switch api {
            case .autoComplete:
                self.toggleNoResult(show: false)
                self.tableView.reloadData()
                self.tableView.isHidden = false
            case .reverseGeocoding:
                self.tableView.isUserInteractionEnabled = false
                self.searchBarContainerView.isUserInteractionEnabled = false
            case .addressListFetched:
                self.tableView.isHidden = true
                self.recentSearchesTableView.reloadData()
                self.recentSearchesTableView.isHidden = false
            }
        }
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, noResultFound: Bool, errorMsg: String?) {
        switch api {
        case .autoComplete:
            if noResultFound && isSuccess {
                self.tableView.isHidden = true
                self.tableView.reloadData()
                self.toggleNoResult(show: true, noItemFound: noResultFound)
                return
            }
            switch isSuccess {
            case true:
                self.tableView.reloadData()
                self.toggleNoResult(show: false)
                self.tableView.isHidden = false
            case false:
                self.tableView.isHidden = true
                self.tableView.reloadData()
                self.showError(message: errorMsg ?? LocalizedStrings.GoogleAutoComplete.somethingWentWrong, extraDelay: nil)
            }
        case .reverseGeocoding:
            if isSuccess == false {
                self.tableView.isUserInteractionEnabled = true
                self.searchBarContainerView.isUserInteractionEnabled = true
                self.tableView.reloadData()
                self.showError(message: errorMsg ?? LocalizedStrings.GoogleAutoComplete.somethingWentWrong)
            }
        case .addressListFetched:
            switch isSuccess {
            case true:
                self.recentSearchesTableView.reloadData()
            case false:
                self.toggleNoResult(show: false)
                self.showError(message: errorMsg ?? "")
            }
        }
    }
}
