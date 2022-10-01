//
//  ExploreMenuVM.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import Foundation

protocol ExploreMenuVMDelegate: AnyObject {
    func itemListAPIResponse(responseType: Result<String, Error>, index: Int)
    func itemDetailAPIResponse(responseType: Result<CustomisationTemplate?, Error>, index: Int)
}

class ExploreMenuVM {
    
    private var menuCategories: [MenuCategory]?
    private var itemTableData: [[MenuItem]] = []
    private var indexToStart: Int?
    private var itemDetailResponse: MenuItem?
    private var itemDetailTableIndex: Int?
    var getMenuCategories: [MenuCategory]? { menuCategories }
    var getItemTableData: [[MenuItem]] { itemTableData }
    var getIndexToStart: Int? { indexToStart }
    var getItemDetailResponse: MenuItem? { itemDetailResponse }
    var getItemDetailTableIndex: Int? { itemDetailTableIndex }

    weak var delegate: ExploreMenuVMDelegate?
    
    init(menuCategories: [MenuCategory], delegate: ExploreMenuVMDelegate, indexToStart: Int? = nil) {
        self.menuCategories = menuCategories
        self.delegate = delegate
        self.indexToStart = indexToStart
        self.menuCategories?.forEach({ _ in
            self.itemTableData.append([])
        })
    }
	
	func updateStartFlowIndex(_ index: Int) {
		self.indexToStart = index
	}
    
    func updateLikeStatus(_ liked: Bool, itemId: String, hashId: String, modGroups: [ModGroup]?, tableIndex: Int) {
        if liked {
            debugPrint("Added Hash ID \(hashId)")
            DataManager.saveHashIDtoFavourites(hashId)
        } else {
            debugPrint("Removed Hash ID \(hashId)")
            DataManager.removeHashIdFromFavourites(hashId)
        }
        guard let menuItems = itemTableData[safe: tableIndex], let itemIndex = menuItems.firstIndex(where: { $0._id == itemId }) else {
            fatalError("Item Index Issue")
        }
        let item = itemTableData[tableIndex][itemIndex]
        if modGroups.isNotNil {
            itemTableData[tableIndex][itemIndex].isFavourites = liked
        }
        let itemInTable = itemTableData[tableIndex][itemIndex]
//        let request = FavouriteRequest(itemId: itemId, hashId: hashId, menuId: itemInTable.menuId ?? "", itemSdmId: item.itemId ?? 0, isFavourite: item.isFavourites ?? false, servicesAvailable: <#APIEndPoints.ServicesType#>, modGroups: modGroups)
//        APIEndPoints.HomeEndPoints.hitFavouriteAPI(request: request, success: { (response) in
//            debugPrint(response.message ?? "")
//        }, failure: { _ in
//            //Need to revisit implementation, provide a like delegate method
//        })
    }
    
    func updateCountLocally(count: Int, menuItem: MenuItem, template: CustomisationTemplate?, tableIndex: Int) {
        guard let menuItems = itemTableData[safe: tableIndex], let index = menuItems.firstIndex(where: { $0._id ?? "" == menuItem._id ?? "" }) else { return }
        let oldCount = menuItems[index].cartCount ?? 0
        let newCount = count
        if newCount > oldCount, let template = template {
            // Addition, Means Base Item
            itemTableData[tableIndex][index].cartCount = newCount
            var array = menuItems[index].templates ?? []
            array.append(template)
            itemTableData[tableIndex][index].templates = array
            debugPrint("Count updated to \(newCount) for item : \(menuItem.nameEnglish ?? ""), added template with hashId : \(template.hashId ?? "")")
            
        } else {
            guard let item = menuItems[safe: index] else { return }
            itemTableData[tableIndex][index].cartCount = newCount
            debugPrint("Count updated to \(newCount) for item : \(menuItem.nameEnglish ?? "")")
            if item.templates?.count ?? 0 > 0 {
                //Some template to be removed
                debugPrint("Removed template with hashId : \(menuItems[index].templates?.last?.hashId ?? "")")
                itemTableData[tableIndex][index].templates?.removeLast()
            }
        }
    }
    
    func updateLikeStatusLocally(item: MenuItem, isLiked: Bool, tableIndex: Int) {
        if let menuItems = itemTableData[safe: tableIndex], let index = menuItems.firstIndex(where: { $0._id ?? "" == item._id ?? "" }), let itemMatched = menuItems[safe: index] {
            if itemMatched.templates.isNil && item.templates.isNil {
                //No Customisation
                itemTableData[tableIndex][index].isFavourites = isLiked
            } else {
                let topTemplateInCurrentItem = itemMatched.templates?.last
                let incomingTemplateTop = item.templates?.last
                if topTemplateInCurrentItem?.hashId ?? "" == incomingTemplateTop?.hashId ?? "" {
                    //Template Matched, update Liked
                    itemTableData[tableIndex][index].isFavourites = isLiked
                }
            }
        }
    }
    
    func fetchMenuItems(selectedIndex: Int) {
        
        if selectedIndex >= menuCategories?.count ?? 0 { return }
        
        let menuId = menuCategories![selectedIndex]._id ?? ""
        if !self.itemTableData[selectedIndex].isEmpty {
           // self.delegate?.itemListAPIResponse(responseType: .success(""), index: selectedIndex)
            return }
        
        APIEndPoints.HomeEndPoints.getMenuItemList(menuId: menuId, success: { [weak self] in
            self?.itemTableData[selectedIndex] = $0.data ?? []
            self?.delegate?.itemListAPIResponse(responseType: .success($0.message ?? ""), index: selectedIndex)
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.itemListAPIResponse(responseType: .failure(error), index: selectedIndex)
        })
    }
    
    func fetchItemDetail(itemId: String, preLoadTemplate: CustomisationTemplate?, tableIndex: Int) {
        APIEndPoints.HomeEndPoints.getItemDetail(itemId: itemId, success: { [weak self] (response) in
            self?.itemDetailResponse = response.data?.first
            self?.itemDetailTableIndex = tableIndex
            self?.delegate?.itemDetailAPIResponse(responseType: .success(preLoadTemplate), index: tableIndex)
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.itemDetailAPIResponse(responseType: .failure(error), index: tableIndex)
        })
    }
    
}
