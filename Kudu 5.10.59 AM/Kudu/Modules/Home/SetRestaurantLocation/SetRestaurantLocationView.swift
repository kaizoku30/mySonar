//
//  SetRestaurantLocationView.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit

class SetRestaurantLocationView: UIView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchTFView: AppTextFieldView!
    @IBOutlet private weak var searchBarContainerView: UIView!
    @IBOutlet private weak var noResultView: NoResultFoundView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var errorToastView: AppErrorToastView!
    @IBOutlet private weak var errorTopAnchor: NSLayoutConstraint!
    @IBOutlet private weak var errorHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var clearBtn: AppButton!
    
    @IBAction private func backButtonPressed(_ sender: Any) {
        self.handleViewActions?(.backButtonPressed)
    }
    
    @IBAction private func clearButtonPressed(_ sender: Any) {
        self.currentSection = .blankScreen
        self.handleViewActions?(.clearButtonPressed)
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    private var flow: HomeVM.SectionType = .pickup
    private var currentSection: CurrentSection = .suggestions
    var getCurrentSection: CurrentSection { currentSection }
    private var vcSafeAreaRef: (top: CGFloat, bottom: CGFloat) = (0, 0)
    
    enum ViewActions {
        case searchTextChanged(updatedText: String)
        case searchTextForDetailList(searchText: String)
        case backButtonPressed
        case clearButtonPressed
        case fetchSuggestions
        case fetchList
        case openSettings
        case openMap
    }
    
    enum APICalled {
        case suggestions
        case detailList
    }
    
    enum CurrentSection {
        case blankScreen
        case suggestions
        case results
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clearBtn.isHidden = true
        noResultView.contentType = .noResultFound
        searchTFView.textFieldType = .address
        searchTFView.placeholderText = LocalizedStrings.SetRestaurant.selectBranch
        searchTFView.font = AppFonts.mulishBold.withSize(14)
        searchTFView.textColor = .black
        searchBarContainerView.roundTopCorners(cornerRadius: 4)
        tableView.registerCell(with: AutoCompleteLoaderCell.self)
        tableView.registerCell(with: AutoCompleteResultCell.self)
//        tableView.registerCell(with: RestaurantItemTableViewCell.self)
//        tableView.registerCell(with: RestaurantListInfoTableViewCell.self)
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = false
        titleLabel.text = LocalizedStrings.SetRestaurant.setPickupLocation
    }
    
    func setupView(flow: HomeVM.SectionType = .pickup, safeAreaInsets:(top: CGFloat, bottom: CGFloat)) {
        mainThread {
            self.flow = flow
            //self.setTitle()
            self.searchTFView.focus()
            self.handleTextField()
            self.vcSafeAreaRef = safeAreaInsets
        }
        
    }
    
    func setTitle(flow: HomeVM.SectionType = .pickup) {
        if flow == .curbside {
            titleLabel.text = LocalizedStrings.SetRestaurant.setCurbsideLocation
        }
    }
    
    func syncSearchTextFromMap(text: String) {
        searchTFView.currentText = text
        if text.isEmpty {
            self.currentSection = .blankScreen
            self.handleClearAll()
        } else {
            self.currentSection = .results
            self.handleViewActions?(.searchTextForDetailList(searchText: text))
        }
    }
    
    private func handleTextField() {
        searchTFView.textFieldDidChangeCharacters = { [weak self] in
            guard let strongSelf = self, let text = $0 else { return }
            strongSelf.toggleNoResult(show: false)
            strongSelf.currentSection = text.isEmpty ? .blankScreen : .suggestions
            strongSelf.clearBtn.isHidden = text.isEmpty
            if strongSelf.currentSection == .suggestions {
                strongSelf.handleViewActions?(.searchTextChanged(updatedText: text))
            } else {
                strongSelf.handleClearAll()
            }
        }
        
        searchTFView.textFieldDidBeginEditing = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.toggleNoResult(show: false)
            strongSelf.currentSection = strongSelf.searchTFView.currentText.isEmpty ? .blankScreen : .suggestions
            debugPrint("Textfield Selected")
            strongSelf.tableView.reloadData()
        }
        
        searchTFView.textFieldFinishedEditing = { [weak self] in
            guard let strongSelf = self else { return }
            if let text = $0, text.isEmpty == false {
                strongSelf.currentSection = text.isEmpty ? .blankScreen : .results
                if text.isEmpty {
                    strongSelf.handleClearAll()
                    return
                }
                strongSelf.handleViewActions?(.searchTextForDetailList(searchText: text))
            }
            debugPrint("Textfield Unselected")
        }
        
    }
    
    private func toggleNoResult(show: Bool) {
        mainThread {
            self.tableView.isHidden = show
            self.noResultView.isHidden = !show
            self.noResultView.show = show
        }
    }
    
    func handleClearAll() {
        searchTFView.currentText = ""
        clearBtn.isHidden = true
        currentSection = .blankScreen
        toggleNoResult(show: false)
        self.tableView.reloadData()
    }
    
    func focusTextField() {
        self.searchTFView.focus()
    }
    
    func showError(message: String, extraDelay: TimeInterval? = nil) {
        mainThread {
            let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
            toast.show(message: message, view: self)
        }
    }
    
    func showLocationServicesAlert(type: LocationServicesDeniedView.AlertType) {
        let alert = LocationServicesDeniedView(frame: CGRect(x: 0, y: 0, width: LocationServicesDeniedView.Width, height: LocationServicesDeniedView.Height))
        alert.configure(type: type, leftButtonTitle: LocalizedStrings.SetRestaurant.cancel, rightButtonTitle: LocalizedStrings.SetRestaurant.settings, container: self)
        alert.handleAction = { [weak self] in
            if $0 == .right {
                self?.handleViewActions?(.openSettings)
            } else {
                self?.handleViewActions?(.backButtonPressed)
            }
        }
    }

}

extension SetRestaurantLocationView {
    func handleAPIRequest(_ api: APICalled) {
        mainThread {
            self.tableView.reloadData()
        }
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, noResultFound: Bool, errorMsg: String?) {
        mainThread { [weak self] in
            guard let strongSelf = self else { return }
            if api == .detailList && isSuccess && noResultFound {
                strongSelf.toggleNoResult(show: true)
                return
            }
            strongSelf.tableView.reloadData()
            if !isSuccess {
                let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: strongSelf.width - 32, height: 48))
                toast.show(message: errorMsg ?? "", view: strongSelf)
            }
        }
    }
}
