//
//  ExploreMenuSearchVC + Cart.swift
//  Kudu
//
//  Created by Admin on 15/09/22.
//

import UIKit

extension ExploreMenuSearchVC {
    
	func updateCountLocally(count: Int, menuItem: MenuItem, template: CustomisationTemplate?) {
        
        var arrayToSearch: [MenuSearchResultItem] = []
        switch self.currentViewType {
        case .recentSearchTopCategories:
            arrayToSearch = self.recentSearches
        case .results:
            arrayToSearch = self.results
        case .suggestionAndTopCategories:
            arrayToSearch = self.suggestions
        }
        
		guard let index = arrayToSearch.firstIndex(where: { $0._id ?? "" == menuItem._id ?? "" }) else { return }
		var oldCount = arrayToSearch[index].cartCount ?? 0
        var newCount = count
        if self.currentViewType == .recentSearchTopCategories || self.currentViewType == .suggestionAndTopCategories {
            let hashIdToConsider = template?.hashId ?? "" != "" ? template!.hashId! : MD5Hash.generateHashForTemplate(itemId: menuItem._id ?? "", modGroups: nil)
            oldCount = CartUtility.fetchCartLocally().first(where: { $0.hashId ?? "" == hashIdToConsider})?.quantity ?? 0
            if oldCount >= 1 && newCount == 1 && menuItem.isCustomised ?? false == true {
                newCount = oldCount + 1
            }
        }
		
		if newCount > oldCount, let template = template {
			// Addition, Means Base Item
            arrayToSearch[index].cartCount = newCount
			var array = arrayToSearch[index].templates ?? []
			var templateCount = (array.filter({ $0.hashId ?? "" == template.hashId ?? ""})).count
			array.append(template)
            arrayToSearch[index].templates = array
            if self.currentViewType == .recentSearchTopCategories || self.currentViewType == .suggestionAndTopCategories {
                templateCount = oldCount
            }
           // self.updateExploreMenu?(arrayToSearch[index])
			if templateCount == 0 {
                addToCart(menuItem: menuItem, template: template, menuUpdate: arrayToSearch[index])
			} else {
                CartUtility.updateCartCountRemotely(menuItem: menuItem, hashId: template.hashId ?? "", isIncrement: true, quantity: newCount, completion: { [weak self] in
                    self?.handleUpdateCallback(result: $0, menuUpdate: arrayToSearch[index], hashId: template.hashId ?? "", isIncrement: true, modGroups: template.modGroups)
                })
			}
			debugPrint("Count updated to \(newCount) for item : \(menuItem.nameEnglish ?? ""), added template with hashId : \(template.hashId ?? "")")
			
		} else {
			guard let item = arrayToSearch[safe: index] else { return }
            arrayToSearch[index].cartCount = newCount
			debugPrint("Count updated to \(newCount) for item : \(menuItem.nameEnglish ?? "")")
            if item.templates?.count ?? 0 > 0, item.templates?[safe: 0]?.modGroups?.isEmpty ?? false == false {
				//Some template to be removed
				debugPrint("Removed template with hashId : \(arrayToSearch[index].templates?.last?.hashId ?? "")")
				let lastHashId = (arrayToSearch[index].templates?.last?.hashId ?? "")
                arrayToSearch[index].templates?.removeLast()
				let newArray = arrayToSearch[index].templates ?? []
				let templateCount = (newArray.filter({ $0.hashId ?? "" == lastHashId})).count
				if templateCount == 0 {
					// Remove api
                    CartUtility.removeItemFromCartRemotely(menuItem: menuItem, hashId: lastHashId, completion: { [weak self] in
                        self?.handleDeleteCallback(result: $0, menuUpdate: arrayToSearch[index], hashId: lastHashId, modGroups: template?.modGroups)
                    })
				} else {
                    CartUtility.updateCartCountRemotely(menuItem: menuItem, hashId: lastHashId, isIncrement: false, quantity: newCount, completion: { [weak self] in
                        self?.handleUpdateCallback(result: $0, menuUpdate: arrayToSearch[index], hashId: lastHashId, isIncrement: false, modGroups: template?.modGroups)
                    })
				}
                //self.updateExploreMenu?(results[index])
			} else {
				// Base Items Count Update
				let hashIdForBaseItem = MD5Hash.generateHashForTemplate(itemId: menuItem._id ?? "", modGroups: nil)
				if newCount == 0 {
					//Remove api
                    CartUtility.removeItemFromCartRemotely(menuItem: menuItem, hashId: hashIdForBaseItem, completion: { [weak self] in
                        self?.handleDeleteCallback(result: $0, menuUpdate: arrayToSearch[index], hashId: hashIdForBaseItem, modGroups: nil)
                    })
				} else if newCount == 1 && oldCount == 0 {
                    addToCart(menuItem: menuItem, template: template, menuUpdate: arrayToSearch[index])
				} else {
                    CartUtility.updateCartCountRemotely(menuItem: menuItem, hashId: hashIdForBaseItem, isIncrement: newCount > oldCount, quantity: newCount, completion: { [weak self] in
                        self?.handleUpdateCallback(result: $0, menuUpdate: arrayToSearch[index], hashId: hashIdForBaseItem, isIncrement: newCount > oldCount, modGroups: nil)
                    })
				}
                //self.updateExploreMenu?(arrayToSearch[index])
			}
		}
	}
}

extension ExploreMenuSearchVC {
    private func handleDeleteCallback(result: Result<Bool, Error>, menuUpdate: MenuSearchResultItem, hashId: String, modGroups: [ModGroup]?) {
        let strongSelf = self
        switch result {
        case .success:
            //strongSelf.updateExploreMenu?(menuUpdate)
            let cartNotification = CartCountNotifier(isIncrement: false, itemId: menuUpdate._id ?? "", menuId: menuUpdate.menuId ?? "", hashId: hashId, serviceType: self.serviceType, modGroups: modGroups)
            NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
            switch strongSelf.currentViewType {
            case .recentSearchTopCategories:
                break
            case .results:
                if let firstIndex = strongSelf.results.firstIndex(where: { $0._id ?? "" == menuUpdate._id ?? "" }) {
                    strongSelf.results[firstIndex] = menuUpdate
                }
                strongSelf.tableView.reloadData()
            case .suggestionAndTopCategories:
                if let firstIndex = strongSelf.suggestions.firstIndex(where: { $0._id ?? "" == menuUpdate._id ?? "" }) {
                    strongSelf.suggestions[firstIndex] = menuUpdate
                }
                strongSelf.tableView.reloadData()
            }
        case .failure:
            strongSelf.tableView.reloadData()
        }
    }
}

extension ExploreMenuSearchVC {
    private func handleUpdateCallback(result: Result<Bool, Error>, menuUpdate: MenuSearchResultItem, hashId: String, isIncrement: Bool, modGroups: [ModGroup]?) {
        let strongSelf = self
        switch result {
        case .success:
            let cartNotification = CartCountNotifier(isIncrement: isIncrement, itemId: menuUpdate._id ?? "", menuId: menuUpdate.menuId ?? "", hashId: hashId, serviceType: self.serviceType, modGroups: modGroups)
            NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
            switch strongSelf.currentViewType {
            case .recentSearchTopCategories:
                break
            case .results:
                if let firstIndex = strongSelf.results.firstIndex(where: { $0._id ?? "" == menuUpdate._id ?? "" }) {
                    strongSelf.results[firstIndex] = menuUpdate
                }
                strongSelf.tableView.reloadData()
            case .suggestionAndTopCategories:
                if let firstIndex = strongSelf.suggestions.firstIndex(where: { $0._id ?? "" == menuUpdate._id ?? "" }) {
                    strongSelf.suggestions[firstIndex] = menuUpdate
                }
                strongSelf.tableView.reloadData()
            }
        case .failure:
            strongSelf.tableView.reloadData()
        }
    }
}

extension ExploreMenuSearchVC {
    private func addToCart(menuItem: MenuItem, template: CustomisationTemplate?, menuUpdate: MenuSearchResultItem) {
		var hashId: String!
		if let template = template {
			hashId = template.hashId ?? ""
		} else {
			hashId = MD5Hash.generateHashForTemplate(itemId: menuItem._id ?? "", modGroups: nil)
		}
		guard let menuId = menuItem.menuId, let itemId = menuItem._id, let itemSdmId = menuItem.itemId  else { return }
        let addToCartReq = AddCartItemRequest(itemId: itemId, menuId: menuId, hashId: hashId, storeId: self.storeId, itemSdmId: itemSdmId, quantity: 1, servicesAvailable: serviceType, modGroups: template?.modGroups)
        CartUtility.addItemToCartRemotely(addToCartReq: addToCartReq, menuItem: menuItem, completion: { [weak self] (response) in
            mainThread {
                guard let strongSelf = self else { return }
                switch response {
                case .success:
                    let cartNotification = CartCountNotifier(isIncrement: true, itemId: menuUpdate._id ?? "", menuId: menuUpdate.menuId ?? "", hashId: hashId, serviceType: strongSelf.serviceType, modGroups: template?.modGroups)
                    NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
                    //strongSelf.updateExploreMenu?(menuUpdate)
                    switch strongSelf.currentViewType {
                    case .recentSearchTopCategories:
                        strongSelf.tableView.becomeFirstResponder()
                    case .results:
                        if let firstIndex = strongSelf.results.firstIndex(where: { $0._id ?? "" == menuUpdate._id ?? "" }) {
                            strongSelf.results[firstIndex] = menuUpdate
                        }
                        strongSelf.tableView.reloadData()
                    case .suggestionAndTopCategories:
                        if let firstIndex = strongSelf.suggestions.firstIndex(where: { $0._id ?? "" == menuUpdate._id ?? "" }) {
                            strongSelf.suggestions[firstIndex] = menuUpdate
                        }
                        strongSelf.tableView.reloadData()
                    }
                case .failure:
                    strongSelf.tableView.reloadData()
                }
            }
        })
	}
}

extension ExploreMenuSearchVC {
    func showCartConflictAlert(_ count: Int, _ item: MenuItem, _ template: CustomisationTemplate? = nil) {
        let alert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 186))
        alert.setTextAlignment(.left)
        alert.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: nil)
        alert.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: .right)
        alert.configure(title: LSCollection.CartScren.orderTypeHasBeenChanged, message: LSCollection.CartScren.cartWillBeCleared, leftButtonTitle: LSCollection.SignUp.cancel, rightButtonTitle: LSCollection.SignUp.continueText, container: self.view)
        alert.handleAction = { [weak self] in
            if $0 == .right {
                CartUtility.clearCartRemotely(clearedConfirmed: {
                    self?.updateCountLocally(count: count, menuItem: item, template: nil)
                    self?.tableView.reloadData()
                    weak var weakRef = alert
                    weakRef?.removeFromContainer()
                })
            }
        }
    }
}
