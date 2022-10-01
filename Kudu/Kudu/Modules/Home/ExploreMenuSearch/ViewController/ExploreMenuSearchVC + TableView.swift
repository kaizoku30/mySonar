//
//  ExploreMenuSearchVC + TableView.swift
//  Kudu
//
//  Created by Admin on 15/09/22.
//

import UIKit

extension ExploreMenuSearchVC: UITableViewDataSource, UITableViewDelegate {
	
	// MARK: Delegate Methods
	
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
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.section == 1 && currentViewType == .results && isFetchingResults == false && results.count < total && isFetchingMenuItems == false && results.isEmpty == false && isShowingMenuData == false {
			debugPrint("Hit Pagination")
			self.pageNo += 1
			getResults()
		}
	}
	
}

extension ExploreMenuSearchVC {
	
	// MARK: Row Methods
	
	func getRowsForRecentSearchTopCategories() -> Int {
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
	
	func getRowsForSuggestionsAndTopSearchCategories() -> Int {
		//Suggestions
		//Top Categories
		if isFetchingSuggestions {
			return 5
		}
		return 1 + suggestions.count
		
	}
	
}

extension ExploreMenuSearchVC {
	// MARK: Custom Cell Methods
	
	func getTopSearchCategoriesCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: TopSearchCategoriesCell.self)
		cell.configure(topSearchedCategories)
		cell.performOperation = { [weak self] in
            let savedFormat = MenuSearchResultItem(menuId: "", _id: $0._id, titleEnglish: $0.titleEnglish, titleArabic: $0.titleArabic, isCategory: true, isItem: false, descriptionEnglish: nil, descriptionArabic: nil, nameEnglish: nil, nameArabic: nil, itemImageUrl: nil, price: nil, allergicComponent: nil, isCustomised: nil, menuImageUrl: $0.menuImageUrl, itemCount: $0.itemCount, cartCount: 0, isAvailable: true, itemId: nil, calories: nil)
			DataManager.shared.saveToRecentlySearchExploreMenu(savedFormat)
			let title = AppUserDefaults.selectedLanguage() == .en ? $0.titleEnglish ?? "" : $0.titleArabic ?? ""
			self?.getCategoryItems(forMenuId: $0._id ?? "", menuTitle: title)
		}
		return cell
	}
	
	func getCellForRecentSearchTopSuggestions(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		//Check for recent Searches existing
		let row = indexPath.row
		if isFetchingTopSearchCategories {
			let cell = tableView.dequeueCell(with: TopSearchCategoriesShimmer.self)
			return cell
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
	
	func suggestionTableViewCellTapped(result: MenuSearchResultItem) {
		if result.isItem ?? false {
			mainThread {
				
				self.searchTFView.isUserInteractionEnabled = false
				self.clearButton.isUserInteractionEnabled = false
				self.tableView.isUserInteractionEnabled = false
				var templateToLoad: CustomisationTemplate?
				if result.cartCount ?? 0 > 0, result.templates?.count ?? 0 > 0 {
					templateToLoad = result.templates?.last
				}
				DataManager.shared.saveToRecentlySearchExploreMenu(result)
				self.fetchItemDetail(itemId: result._id ?? "", preLoadTemplate: templateToLoad)
			}
		} else {
			DataManager.shared.saveToRecentlySearchExploreMenu(result)
			let id = result._id ?? ""
			let title = AppUserDefaults.selectedLanguage() == .en ? result.titleEnglish ?? "" : result.titleArabic ?? ""
			self.getCategoryItems(forMenuId: id, menuTitle: title)
		}
	}
	
	func getCellForResults(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if isFetchingResults {
			let cell = tableView.dequeueCell(with: ResultShimmerTableViewCell.self)
			return cell
		}
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
			let cell = tableView.dequeueCell(with: ResultShimmerTableViewCell.self)
			return cell
		}
	}
	
	func handleItemCellForResults(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, item: MenuSearchResultItem) -> UITableViewCell {
		if item.isItem ?? false {
			let cell = tableView.dequeueCell(with: ItemTableViewCell.self)
            cell.configure(item, serviceType: self.serviceType)
            cell.cartConflict = { [weak self] in
                self?.showCartConflictAlert($0, $1)
            }
			cell.cartCountUpdated = { [weak self] (count, item) in
				self?.updateCountLocally(count: count, menuItem: item, template: nil)
				//self?.tableView.reloadData()
			}
			cell.confirmCustomisationRepeat = { [weak self] (countToUpdate, item) in
				self?.handleCustomiseRepeat(item: item, count: countToUpdate)
			}
			cell.likeStatusUpdated = { [weak self] (liked, item) in
				if item.templates.isNotNil, let recentTemplate = item.templates?.last {
					//Some template added
					self?.updateLikeStatus(liked, itemId: item._id ?? "", hashId: recentTemplate.hashId ?? "", modGroups: recentTemplate.modGroups ?? [])
				} else {
					//Base Item Behaviour
					let hashIdForBaseItem = MD5Hash.generateHashForTemplate(itemId: item._id ?? "", modGroups: nil)
					self?.updateLikeStatus(liked, itemId: item._id ?? "", hashId: hashIdForBaseItem, modGroups: nil)
				}
			}
			cell.openItemDetailForSearch = { [weak self] (result) in
				guard let strongSelf = self else { return }
				mainThread {
					strongSelf.searchTFView.unfocus()
					if result.isCustomised ?? false {
						strongSelf.searchTFView.isUserInteractionEnabled = false
						strongSelf.clearButton.isUserInteractionEnabled = false
						strongSelf.tableView.isUserInteractionEnabled = false
						var templateToLoad: CustomisationTemplate?
						if result.cartCount ?? 0 > 0, result.templates?.count ?? 0 > 0 {
							templateToLoad = result.templates?.last
						}
						strongSelf.fetchItemDetail(itemId: result._id ?? "", preLoadTemplate: templateToLoad)
					} else {
						self?.openItemDetail(result: result)
					}
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
	
	func getCellForSuggestionsTopCategories(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		//Suggestions
		//One Row for top search categories
		let row = indexPath.row
		if isFetchingSuggestions {
			let cell = tableView.dequeueCell(with: SuggestionShimmerCell.self)
			return cell
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
	
	func getSuggestionTableViewCellForTopSearchCategories(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: SuggestionTableViewCell.self)
		if let item = suggestions[safe: indexPath.row] {
			cell.configure(item)
			cell.performOperation = { [weak self] (result) in
				guard let strongSelf = self else { return }
				if result.isItem ?? false {
					strongSelf.isShowingItemData = true
					strongSelf.searchTFView.isUserInteractionEnabled = false
					strongSelf.clearButton.isUserInteractionEnabled = false
					strongSelf.tableView.isUserInteractionEnabled = false
					var templateToLoad: CustomisationTemplate?
					if result.cartCount ?? 0 > 0, result.templates?.count ?? 0 > 0 {
						templateToLoad = result.templates?.last
					}
					DataManager.shared.saveToRecentlySearchExploreMenu(result)
					strongSelf.fetchItemDetail(itemId: result._id ?? "", preLoadTemplate: templateToLoad)
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
	
}
