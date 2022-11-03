//
//  SuggestionExploreMenuResponseModel.swift
//  Kudu
//
//  Created by Admin on 28/07/22.
//

import Foundation

struct SuggestionExploreMenuResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [MenuSearchResultItem]?
}

struct MenuSearchResultItem: Codable {
	let menuId: String?
    let _id: String?
    let titleEnglish: String?
    let titleArabic: String?
    let calories: Int?
    let isCategory: Bool?
    let isItem: Bool?
    let descriptionEnglish: String?
    let descriptionArabic: String?
    let nameEnglish: String?
    let nameArabic: String?
    let itemImageUrl: String?
    let price: Double?
    let allergicComponent: [AllergicComponent]?
    let isCustomised: Bool?
    let menuImageUrl: String?
    let itemCount: Int?
    var cartCount: Int?
    var isFavourites: Bool?
    let isAvailable: Bool?
	let itemId: Int?
    var modGroups: [ModGroup]?
    var templates: [CustomisationTemplate]?
	var cartRefrences: CartReference?
    let timeRange: [TimeRange]?
    let isTimeRangeSet: Bool?
	
	private enum CodingKeys: String, CodingKey {
        case menuId, _id, titleEnglish, titleArabic, nameEnglish, isCategory, isItem, descriptionEnglish, descriptionArabic, nameArabic, itemImageUrl, price, allergicComponent, isCustomised, menuImageUrl, itemCount, cartCount, isFavourites, isAvailable, itemId, modGroups, templates, cartRefrences, calories, timeRange, isTimeRangeSet }
	
    init(menuId: String?, _id: String?, titleEnglish: String?, titleArabic: String?, isCategory: Bool?, isItem: Bool?, descriptionEnglish: String?, descriptionArabic: String?, nameEnglish: String?, nameArabic: String?, itemImageUrl: String?, price: Double?, allergicComponent: [AllergicComponent]?, isCustomised: Bool?, menuImageUrl: String?, itemCount: Int?, cartCount: Int?, isAvailable: Bool?, itemId: Int?, calories: Int?) {
		self.menuId = menuId
		self._id = _id
		self.titleEnglish = titleEnglish
		self.titleArabic = titleArabic
		self.isCategory = isCategory
		self.isItem = isItem
		self.descriptionEnglish = descriptionEnglish
		self.descriptionArabic = descriptionArabic
		self.nameEnglish = nameEnglish
		self.nameArabic = nameArabic
		self.itemImageUrl = itemImageUrl
		self.price = price
		self.allergicComponent = allergicComponent
		self.isCustomised = isCustomised
		self.menuImageUrl = menuImageUrl
		self.itemCount = itemCount
		self.cartCount = cartCount
		self.isAvailable = isAvailable
		self.itemId = itemId
        self.calories = calories
        self.timeRange = []
        self.isTimeRangeSet = false
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		isItem = try? container.decode(Bool?.self, forKey: .isItem)
		menuId = try? container.decode(String?.self, forKey: .menuId)
		_id = try? container.decode(String?.self, forKey: ._id)
		nameEnglish = try? container.decode(String?.self, forKey: .nameEnglish)
		isCategory = try? container.decode(Bool?.self, forKey: .isCategory)
		nameArabic = try? container.decode(String?.self, forKey: .nameArabic)
		descriptionEnglish = try? container.decode(String?.self, forKey: .descriptionEnglish)
		isCustomised = try? container.decode(Bool?.self, forKey: .isCustomised)
		price = try? container.decode(Double?.self, forKey: .price)
		descriptionArabic = try? container.decode(String?.self, forKey: .descriptionArabic)
		itemImageUrl = try? container.decode(String?.self, forKey: .itemImageUrl)
		allergicComponent = try? container.decode([AllergicComponent]?.self, forKey: .allergicComponent)
		isAvailable = try? container.decode(Bool?.self, forKey: .isAvailable)
		isFavourites = try? container.decode(Bool?.self, forKey: .isFavourites)
		modGroups = try? container.decode([ModGroup]?.self, forKey: .modGroups)
		cartCount = try? container.decode(Int?.self, forKey: .cartCount)
		templates = try? container.decode([CustomisationTemplate]?.self, forKey: .templates)
		titleArabic = try? container.decode(String?.self, forKey: .titleArabic)
		titleEnglish = try? container.decode(String?.self, forKey: .titleEnglish)
		menuImageUrl = try? container.decode(String?.self, forKey: .menuImageUrl)
		itemId = try? container.decode(Int?.self, forKey: .itemId)
		itemCount = try? container.decode(Int?.self, forKey: .itemCount)
		cartRefrences = try? container.decode(CartReference?.self, forKey: .cartRefrences)
        calories = try? container.decode(Int?.self, forKey: .calories)
        timeRange = try? container.decode([TimeRange]?.self, forKey: .timeRange)
        isTimeRangeSet = try? container.decode(Bool?.self, forKey: .isTimeRangeSet)
		self.templates = []
		self.cartCount = cartRefrences?.quantity ?? 0
		for templateObject in cartRefrences?.customised ?? [] {
			let count = templateObject.totalQuantity ?? 0
			for _ in 0..<count {
				templates?.append(templateObject)
			}
		}
		self.cartCount = self.cartRefrences?.quantity ?? 0
	}
    
    func convertToMenuItem() -> MenuItem {
        return MenuItem(menuId: self.menuId ?? "", _id: self._id ?? "", nameArabic: self.nameArabic ?? "", descriptionEnglish: self.descriptionEnglish ?? "", nameEnglish: self.nameEnglish ?? "", isCustomised: self.isCustomised ?? false, price: self.price ?? 0.0, descriptionArabic: self.descriptionArabic ?? "", itemImageUrl: self.itemImageUrl ?? "", allergicComponent: self.allergicComponent ?? [], isAvailable: self.isAvailable ?? false, modGroups: self.modGroups ?? [], cartCount: self.cartCount ?? 0, templates: self.templates ?? [], titleArabic: self.titleArabic ?? "", titleEnglish: self.titleEnglish ?? "", itemId: self.itemId ?? 0, servicesAvailable: "", calories: self.calories, excludeLocations: [])
    }
	
	static func getFormatForRecentlySearched(forItem item: MenuItem) -> MenuSearchResultItem {
        return MenuSearchResultItem(menuId: item.menuId ?? "", _id: item._id ?? "", titleEnglish: item.titleEnglish ?? "", titleArabic: item.titleArabic ?? "", isCategory: false, isItem: true, descriptionEnglish: item.descriptionEnglish ?? "", descriptionArabic: item.descriptionArabic ?? "", nameEnglish: item.nameEnglish ?? "", nameArabic: item.nameArabic ?? "", itemImageUrl: item.itemImageUrl ?? "", price: item.price ?? 0.0, allergicComponent: item.allergicComponent ?? [], isCustomised: item.isCustomised ?? false, menuImageUrl: nil, itemCount: nil, cartCount: item.cartCount ?? 0, isAvailable: item.isAvailable ?? true, itemId: item.itemId ?? 0, calories: item.calories)
	}
}
