//
//  MyFavouritesVM.swift
//  Kudu
//
//  Created by Admin on 18/08/22.
//

import Foundation

protocol MyFavouritesVMDelegate: AnyObject {
    func favouriteAPIResponse(responseType: Result<String, Error>)
    func itemDetailAPIResponse(responseType: Result<CustomisationTemplate?, Error>)
}

class MyFavouritesVM {
    
    private weak var delegate: MyFavouritesVMDelegate?
    private let webService = APIEndPoints.HomeEndPoints.self
    private var pageNo: Int = 1
    private var items: [FavouriteItem] = []
    private var total: Int = 0
    private var itemDetailResponse: MenuItem?
    private var itemDetailIndex: Int?
  //  private var serviceTypeHome: APIEndPoints.ServicesType = .delivery
    var getItems: [FavouriteItem] { items }
    var getPageNo: Int { pageNo }
    var getTotal: Int { total }
    var getItemDetailResponse: MenuItem? { itemDetailResponse }
    var getItemDetailIndex: Int? { itemDetailIndex }
    //var getServiceType: APIEndPoints.ServicesType { serviceTypeHome }
    
    init(delegate: MyFavouritesVMDelegate, serviceTypeHome: APIEndPoints.ServicesType) {
        self.delegate = delegate
      //  self.serviceTypeHome = serviceTypeHome
    }
    
    func getFavourites(pageNo: Int) {
        self.pageNo = pageNo
        if self.pageNo == 1 {
            self.total = 0
            self.items = []
        }
        webService.getFavourites(pageNo: pageNo, success: { [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.total = response.data?.total ?? 0
			strongSelf.items.append(contentsOf: (response.data?.data) ?? [])
			debugPrint("Total items count : \(strongSelf.items.count)")
            strongSelf.delegate?.favouriteAPIResponse(responseType: .success(response.message ?? ""))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.favouriteAPIResponse(responseType: .failure(error))
        })
    }
    
    func fetchItemDetail(itemId: String, preLoadTemplate: CustomisationTemplate?, indexFavouriteArray: Int) {
        APIEndPoints.HomeEndPoints.getItemDetail(itemId: itemId, success: { [weak self] (response) in
            self?.itemDetailResponse = response.data?.first
            self?.itemDetailIndex = indexFavouriteArray
            self?.delegate?.itemDetailAPIResponse(responseType: .success(preLoadTemplate))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.itemDetailAPIResponse(responseType: .failure(error))
        })
    }
    
    func removeFromFavourites(id: String, index: Int) {
        let item = items[safe: index]
		self.total -= 1
        debugPrint("Removed Hash ID \(item?.hashId ?? "")")
        DataManager.removeHashIdFromFavourites(item?.hashId ?? "")
        items.remove(at: index)
        let request = FavouriteRequest(itemId: id, hashId: item?.hashId ?? "", menuId: item?.itemDetails?.menuId ?? "", itemSdmId: item?.itemDetails?.itemId ?? 0, isFavourite: false, servicesAvailable: APIEndPoints.ServicesType(rawValue: item?.itemDetails?.servicesAvailable ?? "") ?? .delivery, modGroups: item?.modGroups ?? [])
        APIEndPoints.HomeEndPoints.hitFavouriteAPI(request: request, success: { _ in
           // No implementation needed
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.favouriteAPIResponse(responseType: .failure(error))
        })
    }
}

extension MyFavouritesVM {
    func updateCountLocally(count: Int, index: Int) {
        let object = items[index]
        guard let menuItem = object.itemDetails else { return }
        let serviceType = APIEndPoints.ServicesType(rawValue: object.itemDetails?.servicesAvailable ?? "") ?? .delivery
        var template: CustomisationTemplate?
        if menuItem.isCustomised ?? false {
            template = CustomisationTemplate(modGroups: object.modGroups ?? [], hashId: object.hashId ?? "", _id: nil, cartId: nil, totalQuantity: nil)
        }
        let oldCount = object.cartCount ?? 0
        let newCount = count
        if newCount > oldCount {
            items[index].cartCount = newCount
            if oldCount == 0 {
                addToCart(menuItem: menuItem, template: template, serviceType: serviceType)
            } else {
                CartUtility.updateCartCount(menuItem: menuItem, hashId: object.hashId ?? "", isIncrement: true, quantity: newCount)
            }
        } else {
            if newCount == 0 {
                items[index].cartCount = newCount
                CartUtility.removeItemFromCart(menuItem: menuItem, hashId: object.hashId ?? "")
            } else {
                items[index].cartCount = newCount
                CartUtility.updateCartCount(menuItem: menuItem, hashId: object.hashId ?? "", isIncrement: false, quantity: newCount)
            }
        }
    }
}

extension MyFavouritesVM {
    private func addToCart(menuItem: MenuItem, template: CustomisationTemplate?, serviceType: APIEndPoints.ServicesType) {
        var hashId: String!
        if let template = template {
            hashId = template.hashId ?? ""
        } else {
            hashId = MD5Hash.generateHashForTemplate(itemId: menuItem._id ?? "", modGroups: nil)
        }
        guard let menuId = menuItem.menuId, let itemId = menuItem._id, let itemSdmId = menuItem.itemId  else { return }
        let addToCartReq = AddCartItemRequest(itemId: itemId, menuId: menuId, hashId: hashId, storeId: nil, itemSdmId: itemSdmId, quantity: 1, servicesAvailable: serviceType, modGroups: template?.modGroups)
        CartUtility.addItemToCart(addToCartReq.createPlaceholderCartObject(itemDetails: menuItem))
        APIEndPoints.CartEndPoints.addItemToCart(req: addToCartReq, success: { (response) in
            guard let cartItem = response.data else { return }
            debugPrint(response)
            var copy = cartItem
            copy.itemDetails = menuItem
            CartUtility.mapObjectWithPlaceholder(copy)
        }, failure: { (error) in
            debugPrint(error.msg)
        })
    }
    
    func addToCartDirectly(menuItem: MenuItem, hashId: String, modGroups: [ModGroup]) {
        let cart = CartUtility.fetchCart()
        let hashIdExists = cart.firstIndex(where: { $0.hashId ?? "" == hashId })
        if hashIdExists.isNotNil {
            let previousQuantity = cart[hashIdExists!].quantity ?? 0
            CartUtility.updateCartCount(menuItem: menuItem, hashId: hashId, isIncrement: true, quantity: previousQuantity + 1)
            return
        }
        let addToCartReq = AddCartItemRequest(itemId: menuItem._id ?? "", menuId: menuItem.menuId ?? "", hashId: hashId, storeId: nil, itemSdmId: menuItem.itemId ?? 0, quantity: 1, servicesAvailable: APIEndPoints.ServicesType(rawValue: menuItem.servicesAvailable!) ?? .delivery, modGroups: modGroups)
        CartUtility.addItemToCart(addToCartReq: addToCartReq, menuItem: menuItem)
    }
}
