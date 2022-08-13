//
//  MenuItemListResponseModel.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import Foundation

struct MenuItemListResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [MenuItem]?
}

struct MenuItem: Codable {
    let _id: String?
    let nameArabic: String?
    let descriptionEnglish: String?
    let nameEnglish: String?
    let isCustomised: Bool?
    let price: Double?
    let descriptionArabic: String?
    let itemImageUrl: String?
    let allergicComponent: [AllergicComponent]?
    var currentCartCountInApp: Int?
    var isLikedInApp: Bool?
}

struct AllergicComponent: Codable {
    let _id: String?
    let name: String?
    let imageUrl: String?
}

/*
 "_id" : "62d11b494f2f4d90d9f3b4a0",
 "nameArabic" : "وجبة فيلي ستيك",
 "descriptionEnglish" : "(1385 Kcal) Grilled beef strips together with onion, mushrooms and cheese, stacked inside Kudu?s fresh bread, served with French fries and soft drink",
 "nameEnglish" : "Philly Steak Combo",
 "isCustomised" : true,
 "price" : 31,
 "descriptionArabic" : "(1385 سعرة حرارية) قطع لحم مشوية مع البصل والمشروم والجبنة في خبز كودو الطازج تقدم مع البطاطس المقلية والمشروب البارد",
 "itemImageUrl" : "https:\/\/app-development.s3.amazonaws.com\/menu_image.png",
 "allergicComponent" : [

 ],
 "id" : "62d11b494f2f4d90d9f3b4a0"
 
 
 "allergicComponent" : [
         {
             "_id" : ObjectId("62d14532abbfd064ffff2747"),
             "name" : "string 123",
             "imageUrl" : "string"
         }
     ]
 */
