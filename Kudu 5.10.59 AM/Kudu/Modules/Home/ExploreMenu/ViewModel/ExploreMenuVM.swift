//
//  ExploreMenuVM.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import Foundation

protocol ExploreMenuVMDelegate: AnyObject {
    func itemListAPIResponse(responseType: Result<String, Error>)
}

class ExploreMenuVM {
    
    private var menuCategories: [MenuCategory]?
    private var menuItems: [MenuItem]?
    private var selectedIndex: Array<MenuCategory>.Index?
    var getMenuCategories: [MenuCategory]? { menuCategories }
    var getMenuItems: [MenuItem]? { menuItems }
    var getSelectedIndex: Array<MenuCategory>.Index? { selectedIndex }
    
    weak var delegate: ExploreMenuVMDelegate?
    
    init(menuCategories: [MenuCategory], delegate: ExploreMenuVMDelegate) {
        self.menuCategories = menuCategories
        self.delegate = delegate
        self.selectedIndex = self.menuCategories!.firstIndex(where: { ($0.isSelectedInApp ?? false) == true })
    }
    
    func updateSelection(_ index: Int) {
        if let menuCategories = menuCategories, index < menuCategories.count, let selectedIndex = getSelectedIndex {
            self.menuCategories![selectedIndex].isSelectedInApp = false
            self.selectedIndex = index
            self.menuCategories![index].isSelectedInApp = true
        }
    }
    
    func updateLikeStatus(_ liked: Bool, id: String) {
        if let menuItems = menuItems, let itemIndex = menuItems.firstIndex(where: { $0._id == id }) {
            self.menuItems![itemIndex].isLikedInApp = liked
        }
    }
    
    func fetchMenuItems() {
        guard let selectedIndex = menuCategories?.firstIndex(where: { $0.isSelectedInApp ?? false == true }), let categories = self.menuCategories else {
            let error = NSError(code: 111, localizedDescription: "No category selected")
            self.delegate?.itemListAPIResponse(responseType: .failure(error))
            return
        }
        let menuId = categories[selectedIndex]._id ?? ""
        self.menuItems = nil
        WebServices.HomeEndPoints.getMenuItemList(menuId: menuId, success: { [weak self] in
            self?.menuItems = $0.data ?? []
            self?.delegate?.itemListAPIResponse(responseType: .success($0.message ?? ""))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.itemListAPIResponse(responseType: .failure(error))
        })
    }
    
}
