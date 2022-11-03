//
//  NKQCConfig.swift
//
//  Created by Nick Kopilovskii on 06.08.2018.
//  Copyright © 2018 Nick Kopilovskii. All rights reserved.
//

import QuartzCore
import UIKit.UIColor
import UIKit.UIFont

/**
 Required to indicate type of selectable time component
 */
public enum NKQCTimeComponent {
  case second
  case minute
  /**12 hours (AM/PM) time format */
  case hour12
  /**24 hours (military) time format */
  case hour24
  
  var count: Int {
    switch self {
    case .second, .minute: return 60
    case .hour12: return 12
    case .hour24: return 24
    }
  }
  
  func lastValue() -> Int {
    switch self {
    case .second, .minute, .hour24: return 0
    case .hour12: return 12
    }
  }
  
  func stringValue(for index: Int) -> String? {
    if index == count { return String(lastValue()) }
    guard index < count  else { return nil }
    return String(index)
  }
  
  func singleAngle() -> CGFloat {
    return .pi * 2 / CGFloat(count)
  }
  
}
/**
 Struct for setting clockface time button display format.
 
 Default values: textConfig = NKQCTextConfiguration(); sideLength = 20.0; backgroundColor = UIColor.white; cornerRadius = 0.0; borderWidth = 0.0; borderColor = UIColor.clear.cgColor
 */
public struct NKQCTimeButtonConfiguration {
  public var textConfig: NKQCTextConfiguration
  public var sideLength: CGFloat
  public var backgroundColor: UIColor
  public var cornerRadius: CGFloat
  public var borderWidth: CGFloat
  public var borderColor: CGColor
  
  public var size: CGSize {
    return CGSize(width: sideLength, height: sideLength)
  }
  
  public init() {
    textConfig = NKQCTextConfiguration()
    sideLength = 20.0
    backgroundColor = .white
    cornerRadius = 0.0
    borderWidth = 0.0
    borderColor = UIColor.clear.cgColor
  }

}

/**
 Struct for setting text display format.
 
 Default values: fontName = "System"; size = 14.0; color = UIColor.black
 */
public struct NKQCTextConfiguration {
  public var fontName: String
  public var size: CGFloat
  public var color: UIColor
  
  public init() {
    fontName = "System"
    size = 14.0
    color = .black
  }
  
  /**Return font with setted params*/
  public func font() -> UIFont {
    return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
  }
}

/**
 Struct for setting clock hand display format.
 
 Default values: color = .black; width = 1.0
 */
public struct NKQCHandConfiguration {
  public var color: UIColor
  public var width: CGFloat
  
  public init() {
    color = .black
    width = 1.0
  }
}

/**
 Struct for setting clockface notches display format.
 
 Default values: style = NKQCNotchConfiguration.Style.line; width = 1.0; color = UIColor.black; count = 0
 */
public struct NKQCNotchConfiguration {
  public var style: Style
  public var width: CGFloat
  public var color: UIColor
  public var count: UInt?
  
  /**Style of the notch*/
  public enum Style {
    /**Single full line*/
    case line
    /**Dashes. Incoming parametr sets dash length*/
    case dashes(CGFloat)
    /**Dots*/
    case dots
  }
  
  public init() {
    style = .line
    width = 1.0
    color = .black
    count = 0
  }
}
