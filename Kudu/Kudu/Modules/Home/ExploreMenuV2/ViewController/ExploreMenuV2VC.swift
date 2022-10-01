//
//  ExploreMenuV2VC.swift
//  Kudu
//
//  Created by Admin on 13/09/22.
//

import UIKit
import NVActivityIndicatorView

class ExploreMenuV2VC: BaseVC {
    
    @IBOutlet var baseView: ExploreMenuV2View!
    var viewModel: ExploreMenuV2VM!
    
    private var viewSet = false
    private var scrollMetrics = ExploreMenuViewScrollMetrics()
    private var previousIndex: Int = 0
    private var queueScroll = false
    private var reloadCurrentColumn = false
    private var isFetchingItemData = true
    private var menuLookUpID: String?
    private var itemLookUpID: String?
    private var itemIdAssociatedMenuId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleViewActions()
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewSet == false {
            setContent()
            viewSet = true
        }
    }
    
    private func addObservers() {
        self.observeFor(.itemCountUpdatedFromCart, selector: #selector(handleItemUpdate(notification:)))
        self.observeFor(.favouriteStateUpdatedFromCart, selector: #selector(handleItemFavourite))
        self.observeFor(.clearCartEverywhere, selector: #selector(clearCartRef))
    }
    
    @objc private func clearCartRef() {
       self.viewModel.updateQueueScrollIndex(index: self.scrollMetrics.currentColumnIndex)
       checkContent()
    }
    
    @objc private func handleItemFavourite() {
        weak var cell = self.baseView.mainTableView.visibleCells.last as? ContentContainerTableViewCell
        cell?.refreshTable()
    }
    
    @objc private func handleItemUpdate(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let update = CartCountNotifier.getFromUserInfo(userInfo)
            if update.serviceType == viewModel.getServiceType {
                guard let menuIndex = viewModel.getCategories.firstIndex(where: { $0._id ?? "" == update.menuId }) else { return }
                guard let columnData = viewModel.getColumnData[safe: menuIndex], columnData.firstIndex(where: { $0._id ?? "" == update.itemId }).isNotNil else { return }
                //Service type found, menu found, item found
                //Update count first in viewModel
                guard let syncSuccess = viewModel.syncWithCart(menuId: update.menuId, itemId: update.itemId, hashId: update.hashId, increment: update.isIncrement, modGroups: update.modGroups) else { return }
                weak var cell = self.baseView.mainTableView.visibleCells.last as? ContentContainerTableViewCell
                cell?.columnData = syncSuccess
                cell?.refreshTable()
            }
        }
    }
    
    func updateQueueScrollIndex(_ index: Int?) {
        viewModel.updateQueueScrollIndex(index: index)
    }
    
    func updateMenuLookUp(menuId: String) {
        self.menuLookUpID = menuId
    }
    
    func updateItemLookUp(itemId: String, itemIdAssociatedMenuId: String) {
        self.itemLookUpID = itemId
        self.itemIdAssociatedMenuId = itemIdAssociatedMenuId
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // MARK: IMPORTANT NOTE
        // Called everytime we switch tabs so need of methods on Tab bar level
        if viewSet || self.menuLookUpID.isNotNil || self.itemLookUpID.isNotNil {
            // No need to call if view is not even set yet
            checkContent()
        }
        self.baseView.refreshCartLocally()
    }
    
    private func checkContent() {
        //Called everytime we bring menu in focus
        //First check if some auto scroll index has been queued up
        //Would definitely mean coming from Home only -- with specific category index selected
        //Also this is the case when view has once appeared already
        //Only check that needs to be done is for service type change
        //That automatically happens at viewmodel level in fetchContent
        if self.viewModel.getQueueScrollIndex.isNotNil || self.menuLookUpID.isNotNil || self.itemLookUpID.isNotNil {
            self.isFetchingItemData = true
            self.baseView.mainTableView.reloadData()
            setContent()
        } else {
            // Okay no auto scroll at this point, but we should make a check for delivery clash
            self.viewModel.refreshViewModel(someConflictOccured: {
                //Some conflict occured
                //Reset All Content
                self.isFetchingItemData = true
                self.baseView.mainTableView.reloadData()
                self.updateQueueScrollIndex(0)
                self.setContent()
            })
            // If Refresh check
        }
    }
    
    private func setContent() {
        // Called when menu brought into the app for the first time ever || One case where auto scroll queued up from home tab selection
        /*
         Cases :
         1. Direct tap -- service type could be != delivery, startIndex = 0 (viewDidAppear, viewSet flow)
         2. Coming from profile -- service type could be != delivery (depends on home selection), startIndex = 0
         3. Coming from Our Store -- service could be == pickup||curbsidel, startIndex = 0
         4. Coming from home -- cart cleared - explore menu -- service could be any, startIndex = 0
         */
        viewModel.refreshViewModel() //Update handling if coming from the home tab selection
        //Fetching data for the first time ever --- categories, items --- everything does not exist at this point
        
        //With Index Cases :
        /*
         Cases :
         1.Coming from home only possible to come to this page for the first time ever with some index
         */
        fetchContent()
    }
    
    private func fetchContent() {
        self.previousIndex = 0
        self.baseView.toggleBrowseMenu(show: false)
        viewModel.fetchAllItemTableData(completedFetching: { [weak self] in
            if $0 {
                self?.isFetchingItemData = false
                self?.scrollMetrics = self?.viewModel.calculateScrollMetrics() ?? ExploreMenuViewScrollMetrics()
                let menuLookUpID = self?.menuLookUpID ?? ""
                let itemLookUpID = self?.itemLookUpID ?? ""
                let associatedMenuWithItem = self?.itemIdAssociatedMenuId ?? ""
                if !menuLookUpID.isEmpty || !itemLookUpID.isEmpty {
                    
                    self?.menuLookUpID = nil
                    self?.itemLookUpID = nil
                    self?.itemIdAssociatedMenuId = nil
                    
                    if let lookUpIndexForMenu = self?.viewModel.getCategories.firstIndex(where: { $0._id ?? "" == menuLookUpID }) {
                        self?.viewModel.updateQueueScrollIndex(index: lookUpIndexForMenu)
                    }
                    if !itemLookUpID.isEmpty {
                        var requiredColumn: Int?
                        var requiredItemIndex: Int?
                        requiredColumn = self?.viewModel.getCategories.firstIndex(where: { $0._id ?? "" == associatedMenuWithItem })
                        if let columnFound = requiredColumn {
                            requiredItemIndex = self?.viewModel.getColumnData[columnFound].firstIndex(where: { $0._id ?? "" == itemLookUpID})
                        }
                        if requiredColumn.isNotNil && requiredItemIndex.isNotNil {
                            self?.viewModel.updateQueueScrollIndex(index: requiredColumn!)
                            if let result = self?.viewModel.getColumnData[requiredColumn!][requiredItemIndex!] {
                                mainThread {
                                    guard let strongSelf = self else { return }
                                    if result.isCustomised ?? false {
                                        var templateToLoad: CustomisationTemplate?
                                        if result.cartCount ?? 0 > 0, result.templates?.count ?? 0 > 0 {
                                            templateToLoad = result.templates?.last
                                        }
                                        
                                        //  strongSelf.tabBarController?.addLoaderOverlay()
                                        
                                        strongSelf.viewModel?.fetchItemDetail(itemId: result._id ?? "", preLoadTemplate: templateToLoad, tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0, result: { [weak self] (responseType, _) in
                                            //self?.triggerReload()
                                            switch responseType {
                                            case .success(let template):
                                                self?.openCustomisedItemDetail(result: self?.viewModel.getItemDetailResponse, prefillTempate: template, tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0)
                                                //self?.tabBarController?.removeLoaderOverlay()
                                            case .failure(let error):
                                                debugPrint(error.localizedDescription)
                                                debugPrint("Need to show error")
                                                //self?.tabBarController?.removeLoaderOverlay()
                                            }
                                        })
                                    } else {
                                        strongSelf.openItemDetail(result: result)
                                    }
                                }
                            }
                        }
                    }
                }
                if self?.viewModel.getQueueScrollIndex.isNotNil ?? false {
                    self?.queueScroll = true
                    self?.scrollMetrics.currentColumnIndex = self?.viewModel.getQueueScrollIndex ?? 0
                }
                self?.baseView.showTableView(true)
                debugPrint("Completed Fetching and showing Menu")
                let categories = self?.viewModel.getCategories ?? []
                categories.forEach({ _ in
                    self?.scrollMetrics.columnOffsetArray.append(0)
                })
                self?.baseView.refreshCartLocally()
            } else {
                self?.baseView.showTableView(false)
                debugPrint("Some error occured while fetching on VC")
            }
        })
    }
    
    private func handleViewActions() {
        baseView.handleViewActions = { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .backButtonPressed:
                strongSelf.pop()
            case .browseMenuTapped:
                strongSelf.browseMenuTapped()
            case .searchButtonPressed:
                strongSelf.goToSearchVC()
            case .viewCart:
                strongSelf.viewCartPressed()
            case .handleCartConflict(let count, let item, let template):
                strongSelf.updateCartConflict(count, item, template)
            }
        }
    }
    
    private func updateCartConflict(_ count: Int, _ item: MenuItem, _ template: CustomisationTemplate?) {
        self.viewModel.updateCountLocally(count: count, menuItem: item, template: template, tableIndex: self.scrollMetrics.currentColumnIndex)
        self.triggerReload()
        self.baseView.refreshCartLocally()
    }
}

extension ExploreMenuV2VC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isFetchingItemData {
            return indexPath.section == 0 ? tableView.height : 0
        } else {
            return indexPath.section == 0 ? 89 : scrollMetrics.maxHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isFetchingItemData {
            if indexPath.section == 0 {
                let cell = tableView.dequeueCell(with: ShimmerExploreCell.self)
                cell.configure()
                return cell
            } else {
                return UITableViewCell()
            }
        }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueCell(with: FilterContainerTableViewCell.self, indexPath: indexPath)
            cell.selectedIndex = { [weak self] (index) in
                self?.queueScroll = true
                self?.scrollMetrics.columnOffsetArray[index] = 0
                self?.previousIndex = self?.scrollMetrics.currentColumnIndex ?? 0
                self?.scrollMetrics.currentColumnIndex = index
                self?.viewModel.updateQueueScrollIndex(index: index)
                self?.baseView.updateFilters()
            }
            cell.configure(filterArray: viewModel.getCategories, selectedCategoryIndex: scrollMetrics.currentColumnIndex, previousIndex: self.previousIndex)
            return cell
        } else {
            let cell = tableView.dequeueCell(with: ContentContainerTableViewCell.self, indexPath: indexPath)
            manageContentCellOperations(cell: cell)
            return cell
        }
    }
    
}

extension ExploreMenuV2VC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isFetchingItemData {
            return
        }
        if scrollView.contentOffset.y >= 89 {
            self.baseView.toggleBrowseMenu(show: true)
        } else {
            self.baseView.toggleBrowseMenu(show: false)
        }
        
        let currentIndex = scrollMetrics.currentColumnIndex
        let count = viewModel.getColumnData[currentIndex].count
        let columnHeight = CGFloat(count * 197)
        let contentContainerHeight = scrollView.height - 89
        if columnHeight < scrollMetrics.maxHeight && columnHeight > contentContainerHeight {
            let partOfContentUnderTheView = columnHeight - contentContainerHeight
            if partOfContentUnderTheView <= 89 {
                if scrollView.contentOffset.y >= 89 {
                    scrollView.contentOffset.y = 89
                    scrollMetrics.columnOffsetArray[currentIndex] = 89
                    return
                }
            } else {
                if scrollView.contentOffset.y >= partOfContentUnderTheView {
                    scrollView.contentOffset.y = partOfContentUnderTheView
                    scrollMetrics.columnOffsetArray[currentIndex] = partOfContentUnderTheView
                    self.baseView.triggerAnimationBrowseMenu(show: true)
                    return
                } else {
                    self.baseView.triggerAnimationBrowseMenu(show: false)
                }
            }
        }
        
        if columnHeight == scrollMetrics.maxHeight {
            let partOfContentUnderTheView = columnHeight - contentContainerHeight
            if scrollView.contentOffset.y >= partOfContentUnderTheView {
                scrollView.contentOffset.y = partOfContentUnderTheView
                scrollMetrics.columnOffsetArray[currentIndex] = partOfContentUnderTheView
                self.baseView.triggerAnimationBrowseMenu(show: true)
                return
            } else {
                self.baseView.triggerAnimationBrowseMenu(show: false)
            }
        }
        
        if columnHeight < contentContainerHeight {
            if scrollView.contentOffset.y >= 89 {
                scrollView.contentOffset.y = 89
                scrollMetrics.columnOffsetArray[currentIndex] = 89
                return
            }
        }
        
        scrollMetrics.columnOffsetArray[currentIndex] = scrollView.contentOffset.y
    }
}

extension ExploreMenuV2VC {
    private func browseMenuTapped() {
        guard let baseView = self.baseView else { return }
        let copy = self.scrollMetrics.columnOffsetArray
        for index in copy.indices {
            self.scrollMetrics.columnOffsetArray[index] = 0
        }
        let browseView = BrowseMenuView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        mainThread {
            HapticFeedbackGenerator.triggerVibration(type: .lightTap)
            browseView.configure(categories: self.viewModel.getCategories, container: baseView, browseMenuButtonFrame: self.baseView.browseMenuButton.frame)
        }
        browseView.categorySelected = { [weak self] (index) in
            mainThread {
                self?.queueScroll = true
                self?.scrollMetrics.columnOffsetArray[index] = 0
                self?.previousIndex = self?.scrollMetrics.currentColumnIndex ?? 0
                self?.scrollMetrics.currentColumnIndex = index
                self?.viewModel.updateQueueScrollIndex(index: index)
                self?.baseView.mainTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                self?.baseView.updateFilters()
            }
        }
    }
}

extension ExploreMenuV2VC {
    private func manageContentCellOperations(cell: ContentContainerTableViewCell) {
        if reloadCurrentColumn == true {
            reloadCurrentColumn = false
        }
        cell.cellSwipedToIndex = { [weak self] (newIndex) in
            self?.scrollMetrics.currentColumnIndex = newIndex
            weak var tableview = self?.baseView.mainTableView
            weak var cell = tableview?.cellForRow(at: IndexPath(item: 0, section: 0)) as? FilterContainerTableViewCell
            cell?.configure(filterArray: self?.viewModel.getCategories ?? [], selectedCategoryIndex: self?.scrollMetrics.currentColumnIndex ?? 0)
            let offSetRetained = self?.scrollMetrics.columnOffsetArray[newIndex] ?? 0
            self?.baseView.mainTableView.setContentOffset(CGPoint(x: 0, y: offSetRetained), animated: true)
        }
        cell.queueScrollComplete = { [weak self] in
            self?.queueScroll = false
            self?.viewModel.updateQueueScrollIndex(index: nil)
        }
        cell.cartConflict = { [weak self] in
            self?.baseView.showCartConflictAlert($0, $1)
        }
        cell.triggerLoginFlow = { [weak self] in
            let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
            loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
            self?.push(vc: loginVC)
        }
        cell.likeStatusUpdated = { [weak self] (liked, item, _) in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            if item.templates.isNotNil, let recentTemplate = item.templates?.last {
                //Some template added
                viewModel.updateLikeStatus(liked, itemId: item._id ?? "", hashId: recentTemplate.hashId ?? "", modGroups: recentTemplate.modGroups ?? [], tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0, likeFailed: { (msg) in
                    self?.baseView.showError(msg: msg)
                })
            } else {
                //Base Item Behaviour
                let hashIdForBaseItem = MD5Hash.generateHashForTemplate(itemId: item._id ?? "", modGroups: nil)
                viewModel.updateLikeStatus(liked, itemId: item._id ?? "", hashId: hashIdForBaseItem, modGroups: nil, tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0, likeFailed: { (msg) in
                    self?.baseView.showError(msg: msg)
                })
            }
            self?.triggerReload()
        }
        cell.openItemDetail = { [weak self] (result, _) in
            guard let strongSelf = self else { return }
            mainThread {
                guard let category = strongSelf.viewModel.getCategories.firstIndex(where: { $0._id ?? "" == result.menuId ?? ""}), let column = strongSelf.viewModel.getColumnData[safe: category], let resultFound = column.first(where: { $0._id ?? "" == result._id ?? "" }) else { return }
                let result = resultFound
                if result.isCustomised ?? false {
                    var templateToLoad: CustomisationTemplate?
                    if result.cartCount ?? 0 > 0, result.templates?.count ?? 0 > 0 {
                        templateToLoad = result.templates?.last
                    }
                    
                    strongSelf.tabBarController?.addLoaderOverlay()
                    
                    strongSelf.viewModel?.fetchItemDetail(itemId: result._id ?? "", preLoadTemplate: templateToLoad, tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0, result: { [weak self] (responseType, _) in
                        self?.triggerReload()
                        switch responseType {
                        case .success(let template):
                            self?.openCustomisedItemDetail(result: self?.viewModel.getItemDetailResponse, prefillTempate: template, tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0)
                            self?.tabBarController?.removeLoaderOverlay()
                        case .failure(let error):
                            debugPrint(error.localizedDescription)
                            debugPrint("Need to show error")
                            self?.tabBarController?.removeLoaderOverlay()
                        }
                    })
                } else {
                    strongSelf.openItemDetail(result: result)
                }
            }
        }
        cell.cartCountUpdated = { [weak self] (count, item, _) in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            viewModel.updateCountLocally(count: count, menuItem: item, template: nil, tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0)
            //strongSelf.triggerReload()
            strongSelf.baseView.refreshCartLocally()
        }
        cell.confirmCustomisationRepeat = { [weak self] (countToUpdate, item, _) in
            guard let strongSelf = self else { return }
            strongSelf.handleCustomiseRepeat(item: item, count: countToUpdate, tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0)
        }
        cell.configure(categories: viewModel.getCategories, columnData: viewModel.getColumnData, metrics: scrollMetrics, queueScroll: self.queueScroll, reloadData: reloadCurrentColumn, serviceType: self.viewModel.getServiceType)
    }
}

extension ExploreMenuV2VC {
    private func openItemDetail(result: MenuItem) {
        let vc = BaseVC()
        vc.configureForCustomView()
        self.tabBarController?.addOverlayBlack()
        let bottomSheet = ItemDetailView(frame: CGRect(x: 0, y: 0, width: self.baseView.width, height: self.baseView.height))
        bottomSheet.triggerLoginFlow = { [weak self] in
            vc.dismiss(animated: true, completion: { [weak self] in
                self?.tabBarController?.removeOverlay()
                let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                self?.push(vc: loginVC)
            })
        }
        bottomSheet.configureForExploreMenu(container: vc.view, itemId: result._id ?? "", serviceType: self.viewModel.getServiceType)
        bottomSheet.cartCountUpdated = { [weak self] (count, item) in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            viewModel.updateCountLocally(count: count, menuItem: item, template: nil, tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0)
            strongSelf.triggerReload()
            strongSelf.baseView.refreshCartLocally()
        }
        bottomSheet.handleDeallocation = {
            vc.dismiss(animated: true, completion: { [weak self] in
                self?.tabBarController?.removeOverlay()
            })
        }
        self.present(vc, animated: true)
    }
    
    private func openCustomisedItemDetail(result: MenuItem?, prefillTempate: CustomisationTemplate? = nil, tableIndex: Int) {
        if let result = result {
            mainThread {
                let vc = BaseVC()
                vc.configureForCustomView()
                let bottomSheet = CustomisableItemDetailView(frame: CGRect(x: 0, y: 0, width: self.baseView.width, height: self.baseView.height))
                bottomSheet.configure(item: result, container: vc.view, preLoadTemplate: prefillTempate, serviceType: self.viewModel.getServiceType)
                bottomSheet.addToCart = { [weak self] (modGroupArray, hashId, itemId) in
                    
                    if AppUserDefaults.value(forKey: .loginResponse).isNil {
                        let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                        loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                        self?.push(vc: loginVC)
                        return
                    }
                    
                    guard let strongSelf = self, let table = strongSelf.viewModel?.getColumnData[self?.scrollMetrics.currentColumnIndex ?? 0], let itemIndex = table.firstIndex(where: { $0._id ?? "" == itemId}) else {
                        return
                    }
                    let item = table[itemIndex]
                    let template = CustomisationTemplate(modGroups: modGroupArray, hashId: hashId)
                    strongSelf.viewModel?.updateCountLocally(count: (item.cartCount ?? 0) + 1, menuItem: item, template: template, tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0)
                    strongSelf.triggerReload()
                    strongSelf.baseView.refreshCartLocally()
                }
                bottomSheet.handleDeallocation = { [weak self] in
                    vc.dismiss(animated: true, completion: {
                        self?.tabBarController?.removeOverlay()
                    })
                }
                self.tabBarController?.addOverlayBlack()
                self.present(vc, animated: true)
            }
        }
    }
    
    private func handleCustomiseRepeat(item: MenuItem, count: Int, tableIndex: Int) {
        self.triggerReload()
        let popUp = RepeatCustomisationView(frame: CGRect(x: 0, y: 0, width: self.baseView.width - AppPopUpView.HorizontalPadding, height: 0))
        popUp.configure(container: self.baseView)
        popUp.handleAction = { [weak self] (action) in
            mainThread {
                if action == .repeatCustomisation {
                    self?.viewModel?.updateCountLocally(count: count, menuItem: item, template: item.templates?.last, tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0)
                    self?.triggerReload()
                    self?.baseView.refreshCartLocally()
                } else {
                    //No Customisation
                    self?.viewModel?.fetchItemDetail(itemId: item._id ?? "", preLoadTemplate: nil, tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0, result: { [weak self] (responseType, _) in
                        self?.triggerReload()
                        switch responseType {
                        case .success(let template):
                            self?.openCustomisedItemDetail(result: self?.viewModel.getItemDetailResponse, prefillTempate: template, tableIndex: self?.scrollMetrics.currentColumnIndex ?? 0)
                        case .failure(let error):
                            debugPrint(error.localizedDescription)
                            debugPrint("Need to show error")
                        }
                    })
                }
            }
        }
    }
}

extension ExploreMenuV2VC {
    private func goToSearchVC() {
        let exploreSearchVC = ExploreMenuSearchVC.instantiate(fromAppStoryboard: .Home)
        exploreSearchVC.serviceType = self.viewModel.getServiceType
        exploreSearchVC.storeId = self.viewModel.getStoreId
        exploreSearchVC.updateExploreMenu = { [weak self] (itemToUpdate) in
            self?.viewModel.syncWithExploreSearch(object: itemToUpdate)
            self?.triggerReload()
        }
        self.push(vc: exploreSearchVC)
    }
}

extension ExploreMenuV2VC {
    private func viewCartPressed() {
        let vc = CartListViewController.instantiate(fromAppStoryboard: .CartPayment)
        vc.flow = .fromExplore
        self.push(vc: vc)
    }
}

extension ExploreMenuV2VC {
    
    private func triggerReload() {
        mainThread {
            if self.isFetchingItemData { return }
            weak var tableview = self.baseView.mainTableView
            weak var cell = tableview?.cellForRow(at: IndexPath(row: 0, section: 1)) as? ContentContainerTableViewCell
            cell?.columnData = self.viewModel.getColumnData
            cell?.metrics = self.scrollMetrics
            cell?.refreshTable()
            self.baseView.refreshCartLocally()
        }
    }
}
