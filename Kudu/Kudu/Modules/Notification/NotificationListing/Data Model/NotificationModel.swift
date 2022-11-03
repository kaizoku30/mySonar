//
//  NotificationModel.swift
//  Kudu
//
//  Created by Harpreet Kaur on 2022-10-20.
//

import Foundation

struct NotificationResponse: Codable {
    
    let message: String?
    let statusCode: Int?
    let data: NotificationModel?
    
}

struct NotificationModel: Codable {
    
    let pageNo: Int?
    let limit: Int?
    let filterCount: Int?
    let total: Int?
    let totalPage: Int?
    let nextHit: Int?
    let data: [NotificationList]?
    
}

struct NotificationList: Codable {
    
    let _id: String?
    let subjectAr: String?
    let status: String?
    let userId: String?
    let descriptionAr: String?
    let subject: String?
    let notificationType: String?
    let description: String?
    let messageType: String?
    
}
