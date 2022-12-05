//
//  ExploreMenuV2VM.swift
//  Kudu
//
//  Created by Admin on 13/09/22.
//

import Foundation
import UIKit

class ExploreMenuV2VM {
    
	private var serviceType: APIEndPoints.ServicesType!
	private var storeId: String?
	private var categories: [MenuCategory] = []
	private var itemColumnData: [[MenuItem]] = []
	private var itemDetailResponse: MenuItem?
	private var itemDetailTableIndex: Int?
	private var categoriesFetched: [String] = [] {
		didSet {
			if categoriesFetched.count == categories.count {
				debugPrint("All Item Data Fetched")
			}
		}
	}
    private var queueScrollIndex: Int?
	var getCategories: [MenuCategory] { categories }
	var getColumnData: [[MenuItem]] { itemColumnData }
	var getItemDetailResponse: MenuItem? { itemDetailResponse }
	var getItemDetailTableIndex: Int? { itemDetailTableIndex }
    var getStoreId: String? { storeId }
    var getServiceType: APIEndPoints.ServicesType { serviceType }
    var getQueueScrollIndex: Int? { queueScrollIndex }
    
    init(categories: [MenuCategory], storeId: String?, serviceType: APIEndPoints.ServicesType) {
		self.categories = categories
		self.storeId = storeId
		self.serviceType = serviceType
	}
	
	func updateQueueScrollIndex(index: Int?) {
		self.queueScrollIndex = index
	}
    
    func refreshViewModel(someConflictOccured: (() -> Void)? = nil) {
        self.serviceType = DataManager.shared.currentServiceType
        self.storeId = DataManager.shared.currentStoreId
        someConflictOccured?()
    }
    
    func syncWithExploreSearch(object: MenuSearchResultItem) {
        let item = object.convertToMenuItem()
        guard let tableIndex = categories.firstIndex(where: { $0._id ?? "" == item.menuId ?? ""}), let column = itemColumnData[safe: tableIndex], let itemIndex = column.firstIndex(where: { $0._id ?? "" == item._id ?? ""}) else { return }
          itemColumnData[tableIndex][itemIndex] = item
    }
    
    func syncWithCart(menuId: String, itemId: String, hashId: String, increment: Bool, modGroups: [ModGroup]?, apiFailed: Bool = false) -> [[MenuItem]]? {
        if apiFailed {
            return itemColumnData
        }
        guard let column = categories.firstIndex(where: { $0._id ?? "" == menuId}), let itemIndex = itemColumnData[column].firstIndex(where: { $0._id ?? "" == itemId }) else { return nil }
        let hashIdExists = itemColumnData[column][itemIndex].templates?.firstIndex(where: { $0.hashId ?? "" == hashId })
        if let hashIndex = hashIdExists {
            let prevItemCount = itemColumnData[column][itemIndex].cartCount ?? 0
            let previousHashCount = itemColumnData[column][itemIndex].templates!.filter({ $0.hashId ?? "" == hashId }).count
            let newHashCount = increment ? previousHashCount + 1 : previousHashCount - 1
            if newHashCount == 0 {
                itemColumnData[column][itemIndex].templates?.remove(at: hashIndex)
                itemColumnData[column][itemIndex].cartCount = prevItemCount - 1
                return itemColumnData
            } else {
                if increment {
                    itemColumnData[column][itemIndex].templates?.insert(CustomisationTemplate(modGroups: modGroups, hashId: hashId), at: hashIndex + 1)
                    itemColumnData[column][itemIndex].cartCount = prevItemCount + 1
                    return itemColumnData
                } else {
                    itemColumnData[column][itemIndex].templates?.remove(at: hashIndex)
                    itemColumnData[column][itemIndex].cartCount = prevItemCount - 1
                    return itemColumnData
                }
            }
        } else {
            // If hash index doesn't exist in templates, two cases -- new template being added, or base item modification happening
            if let someModGroupsIncoming = modGroups, someModGroupsIncoming.isEmpty == false {
                //New Template being added, never decrement case
                let prevItemCount = itemColumnData[column][itemIndex].cartCount ?? 0
                var previousTemplates = itemColumnData[column][itemIndex].templates ?? []
                previousTemplates.append(CustomisationTemplate(modGroups: someModGroupsIncoming, hashId: hashId))
                itemColumnData[column][itemIndex].templates = previousTemplates
                itemColumnData[column][itemIndex].cartCount = prevItemCount + 1
                return itemColumnData
            } else {
                let prevItemCount = itemColumnData[column][itemIndex].cartCount ?? 0
                itemColumnData[column][itemIndex].cartCount = increment ? prevItemCount + 1 : prevItemCount - 1
                return itemColumnData
            }
        }
    }
    
    private func getMenus(fetched: @escaping (() -> Void)) {
        if categories.isEmpty == false {
            debugPrint("NO NEED TO FETCH MENUS")
            fetched()
        }
        // Categories emptied and updated here
        self.storeId = DataManager.shared.currentStoreId
        self.serviceType = DataManager.shared.currentServiceType
        let coordinates = DataManager.shared.currentRelevantLatLong
        APIEndPoints.HomeEndPoints.getMenuList(request: MenuListRequest(servicesType: self.serviceType, lat: coordinates.lat, long: coordinates.long, storeId: self.storeId), success: { [weak self] in
            let filterList = ($0.data ?? [])
            self?.categories = TimeRange.filterArrayOfCategories(categories: filterList)
            fetched()
        }, failure: { _ in
            //Need to handle
            fetched()
        })
    }
	
	func fetchAllItemTableData(completedFetching: @escaping ((Bool) -> Void)) {
        itemColumnData = []
        categoriesFetched = []
        categories = []
        getMenus { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.categories.forEach({ _ in
                strongSelf.itemColumnData.append([])
            })
            strongSelf.categories.forEach({ (category) in
                let menuId = category._id ?? ""
                strongSelf.fetchItemForCategory(menuId: menuId, fetched: { [weak self] (items: [MenuItem]?, idOfMenu: String) in
                    guard let strongSelf = self else { return }
                    guard let indexOfCategory = strongSelf.categories.firstIndex(where: { $0._id ?? "" == menuId }) else { return }
                    if items.isNil {
                        completedFetching(false)
                        return
                    }
                    strongSelf.categoriesFetched.append(idOfMenu)
                    strongSelf.itemColumnData[indexOfCategory] = items ?? []
                    if strongSelf.categoriesFetched.count == strongSelf.categories.count {
                        completedFetching(true)
                    }
                })
            })
        }
	}
	
	private func fetchItemForCategory(menuId: String, fetched: @escaping (([MenuItem]?, String) -> Void)) {
		APIEndPoints.HomeEndPoints.getMenuItemList(menuId: menuId, success: { (response) in
			fetched(response.data ?? [], menuId)
		}, failure: { _ in
			fetched(nil, menuId)
		})
	}
	
	func calculateScrollMetrics() -> ExploreMenuViewScrollMetrics {
		var metrics = ExploreMenuViewScrollMetrics()
		var maxColumnHeight: CGFloat = 0
		var maxRows: Int = 0
		var columnSpecificHeights: [CGFloat] = []
		itemColumnData.forEach({ (columnArray) in
            if columnArray.count > maxRows {
                maxRows = columnArray.count
            }
            let columnHeight = CGFloat(columnArray.count*197)
            columnSpecificHeights.append(columnHeight)
            if columnHeight > maxColumnHeight {
                maxColumnHeight = columnHeight
            }
		})
		
		debugPrint("MAXIMUM HEIGHT OF A COLUMN CAN BE \(maxColumnHeight)")
		metrics.maxRows = maxRows
		metrics.maxHeight = maxColumnHeight
		metrics.columnSpecificHeights = columnSpecificHeights
		return metrics
	}
}

extension ExploreMenuV2VM {
	// MARK: Operation Methods
    func updateLikeStatus(req: LikeUpdateRequest, likeFailed: @escaping ((String) -> Void?)) {
        var hashId = req.hashId
        if req.liked {
			debugPrint("Added Hash ID \(hashId)")
			DataManager.saveHashIDtoFavourites(hashId)
		} else {
			debugPrint("Removed Hash ID \(hashId)")
			DataManager.removeHashIdFromFavourites(hashId)
		}
        
        guard let menuItems = itemColumnData[safe: req.tableIndex], let itemIndex = menuItems.firstIndex(where: { $0._id == req.itemId }) else {
            fatalError("Item Index issue")
        }
        let item = itemColumnData[req.tableIndex][itemIndex]
        var modGroups: [ModGroup]? = req.modGroups
		if modGroups.isNotNil {
            itemColumnData[req.tableIndex][itemIndex].isFavourites = req.liked
            modGroups = itemColumnData[req.tableIndex][itemIndex].templates?.last?.modGroups
            if let templateHashID = itemColumnData[req.tableIndex][itemIndex].templates?.last?.hashId {
                hashId = templateHashID
            }
		}
        let request = FavouriteRequest(itemId: req.itemId, hashId: hashId, menuId: item.menuId ?? "", itemSdmId: item.itemId ?? 0, isFavourite: req.liked, servicesAvailable: self.serviceType, modGroups: modGroups)
		APIEndPoints.HomeEndPoints.hitFavouriteAPI(request: request, success: { (response) in
			debugPrint(response.message ?? "")
		}, failure: { (error) in
			//Need to revisit implementation, provide a like delegate method
			likeFailed(error.msg)
		})
	}
	
	func updateCountLocally(count: Int, menuItem: MenuItem, template: CustomisationTemplate?, tableIndex: Int) {
		guard let menuItems = itemColumnData[safe: tableIndex], let index = menuItems.firstIndex(where: { $0._id ?? "" == menuItem._id ?? "" }) else { return }
		let oldCount = menuItems[index].cartCount ?? 0
		let newCount = count
		if newCount > oldCount, let template = template {
			// Addition, Means Base Item
			//itemColumnData[tableIndex][index].cartCount = newCount
			var array = menuItems[index].templates ?? []
			let templateCount = (array.filter({ $0.hashId ?? "" == template.hashId ?? ""})).count
			array.append(template)
			//itemColumnData[tableIndex][index].templates = array
			if templateCount == 0 {
				addToCart(menuItem: menuItem, template: template, tableIndex: tableIndex)
			} else {
                updateCartCount(menuItem: menuItem, hashId: template.hashId ?? "", tableIndex: tableIndex, isIncrement: true, quantity: newCount, templateModGroups: template.modGroups)
			}
			debugPrint("Count updated to \(newCount) for item : \(menuItem.nameEnglish ?? ""), added template with hashId : \(template.hashId ?? "")")
			
		} else {
			guard let item = menuItems[safe: index] else { return }
			debugPrint("Count updated to \(newCount) for item : \(menuItem.nameEnglish ?? "")")
            if item.templates?.count ?? 0 > 0, let recentTemplate = item.templates?.last, let modGroupCount = recentTemplate.modGroups?.count, modGroupCount > 0 {
				//Some template to be removed
				debugPrint("Removed template with hashId : \(menuItems[index].templates?.last?.hashId ?? "")")
				let lastHashId = itemColumnData[tableIndex][index].templates?.last?.hashId ?? ""
				//itemColumnData[tableIndex][index].templates?.removeLast()
				let newArray = itemColumnData[tableIndex][index].templates ?? []
				let templateCount = (newArray.filter({ $0.hashId ?? "" == lastHashId})).count
				if templateCount == 0 {
					// Remove api
                    removeItemFromCart(menuItem: menuItem, hashId: lastHashId, tableIndex: tableIndex, templateModGroups: template?.modGroups)
				} else {
                    updateCartCount(menuItem: menuItem, hashId: lastHashId, tableIndex: tableIndex, isIncrement: false, quantity: newCount, templateModGroups: template?.modGroups)
				}
				
			} else {
				//Base Items Count Update
               // itemColumnData[tableIndex][index].cartCount = newCount
				let hashIdForBaseItem = MD5Hash.generateHashForTemplate(itemId: menuItem._id ?? "", modGroups: nil)
				if newCount == 0 {
					//Remove api
                    removeItemFromCart(menuItem: menuItem, hashId: hashIdForBaseItem, tableIndex: tableIndex, templateModGroups: nil)
				} else if newCount == 1 && oldCount == 0 {
					addToCart(menuItem: menuItem, template: template, tableIndex: tableIndex)
				} else {
                    updateCartCount(menuItem: menuItem, hashId: hashIdForBaseItem, tableIndex: tableIndex, isIncrement: newCount > oldCount, quantity: newCount, templateModGroups: nil)
				}
			}
		}
	}
	
	private func addToCart(menuItem: MenuItem, template: CustomisationTemplate?, tableIndex: Int) {
		var hashId: String!
		if let template = template {
			hashId = template.hashId ?? ""
		} else {
			hashId = MD5Hash.generateHashForTemplate(itemId: menuItem._id ?? "", modGroups: nil)
		}
		guard let menuId = categories[safe: tableIndex]?._id, let itemId = menuItem._id, let itemSdmId = menuItem.itemId  else { return }
		let addToCartReq = AddCartItemRequest(itemId: itemId, menuId: menuId, hashId: hashId, storeId: self.storeId, itemSdmId: itemSdmId, quantity: 1, servicesAvailable: serviceType, modGroups: template?.modGroups)
        CartUtility.addItemToCartRemotely(addToCartReq: addToCartReq, menuItem: menuItem, completion: {
            switch $0 {
            case .success:
                let cartNotification = CartCountNotifier(isIncrement: true, itemId: addToCartReq.itemId, menuId: addToCartReq.menuId, hashId: addToCartReq.hashId, serviceType: self.serviceType, modGroups: addToCartReq.modGroups)
                NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
            case .failure:
                let cartNotification = CartCountNotifier(isIncrement: true, itemId: addToCartReq.itemId, menuId: addToCartReq.menuId, hashId: addToCartReq.hashId, serviceType: self.serviceType, modGroups: addToCartReq.modGroups, apiFailed: true)
                NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
            }
        })
	}
	
    private func updateCartCount(menuItem: MenuItem, hashId: String, tableIndex: Int, isIncrement: Bool, quantity: Int, templateModGroups: [ModGroup]?) {
		guard let itemId = menuItem._id else { return }
		let updateCartReq = UpdateCartCountRequest(isIncrement: isIncrement, itemId: itemId, quantity: 1, hashId: hashId)
		//CartUtility.updateCartCount(hashId, isIncrement: isIncrement)
		APIEndPoints.CartEndPoints.incrementDecrementCartCount(req: updateCartReq, success: { (response) in
			debugPrint(response)
            CartUtility.updateCartCountLocally(hashId, isIncrement: isIncrement)
            let cartNotification = CartCountNotifier(isIncrement: isIncrement, itemId: updateCartReq.itemId, menuId: menuItem.menuId ?? "", hashId: updateCartReq.hashId, serviceType: self.serviceType, modGroups: templateModGroups)
            NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
		}, failure: { _ in
            let cartNotification = CartCountNotifier(isIncrement: true, itemId: menuItem._id ?? "", menuId: menuItem.menuId ?? "", hashId: updateCartReq.hashId, serviceType: self.serviceType, modGroups: templateModGroups ?? [], apiFailed: true)
            NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
		})
	}
	
    private func removeItemFromCart(menuItem: MenuItem, hashId: String, tableIndex: Int, templateModGroups: [ModGroup]?) {
		guard let itemId = menuItem._id else { return }
		let removeCartReq = RemoveItemFromCartRequest(itemId: itemId, hashId: hashId)
		APIEndPoints.CartEndPoints.removeItemFromCart(req: removeCartReq, success: { _ in
            CartUtility.removeItemFromCartLocally(hashId)
            let cartNotification = CartCountNotifier(isIncrement: false, itemId: removeCartReq.itemId, menuId: menuItem.menuId ?? "", hashId: removeCartReq.hashId, serviceType: self.serviceType, modGroups: templateModGroups)
            NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
		}, failure: { _ in
            let cartNotification = CartCountNotifier(isIncrement: true, itemId: menuItem._id ?? "", menuId: menuItem.menuId ?? "", hashId: removeCartReq.hashId, serviceType: self.serviceType, modGroups: templateModGroups ?? [], apiFailed: true)
            NotificationCenter.postNotificationForObservers(.itemCountUpdatedFromCart, object: cartNotification.getUserInfoFormat)
		})
	}
	
	func fetchItemDetail(itemId: String, preLoadTemplate: CustomisationTemplate?, tableIndex: Int, result: @escaping (Result<CustomisationTemplate?, Error>, Int) -> Void) {
		APIEndPoints.HomeEndPoints.getItemDetail(itemId: itemId, success: { [weak self] (response) in
			self?.itemDetailResponse = response.data?.first
			self?.itemDetailTableIndex = tableIndex
			result(.success(preLoadTemplate), tableIndex)
		}, failure: {
			let error = NSError(code: $0.code, localizedDescription: $0.msg)
			result(.failure(error), tableIndex)
		})
	}
}
