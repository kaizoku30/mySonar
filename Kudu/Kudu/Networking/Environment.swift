//
//  Environment.swift
//  Kudu
//
//  Created by Admin on 02/05/22.
//

import Foundation

public enum PlistKey: String {
    case kBaseUrl
    
    var keyValue: String {
        return self.rawValue.description
    }
}

enum EnvironmentType {
    case debug
    case qa
    case stg
    case prod
}

public struct Environment {
    
    fileprivate var infoDict: [String: Any] {
            if let dict = Bundle.main.infoDictionary {
                return dict
            } else {
                fatalError("Plist file not found")
            }
    }
    
    public func configuration(_ key: PlistKey) -> String {
        return infoDict[key.keyValue] as? String ?? ""
    }
}
