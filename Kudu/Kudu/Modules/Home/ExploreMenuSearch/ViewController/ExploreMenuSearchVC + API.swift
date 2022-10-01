//
//  ExploreMenuSearchVC + API.swift
//  Kudu
//
//  Created by Admin on 15/09/22.
//

import UIKit

extension ExploreMenuSearchVC {
	
	func fetchItemDetail(itemId: String, preLoadTemplate: CustomisationTemplate?) {
        self.tabBarController?.addLoaderOverlay()
		APIEndPoints.HomeEndPoints.getItemDetail(itemId: itemId, success: { [weak self] (response) in
			self?.searchTFView.isUserInteractionEnabled = true
			self?.clearButton.isUserInteractionEnabled = true
			self?.itemDetailResponse = response.data?.first
			DataManager.shared.saveToRecentlySearchExploreMenu(MenuSearchResultItem.getFormatForRecentlySearched(forItem: self!.itemDetailResponse!))
			self?.tableView.reloadData()
			self?.tableView.isUserInteractionEnabled = true
			if self?.itemDetailResponse?.isCustomised ?? false {
				self?.openCustomisedItemDetail(result: self?.itemDetailResponse, prefillTempate: preLoadTemplate)
			} else {
				self?.openItemDetail(resultMenuItem: (self?.itemDetailResponse)!)
			}
            self?.tabBarController?.removeLoaderOverlay()
		}, failure: { [weak self] _ in
			//Implementation Pending
            self?.tabBarController?.removeLoaderOverlay()
		})
	}
	
	func updateLikeStatus(_ liked: Bool, itemId: String, hashId: String, modGroups: [ModGroup]?) {
		if liked {
			debugPrint("Added Hash ID \(hashId)")
			DataManager.saveHashIDtoFavourites(hashId)
		} else {
			debugPrint("Removed Hash ID \(hashId)")
			DataManager.removeHashIdFromFavourites(hashId)
		}
        guard let itemIndex = results.firstIndex(where: { $0._id == itemId }) else {
            fatalError("Item Index Error") }
        
		if modGroups.isNotNil {
			results[itemIndex].isFavourites = liked
            self.updateExploreMenu?(results[itemIndex])
		}
        let request = FavouriteRequest(itemId: itemId, hashId: hashId, menuId: results[itemIndex].menuId ?? "", itemSdmId: results[itemIndex].itemId ?? 0, isFavourite: liked, servicesAvailable: self.serviceType, modGroups: modGroups)
		APIEndPoints.HomeEndPoints.hitFavouriteAPI(request: request, success: { (response) in
			debugPrint(response.message ?? "")
		}, failure: { _ in
			debugPrint("Implementation needed")
		})
	}
}

extension ExploreMenuSearchVC {
	
	func getTopSearchCategories() {
		APIEndPoints.HomeEndPoints.getTopSearchedCategories(type: self.serviceType, success: { [weak self] in
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
        APIEndPoints.HomeEndPoints.getSearchSuggestionsMenu(storeId: self.storeId, searchKey: self.textQuery, type: self.serviceType, success: { [weak self] in
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
        APIEndPoints.HomeEndPoints.getSearchResultsMenu(storeId: self.storeId, searchKey: self.textQuery, type: self.serviceType, pageNo: self.pageNo, success: { [weak self] in
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
		APIEndPoints.HomeEndPoints.getMenuItemList(menuId: menuId, success: { [weak self] (response) in
			mainThread {
				self?.results = []
				response.data?.forEach({
                    let resultFormat = MenuSearchResultItem(menuId: $0.menuId ?? "", _id: $0._id, titleEnglish: nil, titleArabic: nil, isCategory: false, isItem: true, descriptionEnglish: $0.descriptionEnglish, descriptionArabic: $0.descriptionArabic, nameEnglish: $0.nameEnglish, nameArabic: $0.nameArabic, itemImageUrl: $0.itemImageUrl, price: $0.price, allergicComponent: $0.allergicComponent, isCustomised: $0.isCustomised, menuImageUrl: nil, itemCount: nil, cartCount: nil, isAvailable: true, itemId: $0.itemId ?? 0, calories: $0.calories)
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
}
