//
//  ExploreMenuVC.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import UIKit

class ExploreMenuVC: BaseVC {
    @IBOutlet weak private var baseView: ExploreMenuView!
    var viewModel: ExploreMenuVM?
    private var recentMenuItemForAction: [Int: MenuItem] = [:]
    private var lastCellOfInterest: [Int] = []
    override func viewDidLoad() {
        super.viewDidLoad()
		let fallBackIndex = AppUserDefaults.selectedLanguage() == .en ? 0 : ((viewModel?.getMenuCategories?.count) ?? 0) - 1
        self.baseView.setup(categories: viewModel?.getMenuCategories ?? [], selectedIndex: viewModel?.getIndexToStart ?? fallBackIndex)
        viewModel?.getMenuCategories?.forEach({ _ in 
            lastCellOfInterest.append(0)
        })
        viewModel?.fetchMenuItems(selectedIndex: viewModel?.getIndexToStart ?? fallBackIndex)
        baseView.handleAPIRequest(.itemList, reloadIndexPath: IndexPath(item: viewModel?.getIndexToStart ?? fallBackIndex, section: 0))
        handleActions()
        addObservers()
    }
    
    private func addObservers() {
        self.observeFor(.updateLikeStatus, selector: #selector(updateArrayForLike(notification:)))
    }
    
    @objc private func updateArrayForLike(notification: NSNotification) {
//            let itemToUpdate = notification.userInfo?["item"] as? MenuItem
//            let likeStatus = notification.userInfo?["isFavourites"] as? Bool
//            if let itemToUpdate = itemToUpdate, let likeStatus = likeStatus {
//                self.viewModel?.updateLikeStatusLocally(item: itemToUpdate, isLiked: likeStatus)
//                self.baseView.refreshTableView()
//            }
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            switch $0 {
            case .backButtonPressed:
                self?.pop()
            case .searchButtonPressed:
                let exploreSearchVC = ExploreMenuSearchVC.instantiate(fromAppStoryboard: .Home)
                self?.push(vc: exploreSearchVC)
            case .browseMenuTapped:
                guard let baseView = self?.baseView else { return }
                let browseView = BrowseMenuView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                mainThread {
					HapticFeedbackGenerator.triggerVibration(type: .lightTap)
					browseView.configure(categories: self?.viewModel?.getMenuCategories ?? [], container: baseView, browseMenuButtonFrame: self?.baseView.browseMenuButton.frame ?? CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: 0)))
                }
                browseView.categorySelected = { [weak self] (index) in
                    mainThread {
                        self?.baseView.filterSelected(index: index)
                    }
                    self?.viewModel?.fetchMenuItems(selectedIndex: index)
                    self?.baseView.handleAPIRequest(.itemList, reloadIndexPath: IndexPath(item: index, section: 0))
                }
            }
        }
    }
    
}

extension ExploreMenuVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if baseView.checkCollection(collectionView) == .tables {
            return getCellForVerticalList(collectionView, cellForItemAt: indexPath)
        }
        
        let cell = collectionView.dequeueCell(with: ExploreMenuCategoryCollectionViewCell.self, indexPath: indexPath)
        if indexPath.row < (viewModel?.getMenuCategories ?? []).count {
            let item = viewModel!.getMenuCategories![indexPath.row]
            let scrolling = baseView.getScrollMetrics.scrolling
            let currentScrollIndex = baseView.getScrollMetrics.currentPage
            let selected = scrolling ? false : indexPath.row == currentScrollIndex
            cell.configure(item: item, selected: selected)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel?.getMenuCategories ?? []).count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if baseView.checkCollection(collectionView) == .tables {
            return
        }
        
        if indexPath.item < (viewModel?.getMenuCategories ?? []).count {
            baseView.filterSelected(index: indexPath.item)
            viewModel?.fetchMenuItems(selectedIndex: indexPath.item)
            baseView.handleAPIRequest(.itemList, reloadIndexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if baseView.checkCollection(collectionView) == .tables {
            return CGSize(width: collectionView.width, height: collectionView.height)
        }
        let widths = baseView.getScrollMetrics.itemSpecificWidthArray
        if indexPath.item >= widths.count { return CGSize.zero }
        return CGSize(width: widths[indexPath.row], height: 89)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

extension ExploreMenuVC {
    private func getCellForVerticalList(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: ExploreMenuVerticalListCell.self, indexPath: indexPath)
        guard let viewModel = self.viewModel, indexPath.item < viewModel.getItemTableData.count else { return cell }
        let recentItem = self.recentMenuItemForAction[indexPath.item]
        cell.configure(data: viewModel.getItemTableData[indexPath.item], tableIndex: indexPath.item, recentMenuItemForAction: recentItem)
		cell.scrollBrowseMenu = { [weak self] (show) in
			self?.baseView.scrollBrowseMenu(show: show)
		}
		cell.scrolled = { [weak self] (tableIndex) in
			self?.recentMenuItemForAction.removeValue(forKey: tableIndex)
		}
        cell.openItemDetail = { [weak self] (result, tableIndex) in
            guard let strongSelf = self else { return }
            mainThread {
                self?.recentMenuItemForAction[tableIndex] = result
                if result.isCustomised ?? false {
                    strongSelf.baseView.handleAPIRequest(.itemDetail, reloadIndexPath: IndexPath(item: tableIndex, section: 0))
                    var templateToLoad: CustomisationTemplate?
                    if result.cartCount ?? 0 > 0, result.templates?.count ?? 0 > 0 {
                        templateToLoad = result.templates?.last
                    }
                    strongSelf.viewModel?.fetchItemDetail(itemId: result._id ?? "", preLoadTemplate: templateToLoad, tableIndex: tableIndex)
                } else {
                    strongSelf.openItemDetail(result: result)
                }
            }
        }
        cell.cartCountUpdated = { [weak self] (count, item, tableIndex) in
            self?.recentMenuItemForAction[tableIndex] = item
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            viewModel.updateCountLocally(count: count, menuItem: item, template: nil, tableIndex: tableIndex)
            strongSelf.baseView.refreshTableViews(indexPath: IndexPath(item: tableIndex, section: 0))
        }
        cell.confirmCustomisationRepeat = { [weak self] (countToUpdate, item, tableIndex) in
            self?.recentMenuItemForAction[tableIndex] = item
            guard let strongSelf = self else { return }
            strongSelf.handleCustomiseRepeat(item: item, count: countToUpdate, tableIndex: tableIndex)
        }
        
        cell.likeStatusUpdated = { [weak self] (liked, item, tableIndex) in
            self?.recentMenuItemForAction[tableIndex] = item
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
            if item.templates.isNotNil, let recentTemplate = item.templates?.last {
                //Some template added
                viewModel.updateLikeStatus(liked, itemId: item._id ?? "", hashId: recentTemplate.hashId ?? "", modGroups: recentTemplate.modGroups ?? [], tableIndex: tableIndex)
            } else {
                //Base Item Behaviour
                let hashIdForBaseItem = MD5Hash.generateHashForTemplate(itemId: item._id ?? "", modGroups: nil)
                viewModel.updateLikeStatus(liked, itemId: item._id ?? "", hashId: hashIdForBaseItem, modGroups: nil, tableIndex: tableIndex)
            }
        }
        cell.triggerLoginFlow = { [weak self] in
            let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
            loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
            self?.push(vc: loginVC)
        }
        return cell
    }
}

extension ExploreMenuVC: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        if self.baseView.checkCollection(collectionView) == .tables {
            self.baseView.scrolViewWillBeginDragging(scrollView: scrollView)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        if self.baseView.checkCollection(collectionView) == .tables {
            self.baseView.synchronizeScrollView(scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        if self.baseView.checkCollection(collectionView) == .tables {
            self.baseView.scrollViewWillEndDeaccelerating(scrollView: scrollView)
            viewModel?.fetchMenuItems(selectedIndex: self.baseView.getScrollMetrics.currentPage)
            let itemCount = viewModel?.getItemTableData[self.baseView.getScrollMetrics.currentPage].count ?? 0
            if itemCount == 0 {
                baseView.handleAPIRequest(.itemList, reloadIndexPath: IndexPath(item: self.baseView.getScrollMetrics.currentPage, section: 0))
            }
        }
    }

}

extension ExploreMenuVC {
    
    private func handleCustomiseRepeat(item: MenuItem, count: Int, tableIndex: Int) {
        self.baseView.refreshTableViews(indexPath: IndexPath(item: tableIndex, section: 0))
        let popUp = RepeatCustomisationView(frame: CGRect(x: 0, y: 0, width: self.baseView.width - AppPopUpView.HorizontalPadding, height: 0))
        popUp.configure(container: self.baseView)
        popUp.handleAction = { [weak self] (action) in
            mainThread {
                if action == .repeatCustomisation {
                    self?.viewModel?.updateCountLocally(count: count, menuItem: item, template: item.templates?.last, tableIndex: tableIndex)
                    self?.baseView.refreshTableViews(indexPath: IndexPath(item: tableIndex, section: 0))
                } else {
                    //No Customisation
                    self?.baseView.handleAPIRequest(.itemDetail, reloadIndexPath: IndexPath(item: tableIndex, section: 0))
                    self?.viewModel?.fetchItemDetail(itemId: item._id ?? "", preLoadTemplate: nil, tableIndex: tableIndex)
                }
            }
        }
    }
    
    private func openItemDetail(result: MenuItem) {
        let bottomSheet = ItemDetailView(frame: CGRect(x: 0, y: 0, width: self.baseView.width, height: self.baseView.height))
        //bottomSheet.configure(container: self.baseView, item: result, serviceType: self.s)
    }
    
    private func openCustomisedItemDetail(result: MenuItem?, prefillTempate: CustomisationTemplate? = nil, tableIndex: Int) {
        if let result = result {
            mainThread {
                let bottomSheet = CustomisableItemDetailView(frame: CGRect(x: 0, y: 0, width: self.baseView.width, height: self.baseView.height))
               // bottomSheet.configure(item: result, container: self.baseView, preLoadTemplate: prefillTempate)
                bottomSheet.addToCart = { [weak self] (modGroupArray, hashId, itemId) in
                    
                    if AppUserDefaults.value(forKey: .loginResponse).isNil {
                        let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
                        loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
                        self?.push(vc: loginVC)
                        self?.baseView.refreshTableViews(indexPath: IndexPath(item: tableIndex, section: 0))
                        return
                    }
                    
                    guard let strongSelf = self, let table = strongSelf.viewModel?.getItemTableData[tableIndex], let itemIndex = table.firstIndex(where: { $0._id ?? "" == itemId}) else {
                        return
                    }
                    let item = table[itemIndex]
                    strongSelf.viewModel?.updateCountLocally(count: (item.cartCount ?? 0) + 1, menuItem: item, template: CustomisationTemplate(modGroups: modGroupArray, hashId: hashId), tableIndex: tableIndex)
                    strongSelf.baseView.refreshTableViews(indexPath: IndexPath(item: tableIndex, section: 0))
                }
            }
        }
    }
}

extension ExploreMenuVC: ExploreMenuVMDelegate {
    
    func itemListAPIResponse(responseType: Result<String, Error>, index: Int) {
        switch responseType {
        case .success(let string):
            baseView.handleAPIResponse(.itemList, isSuccess: true, errorMsg: nil, reloadIndexPath: IndexPath(item: index, section: 0))
        case .failure(let error):
            baseView.handleAPIResponse(.itemList, isSuccess: false, errorMsg: error.localizedDescription, reloadIndexPath: IndexPath(item: index, section: 0))
        }
    }
    
    func itemDetailAPIResponse(responseType: Result<CustomisationTemplate?, Error>, index: Int) {
        switch responseType {
        case .success(let template):
            baseView.handleAPIResponse(.itemDetail, isSuccess: true, errorMsg: nil, reloadIndexPath: IndexPath(item: index, section: 0))
            self.openCustomisedItemDetail(result: self.viewModel?.getItemDetailResponse, prefillTempate: template, tableIndex: self.viewModel?.getItemDetailTableIndex ?? 0)
        case .failure(let error):
            baseView.handleAPIResponse(.itemDetail, isSuccess: false, errorMsg: error.localizedDescription, reloadIndexPath: IndexPath(item: index, section: 0))
        }
    }
}
