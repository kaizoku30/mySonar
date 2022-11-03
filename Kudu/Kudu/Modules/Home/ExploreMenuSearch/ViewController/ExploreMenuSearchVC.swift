//
//  ExploreMenuSearchVC.swift
//  Kudu
//
//  Created by Admin on 28/07/22.
//

import UIKit

class ExploreMenuSearchVC: BaseVC {
    
    @IBOutlet  weak var searchContainer: UIView!
    @IBOutlet  weak var tableView: UITableView!
    @IBOutlet  weak var clearButton: AppButton!
    @IBOutlet  weak var searchIcon: UIImageView!
    @IBOutlet  weak var searchTFView: AppTextFieldView!
    @IBOutlet  weak var noResultView: NoResultFoundView!
    @IBOutlet  weak var searchLine: UIView!
    
    @IBAction  func backButtonPressed(_ sender: Any) {
        if self.isShowingMenuData {
            self.toggleSearchState(searchBarActive: true)
            switch previousViewType {
            case .recentSearchTopCategories:
                self.clearAllPressed()
            case .results:
                self.textQuery = previousTextQuery
                self.searchTFView.currentText = self.textQuery
                self.currentViewType = .results
                self.searchTFView.isUserInteractionEnabled = true
                self.isShowingMenuData = false
                self.keyboardDismissed()
            case .suggestionAndTopCategories:
                self.textQuery = previousTextQuery
                self.searchTFView.currentText = self.textQuery
                self.currentViewType = .suggestionAndTopCategories
                self.searchTFView.isUserInteractionEnabled = true
                self.isShowingMenuData = false
                self.searchLine.isHidden = false
                self.searchTFView.focus()
                self.debouncerFunction()
            }
        } else {
            self.pop()
        }
        
    }
    
    @IBAction  func clearButtonPressed(_ sender: Any) {
        clearAllPressed()
    }
    
    var storeId: String?
    var serviceType: APIEndPoints.ServicesType = .delivery
    var debouncer = Debouncer(delay: 1)
    var textQuery: String = ""
    var topSearchedCategories: [MenuCategory] = []
    var suggestions: [MenuSearchResultItem] = []
    var pageNo: Int = 1
    var total: Int = 1
    var results: [MenuSearchResultItem] = []
    var recentSearches: [MenuSearchResultItem] { DataManager.shared.fetchRecentSearchesForExploreMenu() }
    var currentViewType: CurrentViewType = .recentSearchTopCategories
    var previousViewType: CurrentViewType = .recentSearchTopCategories
    var previousTextQuery: String = ""
    var isFetchingTopSearchCategories = false
    var isFetchingSuggestions = false
    var isFetchingResults = false
    var isFetchingMenuItems = false
    var isShowingMenuData = false
    var isShowingItemData = false
    var itemDetailResponse: MenuItem?
    var itemDetailTableIndex: Int?
    var updateExploreMenu: ((MenuSearchResultItem) -> Void)?
    enum CurrentViewType {
        case suggestionAndTopCategories
        case results
        case recentSearchTopCategories
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchIcon.isUserInteractionEnabled = true
        searchIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchIconPressed)))
        noResultView.show = true
        noResultView.contentType = .noResultFound
        setupTF()
        setupTableView()
        handleDebouncer()
        self.tableView.isUserInteractionEnabled = false
        self.isFetchingTopSearchCategories = true
        self.tableView.reloadData()
        self.getTopSearchCategories()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.searchTFView.focus()
        })
    }
    
    func setupTableView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.registerCell(with: SuggestionShimmerCell.self)
        tableView.registerCell(with: AutoCompleteLoaderCell.self)
        tableView.registerCell(with: ItemTableViewCell.self)
    }
}

extension ExploreMenuSearchVC {
    func openItemDetail(result: MenuSearchResultItem) {
        mainThread {
            self.isShowingItemData = true
            self.searchTFView.unfocus()
            let vc = BaseVC()
            vc.configureForCustomView()
            let bottomSheet = ItemDetailView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
            bottomSheet.triggerLoginFlow = { [weak self] (addReq) in
                GuestUserCache.shared.queueAction(.addToCart(req: addReq))
                vc.dismiss(animated: true, completion: { [weak self] in
                    self?.tabBarController?.removeOverlay()
                    let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                    loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                    self?.push(vc: loginVC)
                })
            }
            
            bottomSheet.configureForExploreMenu(container: vc.view, itemId: result._id ?? "", serviceType: self.serviceType)
            bottomSheet.handleDeallocation = { [weak self] in
                self?.isShowingItemData = false
                if self?.currentViewType == .suggestionAndTopCategories {
                    self?.searchTFView.focus()
                }
                self?.tableView.reloadData()
                vc.dismiss(animated: true, completion: { [weak self] in
                    self?.tabBarController?.removeOverlay()
                })
            }
            bottomSheet.cartCountUpdated = { [weak self] (count, item) in
                self?.updateCountLocally(count: count, menuItem: item, template: nil)
                self?.tableView.reloadData()
            }
            self.tabBarController?.addOverlayBlack()
            self.present(vc, animated: true)
        }
    }
    
    func openItemDetail(resultMenuItem: MenuItem) {
        mainThread {
            self.isShowingItemData = true
            self.searchTFView.unfocus()
            let vc = BaseVC()
            vc.configureForCustomView()
            let bottomSheet = ItemDetailView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
            bottomSheet.triggerLoginFlow = { [weak self] (addReq) in
                GuestUserCache.shared.queueAction(.addToCart(req: addReq))
                vc.dismiss(animated: true, completion: { [weak self]  in
                    self?.tabBarController?.removeOverlay()
                    let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                    loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                    self?.push(vc: loginVC)
                })
            }
            bottomSheet.configure(container: vc.view, item: resultMenuItem, serviceType: self.serviceType)
            bottomSheet.handleDeallocation = { [weak self] in
                self?.isShowingItemData = false
                if self?.currentViewType == .suggestionAndTopCategories {
                    self?.searchTFView.focus()
                }
                self?.tableView.reloadData()
                vc.dismiss(animated: true, completion: {
                    self?.tabBarController?.removeOverlay()
                })
            }
            bottomSheet.cartCountUpdated = { [weak self] (count, item) in
                self?.updateCountLocally(count: count, menuItem: item, template: nil)
                self?.tableView.reloadData()
            }
            self.tabBarController?.addOverlayBlack()
            self.present(vc, animated: true)
        }
    }
}

extension ExploreMenuSearchVC {
    
    func handleCustomiseRepeat(item: MenuItem, count: Int) {
        self.tableView.reloadData()
        let popUp = RepeatCustomisationView(frame: CGRect(x: 0, y: 0, width: self.view.width - AppPopUpView.HorizontalPadding, height: 0))
        popUp.configure(container: self.view)
        popUp.handleAction = { [weak self] (action) in
            mainThread {
                if action == .repeatCustomisation {
                    self?.updateCountLocally(count: count, menuItem: item, template: item.templates?.last)
                    self?.tableView.reloadData()
                } else {
                    //No Customisation
                    self?.tableView.reloadData()
                    self?.fetchItemDetail(itemId: item._id ?? "", preLoadTemplate: nil)
                }
            }
        }
    }
}

extension ExploreMenuSearchVC {
    
    func openCustomisedItemDetail(result: MenuItem?, prefillTempate: CustomisationTemplate? = nil) {
        self.isShowingItemData = true
        self.searchTFView.unfocus()
        if let result = result {
            mainThread {
                let vc = BaseVC()
                vc.configureForCustomView()
                let bottomSheet = CustomisableItemDetailView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
                bottomSheet.handleDeallocation = { [weak self] in
                    self?.isShowingItemData = false
                    if self?.currentViewType ?? .results == .suggestionAndTopCategories {
                        self?.searchTFView.focus()
                    }
                    self?.tableView.reloadData()
                    vc.dismiss(animated: true, completion: {
                        self?.tabBarController?.removeOverlay()
                    })
                }
                bottomSheet.configure(item: result, container: vc.view, preLoadTemplate: prefillTempate, serviceType: self.serviceType)
                bottomSheet.addToCart = { [weak self] (modGroupArray, hashId, itemId) in
                    guard let strongSelf = self else { return }
                    
                    if DataManager.shared.isUserLoggedIn == false {
                        GuestUserCache.shared.queueAction(.addToCart(req: AddCartItemRequest(itemId: itemId, menuId: result.menuId ?? "", hashId: hashId, storeId: DataManager.shared.currentStoreId, itemSdmId: result.itemId ?? 0, quantity: 1, servicesAvailable: DataManager.shared.currentServiceType, modGroups: modGroupArray)))
                        let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                        loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                        self?.push(vc: loginVC)
                        self?.tableView.reloadData()
                        return
                    }
                    
                    var arrayToSearch: [MenuSearchResultItem] = []
                    switch strongSelf.currentViewType {
                    case .recentSearchTopCategories:
                        arrayToSearch = strongSelf.recentSearches
                    case .results:
                        arrayToSearch = strongSelf.results
                    case .suggestionAndTopCategories:
                        arrayToSearch = strongSelf.suggestions
                    }
                    
                    guard let itemIndex = arrayToSearch.firstIndex(where: { $0._id ?? "" == itemId}) else {
                        return
                    }
                    let item = arrayToSearch[itemIndex]
                    strongSelf.isShowingItemData = false
                    strongSelf.updateCountLocally(count: (item.cartCount ?? 0) + 1, menuItem: item.convertToMenuItem(), template: CustomisationTemplate(modGroups: modGroupArray, hashId: hashId))
                    strongSelf.tableView.reloadData()
                }
                self.tabBarController?.addOverlayBlack()
                self.present(vc, animated: true)
            }
        }
    }
}
