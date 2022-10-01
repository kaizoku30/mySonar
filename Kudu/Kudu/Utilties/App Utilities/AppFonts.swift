//
//  AppFonts.swift
//  Kudu
//
//  Created by Admin on 02/05/22.
//

import UIKit

enum AppFonts: String {
    case mulishBlack = "Mulish-Black"
    case mulishBlackItalic = "Mulish-BlackItalic"
    case mulishBold = "Mulish-Bold"
    case mulishBoldItalic = "Mulish-BoldItalic"
    case mulishExtraBold = "Mulish-ExtraBold"
    case mulishExtraBoldiTalic = "Mulish-ExtraBoldItalic"
    case mulishExtraLight = "Mulish-ExtraLight"
    case mulishExtraLightItalic = "Mulish-ExtraLightItalic"
    case mulishItalic = "Mulish-Italic"
    case mulishLightItalic = "Mulish-LightItalic"
    case mulishMedium = "Mulish-Medium"
    case mulishMediumItalic = "Mulish-MediumItalic"
    case mulishRegular = "Mulish-Regular"
    case mulishSemiBold = "Mulish-SemiBold"
    case mulishSemiBoldItalic = "Mulish-SemiBoldItalic"
    case prequelDemoRegular = "PrequelDemo-Regular"
    case captureIt = "CaptureIt"
}

extension AppFonts {
    func withSize(_ fontSize: CGFloat) -> UIFont {
        if let font = UIFont(name: self.rawValue, size: fontSize) {
          return font
        } else {
           printDebug("Font Not Found")
           return UIFont.systemFont(ofSize: fontSize)
        }
    }

    func withDefaultSize() -> UIFont {
        if let font = UIFont(name: self.rawValue, size: 15.0) {
            return font
        } else {
             printDebug("Font Not Found")
             return UIFont.systemFont(ofSize: 15.0)
        }
    }
}
