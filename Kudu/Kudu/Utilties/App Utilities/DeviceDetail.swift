import UIKit

struct DeviceDetail {

    /// Enum - NetworkTypes
    enum NetworkType: String {
        case _2G = "2G"
        case _3G = "3G"
        case _4G = "4G"
        case lte = "LTE"
        case wifi = "Wifi"
        case none = ""
    }

    /// Device Model
    static var deviceModel: String {
        return UIDevice.current.model
    }

    /// OS Version
    static var osVersion: String {
        return UIDevice.current.systemVersion
    }

    /// Platform
    static var platform: String {
        return UIDevice.current.systemName
    }

    /// Device Id
    static var deviceId: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "dummydeviceid"
    }

    static var currentCountryCode: String {
        guard let code = Locale.current.regionCode else { return "us" }
        return code.lowercased()
    }
    
    static var deviceToken: String {
        return "dummyToken"
    }
    
    enum DeviceType: String {
        case none = "0"
        case android = "1"
        case iOS = "2"
        case web = "3"
        
        init(type: Int) {
            switch type {
            case 0:
                self = .none
            case 1:
                self = .android
            case 2:
                self = .iOS
            default:
                self = .web
            }
        }
    }

}
