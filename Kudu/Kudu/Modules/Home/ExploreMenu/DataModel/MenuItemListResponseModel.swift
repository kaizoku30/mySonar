//
//  MenuItemListResponseModel.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import Foundation
import UIKit

struct MenuItemListResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [MenuItem]?
}

struct MenuItem: Codable {
    let menuId: String?
    let _id: String?
    let nameArabic: String?
    let calories: Int?
    let descriptionEnglish: String?
    let nameEnglish: String?
    let isCustomised: Bool?
    let price: Double?
    let descriptionArabic: String?
    let itemImageUrl: String?
    let allergicComponent: [AllergicComponent]?
    var isAvailable: Bool?
    var isFavourites: Bool?
    var modGroups: [ModGroup]?
    var cartCount: Int?
    var templates: [CustomisationTemplate]?
    var verticalOffset: Double?
    let titleArabic: String?
    let titleEnglish: String?
    let itemId: Int?
    var cartRefrences: CartReference?
    var servicesAvailable: String?
    
    private enum CodingKeys: String, CodingKey {
        case menuId, _id, nameArabic, descriptionEnglish, nameEnglish, isCustomised, price, descriptionArabic, itemImageUrl, allergicComponent, isAvailable, isFavourites, modGroups, cartCount, templates, verticalOffset, titleArabic, titleEnglish, itemId, cartRefrences, servicesAvailable, calories }
    
    init(menuId: String?, _id: String?, nameArabic: String?, descriptionEnglish: String?, nameEnglish: String?, isCustomised: Bool?, price: Double?, descriptionArabic: String?, itemImageUrl: String?, allergicComponent: [AllergicComponent]?, isAvailable: Bool?, modGroups: [ModGroup]?, cartCount: Int?, templates: [CustomisationTemplate]?, titleArabic: String?, titleEnglish: String?, itemId: Int?, servicesAvailable: String?, calories: Int?) {
        self.menuId = menuId
        self._id = _id
        self.nameArabic = nameArabic
        self.descriptionEnglish = descriptionEnglish
        self.nameEnglish = nameEnglish
        self.isCustomised = isCustomised
        self.price = price
        self.descriptionArabic = descriptionArabic
        self.itemImageUrl = itemImageUrl
        self.allergicComponent = allergicComponent
        self.isAvailable = isAvailable
        self.modGroups = modGroups
        self.templates = templates
        self.titleArabic = titleArabic
        self.titleEnglish = titleEnglish
        self.itemId = itemId
        self.cartCount = cartCount
        self.servicesAvailable = servicesAvailable
        self.calories = calories
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        menuId = try? container.decode(String?.self, forKey: .menuId)
        _id = try? container.decode(String?.self, forKey: ._id)
        nameArabic = try? container.decode(String?.self, forKey: .nameArabic)
        descriptionEnglish = try? container.decode(String?.self, forKey: .descriptionEnglish)
        nameEnglish = try? container.decode(String?.self, forKey: .nameEnglish)
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
        verticalOffset = try? container.decode(Double?.self, forKey: .verticalOffset)
        titleArabic = try? container.decode(String?.self, forKey: .titleArabic)
        titleEnglish = try? container.decode(String?.self, forKey: .titleEnglish)
        itemId = try? container.decode(Int?.self, forKey: .itemId)
        cartRefrences = try? container.decode(CartReference?.self, forKey: .cartRefrences)
        servicesAvailable = try? container.decode(String?.self, forKey: .servicesAvailable)
        self.templates = []
        self.cartCount = cartRefrences?.quantity ?? 0
        for templateObject in cartRefrences?.customised ?? [] {
            let count = templateObject.totalQuantity ?? 0
            for _ in 0..<count {
                templates?.append(templateObject)
            }
        }
        self.cartCount = self.cartRefrences?.quantity ?? 0
        self.calories = try? container.decode(Int?.self, forKey: .calories)
    }
}

struct CartReference: Codable {
    let quantity: Int?
    let services: String?
    let _id: String?
    let itemSdmId: Int?
    let menuId: String?
    let customised: [CustomisationTemplate]?
}

struct CustomisationTemplate: Codable {
    var modGroups: [ModGroup]?
    var hashId: String?
    var _id: String?
    var cartId: String?
    var totalQuantity: Int?
}

enum ModType: String {
    case drink
    case add
    case remove
    case replace
}

enum DrinkSize: String {
    case regular = "1"
    case medium = "2"
    case large = "3"
    
    var title: String {
        switch self {
        case .regular:
            return "Regular"
        case .medium:
            return "Medium"
        case .large:
            return "Large"
        }
    }
}

struct DrinkSizeObject {
    let drinkSize: DrinkSize
    var selectedState: Bool = false
}

struct ModGroup: Codable {
    let _id: String?
    let modGroupId: Int?
    let maximum: Int?
    let minimum: Int?
    let modifiersId: [String]?
    let isRequired: Bool?
    let titleUn: String?
    let title: String?
    let isAvailable: Bool?
    let modType: String?
    var modifiers: [ModifierObject]?
    var selectedDrinkSizeInApp: String?
    var checkMarkCount: Int?
    var addTypeModifiers: [String]?
    
    static func sortAndGetDrinkSizes(drinks: [ModifierObject]) -> [DrinkSizeObject] {
        var drinksSizeTypes: [DrinkSizeObject] = []
        let regularExists = drinks.contains(where: {
            guard let drinkSize = DrinkSize(rawValue: $0.drinkSize ?? "") else { return false }
            return drinkSize == .regular
        })
        let mediumExists = drinks.contains(where: {
            guard let drinkSize = DrinkSize(rawValue: $0.drinkSize ?? "") else { return false }
            return drinkSize == .medium
        })
        let largeExists = drinks.contains(where: {
            guard let drinkSize = DrinkSize(rawValue: $0.drinkSize ?? "") else { return false }
            return drinkSize == .large
        })
        if regularExists {
            drinksSizeTypes.append(DrinkSizeObject(drinkSize: .regular))
        }
        if mediumExists {
            drinksSizeTypes.append(DrinkSizeObject(drinkSize: .medium))
        }
        if largeExists {
            drinksSizeTypes.append(DrinkSizeObject(drinkSize: .large))
        }
        drinksSizeTypes.sort(by: { $0.drinkSize.rawValue < $1.drinkSize.rawValue })
        return drinksSizeTypes
    }
    
    static func getRequestJSON(modGroups: [ModGroup]) -> [[String: Any]] {
        var array: [[String: Any]] = []
        modGroups.forEach({ (modGroup) in
            var modifierArray: [[String: Any]] = []
            modGroup.modifiers?.forEach({ (modifier) in
                modifierArray.append(getModifierObjectJSON(modifier: modifier))
            })
            array.append(getModGroupJSON(modGroup: modGroup, modifierArray: modifierArray))
        })
        
        func getModifierObjectJSON(modifier: ModifierObject) -> [String: Any] {
            var json: [String: Any] = ["_id": modifier._id ?? "",
                                       "maximum": modifier.maximum ?? 0,
                                       "minimum": modifier.minimum ?? 0,
                                       "nameArabic": modifier.nameArabic ?? "",
                                       "nameEnglish": modifier.nameEnglish ?? "",
                                       "sdmId": modifier.sdmId ?? 0,
                                       "isAvailable": modifier.isAvailable ?? false,
                                       "count": modifier.count ?? 0]
            if let modifierImageUrl = modifier.modifierImageUrl, !modifierImageUrl.isEmpty {
                json["modifierImageUrl"] = modifier.modifierImageUrl ?? ""
            }
            if let modifierImageUrl = modifier.drinkSize, !modifierImageUrl.isEmpty {
                json["drinkSize"] = modifier.drinkSize ?? ""
            }
            if modifier.price.isNotNil {
                json["price"] = modifier.price ?? 0.0
            }
            return json
        }
        
        func getModGroupJSON(modGroup: ModGroup, modifierArray: [[String: Any]]) -> [String: Any] {
            let json: [String: Any] = ["_id": modGroup._id ?? "",
                                       "maximum": modGroup.maximum ?? 0,
                                       "minimum": modGroup.minimum ?? 0,
                                       "modifiersId": modGroup.modifiersId ?? [],
                                       "isRequired": modGroup.isRequired ?? false,
                                       "titleUn": modGroup.titleUn ?? "",
                                       "title": modGroup.title ?? "",
                                       "modGroupId": modGroup.modGroupId ?? 0,
                                       "isAvailable": modGroup.isAvailable ?? false,
                                       "modType": modGroup.modType ?? "",
                                       "modifiers": modifierArray]
            return json
        }
        return array
    }
}

struct ModifierObject: Codable {
    let _id: String?
    let maximum: Int?
    let minimum: Int?
    let modifierImageUrl: String?
    let nameArabic: String?
    let nameEnglish: String?
    let price: Double?
    let isAvailable: Bool?
    let sdmId: Int?
    var count: Int?
    let drinkSize: String?
    var addedToTemplate: Bool?
}

struct AllergicComponent: Codable {
    let _id: String?
    let name: String?
    let imageUrl: String?
    let nameArabic: String?
}
