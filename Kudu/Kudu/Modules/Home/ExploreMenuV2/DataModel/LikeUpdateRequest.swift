//
//  LikeUpdateRequest.swift
//  Kudu
//
//  Created by Admin on 09/11/22.
//

import Foundation

extension ExploreMenuV2VM {
    struct LikeUpdateRequest {
        var liked: Bool
        var itemId: String
        var hashId: String
        var modGroups: [ModGroup]?
        var tableIndex: Int
    }
}
