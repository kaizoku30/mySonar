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
		let oldCount = arrayToSearch[index].cartCount ?? 0
		let newCount = count
		if newCount > oldCount, let template = template {
			// Addition, Means Base Item
            arrayToSearch[index].cartCount = newCount
			var array = arrayToSearch[index].templates ?? []
			let templateCount = (array.filter({ $0.hashId ?? "" == template.hashId ?? ""})).count
			array.append(template)
            arrayToSearch[index].templates = array
           // self.updateExploreMenu?(arrayToSearch[index])
			if templateCount == 0 {
                addToCart(menuItem: menuItem, template: template, menuUpdate: arrayToSearch[index])
			} else {
                CartUtility.updateCartCount(menuItem: menuItem, hashId: template.hashId ?? "", isIncrement: true, quantity: newCount, completion: { [weak self] in
                    self?.handleUpdateCallback(result: $0, menuUpdate: arrayToSearch[index])
                })
			}
			debugPrint("Count updated to \(newCount) for item : \(menuItem.nameEnglish ?? ""), added template with hashId : \(template.hashId ?? "")")
			
		} else {
			guard let item = arrayToSearch[safe: index] else { return }
            arrayToSearch[index].cartCount = newCount
			debugPrint("Count updated to \(newCount) for item : \(menuItem.nameEnglish ?? "")")
			if item.templates?.count ?? 0 > 0 {
				//Some template to be removed
				debugPrint("Removed template with hashId : \(arrayToSearch[index].templates?.last?.hashId ?? "")")
				let lastHashId = (arrayToSearch[index].templates?.last?.hashId ?? "")
                arrayToSearch[index].templates?.removeLast()
				let newArray = arrayToSearch[index].templates ?? []
				let templateCount = (newArray.filter({ $0.hashId ?? "" == lastHashId})).count
				if templateCount == 0 {
					// Remove api
                    CartUtility.removeItemFromCart(menuItem: menuItem, hashId: lastHashId, completion: { [weak self] in
                        self?.handleDeleteCallback(result: $0, menuUpdate: arrayToSearch[index])
                    })
				} else {
                    CartUtility.updateCartCount(menuItem: menuItem, hashId: lastHashId, isIncrement: false, quantity: newCount, completion: { [weak self] in
                        self?.handleUpdateCallback(result: $0, menuUpdate: arrayToSearch[index])
                    })
				}
                //self.updateExploreMenu?(results[index])
			} else {
				// Base Items Count Update
				let hashIdForBaseItem = MD5Hash.generateHashForTemplate(itemId: menuItem._id ?? "", modGroups: nil)
				if newCount == 0 {
					//Remove api
                    CartUtility.removeItemFromCart(menuItem: menuItem, hashId: hashIdForBaseItem, completion: { [weak self] in
                        self?.handleDeleteCallback(result: $0, menuUpdate: arrayToSearch[index])
                    })
				} else if newCount == 1 && oldCount == 0 {
                    addToCart(menuItem: menuItem, template: template, menuUpdate: arrayToSearch[index])
				} else {
                    CartUtility.updateCartCount(menuItem: menuItem, hashId: hashIdForBaseItem, isIncrement: newCount > oldCount, quantity: newCount, completion: { [weak self] in
                        self?.handleUpdateCallback(result: $0, menuUpdate: arrayToSearch[index])
                    })
				}
                //self.updateExploreMenu?(arrayToSearch[index])
			}
		}
	}
}

extension ExploreMenuSearchVC {
    private func handleDeleteCallback(result: Result<Bool, Error>, menuUpdate: MenuSearchResultItem) {
        let strongSelf = self
        switch result {
        case .success:
            strongSelf.updateExploreMenu?(menuUpdate)
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
                    strongSelf.results[firstIndex] = menuUpdate
                }
                strongSelf.tableView.reloadData()
            }
        case .failure(let error):
            strongSelf.tableView.reloadData()
        }
    }
}

extension ExploreMenuSearchVC {
    private func handleUpdateCallback(result: Result<Bool, Error>, menuUpdate: MenuSearchResultItem) {
        let strongSelf = self
        switch result {
        case .success:
            strongSelf.updateExploreMenu?(menuUpdate)
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
                    strongSelf.results[firstIndex] = menuUpdate
                }
                strongSelf.tableView.reloadData()
            }
        case .failure(let error):
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
        CartUtility.addItemToCart(addToCartReq: addToCartReq, menuItem: menuItem, completion: { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .success:
                strongSelf.updateExploreMenu?(menuUpdate)
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
                        strongSelf.results[firstIndex] = menuUpdate
                    }
                    strongSelf.tableView.reloadData()
                }
            case .failure(let error):
                strongSelf.tableView.reloadData()
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
        alert.configure(title: "Change Order Type ?", message: "Please be aware your cart will be cleared as you change order type", leftButtonTitle: "Cancel", rightButtonTitle: "Continue", container: self.view)
        alert.handleAction = { [weak self] in
            if $0 == .right {
                CartUtility.clearCart(clearedConfirmed: {
                    self?.updateCountLocally(count: count, menuItem: item, template: nil)
                    self?.tableView.reloadData()
                    weak var weakRef = alert
                    weakRef?.removeFromContainer()
                })
            }
        }
    }
}
