//
//  CartListResponseModel.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import Foundation

struct CartListResponseModel: Codable {
	let message: String?
	let statusCode: Int?
	let data: CartListData?
}

struct CartListData: Codable {
    let data: [CartListObject]?
    let couponData: CouponObject?
}

struct CartListObject: Codable {
	let _id: String?
	let itemId: String?
	let menuId: String?
	let hashId: String?
	let isCustomised: Bool?
	var quantity: Int?
	let servicesAvailable: String?
	let itemSdmId: Int?
	let storeId: String?
	let modGroups: [ModGroup]?
    var offerdItem: Bool?
	var itemDetails: MenuItem?
	var expandProductDetails: Bool?
    
    func convertToMenuItem() -> MenuItem {
        let quantity = self.quantity ?? 0
        let template = CustomisationTemplate(modGroups: self.modGroups ?? [], hashId: self.hashId ?? "", _id: nil, cartId: nil, totalQuantity: quantity)
        var templates: [CustomisationTemplate] = []
        for _ in 0..<quantity {
            templates.append(template)
        }
        return MenuItem(menuId: self.menuId ?? "", _id: self.itemDetails?._id ?? "", nameArabic: self.itemDetails?.nameArabic ?? "", descriptionEnglish: self.itemDetails?.descriptionEnglish ?? "", nameEnglish: self.itemDetails?.nameEnglish ?? "", isCustomised: self.itemDetails?.isCustomised ?? false, price: self.itemDetails?.price ?? 0.0, descriptionArabic: self.itemDetails?.descriptionArabic ?? "", itemImageUrl: self.itemDetails?.itemImageUrl ?? "", allergicComponent: self.itemDetails?.allergicComponent ?? [], isAvailable: self.itemDetails?.isAvailable ?? false, modGroups: self.itemDetails?.modGroups ?? [], cartCount: quantity, templates: templates, titleArabic: self.itemDetails?.titleArabic ?? "", titleEnglish: self.itemDetails?.titleEnglish ?? "", itemId: self.itemDetails?.itemId ?? 0, servicesAvailable: self.servicesAvailable, calories: itemDetails?.calories, excludeLocations: itemDetails?.excludeLocations ?? [])
    }
}
