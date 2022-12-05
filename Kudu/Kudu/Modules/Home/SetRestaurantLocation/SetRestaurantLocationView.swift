//
//  SetRestaurantLocationView.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit

class SetRestaurantLocationView: UIView {
    
	@IBOutlet private weak var confirmLocationHeight: NSLayoutConstraint!
	@IBOutlet private weak var mapButton: AppButton!
	@IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchTFView: AppTextFieldView!
    @IBOutlet private weak var searchBarContainerView: UIView!
    @IBOutlet private weak var noResultView: NoResultFoundView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var errorToastView: AppErrorToastView!
    @IBOutlet private weak var errorTopAnchor: NSLayoutConstraint!
    @IBOutlet private weak var errorHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var clearBtn: AppButton!
	@IBOutlet private weak var confirmLocationButton: AppButton!
	
    @IBAction private func backButtonPressed(_ sender: Any) {
        self.handleViewActions?(.backButtonPressed)
    }
	
	@IBAction private func mapButtonPressed(_ sender: Any) {
		self.handleViewActions?(.openMap)
	}
	
    @IBAction private func clearButtonPressed(_ sender: Any) {
        self.currentSection = .blankScreen
        self.handleViewActions?(.clearButtonPressed)
    }
    
	@IBAction private func confirmLocationPressed(_ sender: Any) {
		if self.confirmLocationButton.titleColor(for: .normal) ?? .white == .white {
			self.handleViewActions?(.confirmLocationPresssed)
		}
	}
	
    var handleViewActions: ((ViewActions) -> Void)?
    private var flow: APIEndPoints.ServicesType = .pickup
    private var currentSection: CurrentSection = .suggestions
    var getCurrentSection: CurrentSection { currentSection }
    private var vcSafeAreaRef: (top: CGFloat, bottom: CGFloat) = (0, 0)
    private var showingError = false
	
    enum ViewActions {
        case searchTextChanged
        case searchTextForDetailList(searchText: String)
        case backButtonPressed
        case clearButtonPressed
        case fetchSuggestions
        case fetchList
        case openSettings
        case openMap
		case confirmLocationPresssed
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
		setConfirmButton(enabled: false)
        clearBtn.isHidden = true
        noResultView.contentType = .noResultFound
        searchTFView.textFieldType = .address
        searchTFView.placeholderText = LSCollection.SetRestaurant.selectBranch
        searchTFView.font = AppFonts.mulishBold.withSize(14)
        searchTFView.textColor = .black
        searchBarContainerView.roundTopCorners(cornerRadius: 4)
        tableView.registerCell(with: AutoCompleteLoaderCell.self)
        tableView.registerCell(with: AutoCompleteResultCell.self)
		tableView.registerCell(with: SuggestionShimmerCell.self)
		mapButton.setAttributedTitle(NSAttributedString(string: LSCollection.SetRestaurant.map, attributes: nil), for: .normal)
		mapButton.layer.applySketchShadow(color: .black, alpha: 0.14, x: 0, y: 2, blur: 10, spread: 0)
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = false
        titleLabel.text = LSCollection.SetRestaurant.setPickupLocation
        showHideMapButton(show: false)
    }
	
	func getSearchText() -> String {
		self.searchTFView.currentText
	}
	
	func refreshTableView(enableConfirmLocation: Bool) {
		self.tableView.reloadData()
		self.setConfirmButton(enabled: enableConfirmLocation)
	}
    
    func setupView(flow: APIEndPoints.ServicesType = .pickup, safeAreaInsets:(top: CGFloat, bottom: CGFloat)) {
        mainThread {
            self.flow = flow
            //self.setTitle()
            self.searchTFView.focus()
            self.handleTextField()
            self.vcSafeAreaRef = safeAreaInsets
        }
        
    }
    
    func showHideMapButton(show: Bool) {
        mainThread {
            self.mapButton.isHidden = !show
        }
    }
    
    func setTitle(flow: APIEndPoints.ServicesType = .pickup) {
        if flow == .curbside {
            titleLabel.text = LSCollection.SetRestaurant.setCurbsideLocation
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
                strongSelf.handleViewActions?(.searchTextChanged)
            } else {
				strongSelf.handleViewActions?(.clearButtonPressed)
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
	
	private func toggleConfirmLocation(show: Bool) {
		UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: {
			self.confirmLocationHeight.constant = show ? 84 : 0
			self.layoutIfNeeded()
		})
	}
    
    func handleClearAll() {
        searchTFView.currentText = ""
        clearBtn.isHidden = true
        currentSection = .blankScreen
        toggleNoResult(show: false)
		toggleConfirmLocation(show: false)
        self.tableView.reloadData()
    }
    
    func focusTextField() {
        self.searchTFView.focus()
    }
    
    func showError(message: String, extraDelay: TimeInterval? = nil) {
        mainThread {
			if self.showingError == true { return }
			self.showingError = true
            let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
			toast.show(message: message, view: self, completionBlock: { [weak self] in
				self?.showingError = false
			})
        }
    }
    
    func showLocationServicesAlert(type: LocationServicesDeniedView.LocationAlertType) {
        mainThread {
            let alert = LocationServicesDeniedView(frame: CGRect(x: 0, y: 0, width: LocationServicesDeniedView.locationPopUpWidth, height: LocationServicesDeniedView.locationPopUpHeight))
            alert.configureLocationView(type: type, leftButtonTitle: LSCollection.SetRestaurant.cancel, rightButtonTitle: LSCollection.SetRestaurant.settings, container: self)
            alert.handleActionOnLocationView = { [weak self] in
                if $0 == .right {
                    self?.handleViewActions?(.openSettings)
                } else {
                    self?.handleViewActions?(.backButtonPressed)
                }
            }
        }
    }
	
	func setConfirmButton(enabled: Bool) {
		confirmLocationButton.setTitleColor(enabled ? .white : AppColors.RestaurantListCell.unselectedButtonTextColor, for: .normal)
		confirmLocationButton.backgroundColor = enabled ? AppColors.kuduThemeYellow : AppColors.RestaurantListCell.unselectedButtonBg
		confirmLocationButton.isUserInteractionEnabled = enabled
		
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
				strongSelf.toggleConfirmLocation(show: false)
                return
            }
			if api == .detailList && isSuccess && !noResultFound {
				strongSelf.toggleConfirmLocation(show: true)
			}
            strongSelf.tableView.reloadData()
            if !isSuccess {
                let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: strongSelf.width - 32, height: 48))
                toast.show(message: errorMsg ?? "", view: strongSelf)
            }
        }
    }
}
