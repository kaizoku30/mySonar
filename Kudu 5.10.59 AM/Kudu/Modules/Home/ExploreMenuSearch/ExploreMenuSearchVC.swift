//
//  ExploreMenuSearchVC.swift
//  Kudu
//
//  Created by Admin on 28/07/22.
//

import UIKit

class ExploreMenuSearchVC: BaseVC {
    
    @IBOutlet private weak var searchContainer: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var clearButton: AppButton!
    @IBOutlet private weak var searchIcon: UIImageView!
    @IBOutlet private weak var searchTFView: AppTextFieldView!
    @IBOutlet private weak var noResultView: NoResultFoundView!
    @IBOutlet private weak var searchLine: UIView!
    
    @IBAction private func backButtonPressed(_ sender: Any) {
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
    
    @IBAction private func clearButtonPressed(_ sender: Any) {
        clearAllPressed()
    }
    
    private func clearAllPressed() {
        self.isShowingMenuData = false
        self.searchTFView.isUserInteractionEnabled = true
        self.searchLine.isHidden = false
        self.clearButton.isHidden = true
        self.searchIcon.isHidden = false
        self.searchTFView.currentText = ""
        self.results = []
        self.suggestions = []
        self.currentViewType = .recentSearchTopCategories
        self.tableView.reloadData()
        self.tableView.isHidden = false
    }
    
    var serviceType: HomeVM.SectionType = .delivery
    private var debouncer = Debouncer(delay: 1)
    private var textQuery: String = ""
    private var topSearchedCategories: [MenuCategory] = []
    private var suggestions: [MenuSearchResultItem] = []
    private var pageNo: Int = 1
    private var total: Int = 1
    private var results: [MenuSearchResultItem] = []
    private var recentSearches: [MenuSearchResultItem] { DataManager.shared.fetchRecentSearchesForExploreMenu() }
    private var currentViewType: CurrentViewType = .recentSearchTopCategories
    private var previousViewType: CurrentViewType = .recentSearchTopCategories
    private var previousTextQuery: String = ""
    private var isFetchingTopSearchCategories = false
    private var isFetchingSuggestions = false
    private var isFetchingResults = false
    private var isFetchingMenuItems = false
    private var isShowingMenuData = false
    private var isShowingItemData = false
    
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
    }
    
    @objc private func searchIconPressed() {
        searchTFView.focus()
    }
    
    private func setupTableView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.registerCell(with: AutoCompleteLoaderCell.self)
        tableView.registerCell(with: ItemTableViewCell.self)
    }
}

extension ExploreMenuSearchVC {
    private func handleDebouncer() {
        debouncer.callback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.debouncerFunction()
        }
    }
    
    private func debouncerFunction() {
        if self.textQuery.isEmpty {
            self.suggestions = []
            self.currentViewType = .recentSearchTopCategories
            self.tableView.reloadData()
            self.tableView.isHidden = false
            return
        }
        
        if self.currentViewType == .suggestionAndTopCategories {
            self.isFetchingSuggestions = true
            self.tableView.reloadData()
            self.tableView.isHidden = false
            self.getSuggetions()
        }
    }
}

extension ExploreMenuSearchVC {
    private func setupTF() {
        searchTFView.textFieldType = .address
        searchTFView.placeholderText = LocalizedStrings.SearchMenu.searchByNameOrCategories
        searchTFView.font = AppFonts.mulishBold.withSize(14)
        searchTFView.textColor = .black
        
        searchTFView.textFieldDidChangeCharacters = { [weak self] in
            guard let strongSelf = self, let text = $0 else { return }
            if strongSelf.isFetchingMenuItems || strongSelf.isShowingMenuData { return }
            strongSelf.textQuery = text
            strongSelf.currentViewType = .suggestionAndTopCategories
            strongSelf.searchIcon.isHidden = !text.isEmpty
            strongSelf.clearButton.isHidden = text.isEmpty
            strongSelf.debouncer.call()
        }
        
        searchTFView.textFieldDidBeginEditing = { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.searchTFView.currentText.isEmpty {
                strongSelf.suggestions = []
                strongSelf.currentViewType = .recentSearchTopCategories
                strongSelf.clearButton.isHidden = true
                strongSelf.searchIcon.isHidden = false
                strongSelf.tableView.reloadData()
                strongSelf.tableView.isHidden = false
            } else {
                strongSelf.currentViewType = .suggestionAndTopCategories
                strongSelf.searchIcon.isHidden = true
                strongSelf.clearButton.isHidden = false
                strongSelf.tableView.reloadData()
                strongSelf.tableView.isHidden = false
            }
        }
        
        searchTFView.textFieldFinishedEditing = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.keyboardDismissed()
        }
    }
    
    private func keyboardDismissed() {
        if self.isFetchingMenuItems || self.isShowingMenuData || self.isShowingItemData { return }
        self.currentViewType = self.searchTFView.currentText.isEmpty ? .recentSearchTopCategories : .results
        self.searchLine.isHidden = false
        if self.searchTFView.currentText.isEmpty {
            self.clearButton.isHidden = true
            self.searchIcon.isHidden = false
            self.results = []
            self.currentViewType = .recentSearchTopCategories
            self.tableView.reloadData()
            self.tableView.isHidden = false
            return
        }
        self.clearButton.isHidden = self.searchTFView.currentText.isEmpty
        self.searchIcon.isHidden = !self.searchTFView.currentText.isEmpty
        self.results = []
        self.pageNo = 1
        self.total = 0
        self.isFetchingResults = true
        self.tableView.reloadData()
        self.getResults()
    }
}

extension ExploreMenuSearchVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if currentViewType == .results && isShowingMenuData == false {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentViewType {
        case .recentSearchTopCategories:
            return getRowsForRecentSearchTopCategories()
        case .results:
            return section == 0 ? results.count + 1 : (results.count < total ? 1 : 0)
        case .suggestionAndTopCategories:
            return getRowsForSuggestionsAndTopSearchCategories()
        }
    }
    
    private func getRowsForRecentSearchTopCategories() -> Int {
        //Title Row For Recent Searches
        //Recent Searches
        //Top Categories
        if isFetchingTopSearchCategories {
            return 1
        }
        let recentSearchesRows = recentSearches.count
        let recentSearchTitle = recentSearches.count == 0 ? 0 : 1
        
        return 1 + recentSearchTitle + recentSearchesRows
        
    }
    
    private func getRowsForSuggestionsAndTopSearchCategories() -> Int {
        //Suggestions
        //Top Categories
        if isFetchingSuggestions {
            return 1
        }
        return 1 + suggestions.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentViewType {
        case .suggestionAndTopCategories:
            return getCellForSuggestionsTopCategories(tableView, cellForRowAt: indexPath)
        case .recentSearchTopCategories:
            return getCellForRecentSearchTopSuggestions(tableView, cellForRowAt: indexPath)
        case .results:
            return getCellForResults(tableView, cellForRowAt: indexPath)
        }
    }
    
    private func getTopSearchCategoriesCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: TopSearchCategoriesCell.self)
        cell.configure(topSearchedCategories)
        cell.performOperation = { [weak self] in
            let savedFormat = MenuSearchResultItem(_id: $0._id, titleEnglish: $0.titleEnglish, titleArabic: $0.titleArabic, isCategory: true, isItem: false, descriptionEnglish: nil, descriptionArabic: nil, nameEnglish: nil, nameArabic: nil, itemImageUrl: nil, price: nil, allergicComponent: nil, isCustomised: nil, menuImageUrl: $0.menuImageUrl, itemCount: $0.itemCount, isAvailable: true)
            DataManager.shared.saveToRecentlySearchExploreMenu(savedFormat)
            let title = AppUserDefaults.selectedLanguage() == .en ? $0.titleEnglish ?? "" : $0.titleArabic ?? ""
            self?.getCategoryItems(forMenuId: $0._id ?? "", menuTitle: title)
        }
        return cell
    }
    
    private func getCellForRecentSearchTopSuggestions(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Check for recent Searches existing
        let row = indexPath.row
        if isFetchingTopSearchCategories {
            return getLoaderCell(tableView, cellForRowAt: indexPath)
        }
        if recentSearches.isEmpty {
            return getTopSearchCategoriesCell(tableView, cellForRowAt: indexPath)
        } else {
            if row == 0 {
                let cell = tableView.dequeueCell(with: RecentMenuSearchTitleCell.self)
                return cell
            } else if row == tableView.numberOfRows(inSection: 0) - 1 {
                //Last Cell
                return getTopSearchCategoriesCell(tableView, cellForRowAt: indexPath)
            } else {
                //Rest Of the Cell between 0 -- Last Cell
                let cell = tableView.dequeueCell(with: SuggestionTableViewCell.self)
                if let item = recentSearches[safe: indexPath.row - 1] {
                    cell.configure(item)
                    cell.performOperation = { [weak self] (result) in
                        guard let strongSelf = self else { return }
                        strongSelf.suggestionTableViewCellTapped(result: result)
                    }
                }
                return cell
            }
        }
    }
    
    private func suggestionTableViewCellTapped(result: MenuSearchResultItem) {
        if result.isItem ?? false {
            mainThread {
                self.searchTFView.unfocus()
                DataManager.shared.saveToRecentlySearchExploreMenu(result)
                let bottomSheet = ItemDetailView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
                bottomSheet.configureForExploreMenu(container: self.view, item: result)
            }
        } else {
            DataManager.shared.saveToRecentlySearchExploreMenu(result)
            let id = result._id ?? ""
            let title = AppUserDefaults.selectedLanguage() == .en ? result.titleEnglish ?? "" : result.titleArabic ?? ""
            self.getCategoryItems(forMenuId: id, menuTitle: title)
        }
    }
    
    private func getLoaderCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueCell(with: AutoCompleteLoaderCell.self)
    }
    
    private func getCellForResults(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFetchingResults { return getLoaderCell(tableView, cellForRowAt: indexPath) }
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 {
            //Results
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueCell(with: NumberOfItemsCell.self)
                cell.itemsCountLabel.text = "\(results.count) results found"
                return cell
            }
            
            if let item = results[safe: row - 1] {
                return handleItemCellForResults(tableView, cellForRowAt: indexPath, item: item)
            }
            return UITableViewCell()
        } else {
            //Pagination Loader
            return getLoaderCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    private func handleItemCellForResults(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, item: MenuSearchResultItem) -> UITableViewCell {
        if item.isItem ?? false {
            let cell = tableView.dequeueCell(with: ItemTableViewCell.self)
            cell.configure(item)
            cell.openItemDetailForSearch = { [weak self] (result) in
                guard let strongSelf = self else { return }
                mainThread {
                    strongSelf.searchTFView.unfocus()
                    DataManager.shared.saveToRecentlySearchExploreMenu(result)
                    let bottomSheet = ItemDetailView(frame: CGRect(x: 0, y: 0, width: strongSelf.view.width, height: strongSelf.view.height))
                    bottomSheet.configureForExploreMenu(container: strongSelf.view, item: result)
                }
            }
            cell.triggerLoginFlow = { [weak self] in
                let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                self?.push(vc: loginVC)
            }
            return cell
        } else {
            let cell = tableView.dequeueCell(with: ExploreSearchCategoryResultCell.self)
            cell.configure(item)
            cell.performOperation = { [weak self] in
                DataManager.shared.saveToRecentlySearchExploreMenu($0)
                let title = AppUserDefaults.selectedLanguage() == .en ? $0.titleEnglish ?? "" : $0.titleArabic ?? ""
                self?.getCategoryItems(forMenuId: $0._id ?? "", menuTitle: title)
            }
            return cell
        }
    }
    
    private func getCellForSuggestionsTopCategories(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Suggestions
        //One Row for top search categories
        let row = indexPath.row
        if isFetchingSuggestions {
            return getLoaderCell(tableView, cellForRowAt: indexPath)
        }
        
        if suggestions.isEmpty {
            return getTopSearchCategoriesCell(tableView, cellForRowAt: indexPath)
        } else {
            if row < suggestions.count {
                return getSuggestionTableViewCellForTopSearchCategories(tableView, cellForRowAt: indexPath)
            } else {
                return getTopSearchCategoriesCell(tableView, cellForRowAt: indexPath)
            }
        }
    }
    
    private func getSuggestionTableViewCellForTopSearchCategories(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: SuggestionTableViewCell.self)
        if let item = suggestions[safe: indexPath.row] {
            cell.configure(item)
            cell.performOperation = { [weak self] (result) in
                guard let strongSelf = self else { return }
                if result.isItem ?? false {
                    mainThread {
                        strongSelf.isShowingItemData = true
                        strongSelf.searchTFView.unfocus()
                        DataManager.shared.saveToRecentlySearchExploreMenu(result)
                        let bottomSheet = ItemDetailView(frame: CGRect(x: 0, y: 0, width: strongSelf.view.width, height: strongSelf.view.height))
                        bottomSheet.configureForExploreMenu(container: strongSelf.view, item: result)
                        bottomSheet.handleDeallocation = { [weak self] in
                            self?.isShowingItemData = false
                            self?.searchTFView.focus()
                        }
                    }
                } else {
                    DataManager.shared.saveToRecentlySearchExploreMenu(result)
                    let id = result._id ?? ""
                    let title = AppUserDefaults.selectedLanguage() == .en ? result.titleEnglish ?? "" : result.titleArabic ?? ""
                    strongSelf.getCategoryItems(forMenuId: id, menuTitle: title)
                }
                
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && currentViewType == .results && isFetchingResults == false && results.count < total && isFetchingMenuItems == false && results.isEmpty == false && isShowingMenuData == false {
            debugPrint("Hit Pagination")
            self.pageNo += 1
            getResults()
        }
    }
    
}

extension ExploreMenuSearchVC {
    
    func getTopSearchCategories() {
        WebServices.HomeEndPoints.getTopSearchedCategories(type: self.serviceType, success: { [weak self] in
            let result = $0
            self?.tableView.isUserInteractionEnabled = true
            self?.topSearchedCategories = result.data ?? []
            self?.isFetchingTopSearchCategories = false
            mainThread {
                self?.tableView.reloadData()
            }
        }, failure: { _ in
            // No implementation needed
        })
    }
    
    func getSuggetions() {
        WebServices.HomeEndPoints.getSearchSuggestionsMenu(searchKey: self.textQuery, type: self.serviceType, success: { [weak self] in
            let result = $0
            self?.suggestions = result.data ?? []
            self?.isFetchingSuggestions = false
            mainThread {
                self?.tableView.reloadData()
            }
        }, failure: { _ in
            // No implementation needed
        })
    }
    
    func getResults() {
        WebServices.HomeEndPoints.getSearchResultsMenu(searchKey: self.textQuery, type: self.serviceType, pageNo: self.pageNo, success: { [weak self] in
            let result = $0
            self?.results.append(contentsOf: (result.data?.list) ?? [])
            self?.isFetchingResults = false
            self?.total = result.data?.totalRecord ?? 0
            self?.pageNo = result.data?.pageNo ?? 0
            mainThread {
                let resultCount = (self?.results.count) ?? 0
                if self?.currentViewType == .results {
                    self?.searchIcon.isHidden = true
                    self?.clearButton.isHidden = false
                    self?.tableView.isHidden = resultCount == 0 }
                self?.tableView.reloadData()
            }
        }, failure: { _ in
            // No implementation needed
        })
    }
    
    func getCategoryItems(forMenuId menuId: String, menuTitle: String) {
        mainThread {
            self.toggleSearchState(searchBarActive: false)
            self.previousTextQuery = self.textQuery
            self.previousViewType = self.currentViewType
            self.isShowingMenuData = true
            self.isFetchingMenuItems = true
            self.searchLine.isHidden = true
            self.clearButton.isHidden = true
            self.searchIcon.isHidden = true
            self.searchTFView.currentText = menuTitle
            self.searchTFView.isUserInteractionEnabled = false
            self.searchTFView.unfocus()
            self.results = []
            self.currentViewType = .results
            self.isFetchingResults = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
        WebServices.HomeEndPoints.getMenuItemList(menuId: menuId, success: { [weak self] (response) in
            mainThread {
            self?.results = []
            response.data?.forEach({
                let resultFormat = MenuSearchResultItem(_id: $0._id, titleEnglish: nil, titleArabic: nil, isCategory: false, isItem: true, descriptionEnglish: $0.descriptionEnglish, descriptionArabic: $0.descriptionArabic, nameEnglish: $0.nameEnglish, nameArabic: $0.nameArabic, itemImageUrl: $0.itemImageUrl, price: $0.price, allergicComponent: $0.allergicComponent, isCustomised: $0.isCustomised, menuImageUrl: nil, itemCount: nil, currentCartCountInApp: nil, isAvailable: true)
                self?.results.append(resultFormat)
            })
            self?.isFetchingMenuItems = false
            self?.isFetchingResults = false
            
                let resultCount = (self?.results.count) ?? 0
                if self?.currentViewType == .results { self?.tableView.isHidden = resultCount == 0 }
                self?.tableView.reloadData()
            }
        }, failure: { _ in
            // No implementation needed
        })
    }
    
    func toggleSearchState(searchBarActive: Bool) {
        self.searchContainer.borderColor = searchBarActive ? AppColors.ExploreMenuScreen.borderColor : .clear
        self.searchContainer.backgroundColor = searchBarActive ? AppColors.ExploreMenuScreen.searhBarBg : .white
    }
    
}

class NumberOfItemsCell: UITableViewCell {
    @IBOutlet weak var itemsCountLabel: UILabel!
}
