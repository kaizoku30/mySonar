//
//  CAShapeLayer+Notch.swift
//
//  Created by Nick Kopilovskii on 06.08.2018.
//  Copyright © 2018 Nick Kopilovskii. All rights reserved.
//

import UIKit

protocol NKQCNotchDrawable {
  static func layer(with notchConfig: NKQCNotchConfiguration, in rect: CGRect) -> CAShapeLayer
  func drawNotch(_ config: NKQCNotchConfiguration)
}


extension CAShapeLayer: NKQCNotchDrawable {
  
  static func layer(with notchConfig: NKQCNotchConfiguration, in rect: CGRect) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.frame = rect
    layer.backgroundColor = UIColor.clear.cgColor
    layer.drawNotch(notchConfig)
    return layer
  }
  
  func drawNotch(_ config: NKQCNotchConfiguration) {
    
    switch config.style {
    case .dots:
      path = dots(config.count ?? 0, with: config.width, in: bounds)
      strokeColor = UIColor.clear.cgColor
      lineWidth = 0
      fillColor = config.color.cgColor
      fillRule = kCAFillRuleEvenOdd
      strokeStart = 0
      strokeEnd = 1
      
    case .dashes(let length):
      path = dashes(config.count ?? 0, with: length, in: bounds)
      strokeColor = config.color.cgColor
      lineWidth = config.width
      fillColor = UIColor.clear.cgColor
      strokeStart = 0
      strokeEnd = 1
      
    case .line:
      path = line(in: bounds.square)
      strokeColor = config.color.cgColor
      lineWidth = config.width
      fillColor = UIColor.clear.cgColor
      strokeStart = 0
      strokeEnd = 1
    }
    
  }
  
  fileprivate func dots(_ count: UInt, with width: CGFloat, in rect: CGRect) -> CGPath {
    let points = rect.incircleDevidePoints(count)
    let path = UIBezierPath()
    
    points.forEach { point in path.append(UIBezierPath(roundedRect: CGRect(x: point.x - width / 2, y: point.y - width / 2, width: width, height: width), cornerRadius: width / 2)) }
//    path.close()
    
    return path.cgPath
  }
  
  fileprivate func dashes(_ count: UInt, with length: CGFloat, in rect: CGRect) -> CGPath {
    guard count > 0 else { return UIBezierPath().cgPath }
    
    let outerPoints = rect.incircleDevidePoints(count)
    let innerPoints = rect.changedSize(with: -length * 2).incircleDevidePoints(count)
    
    let path = UIBezierPath()
    
    (0...(Int(count) - 1)).forEach {
      let dash = UIBezierPath()
      dash.move(to: outerPoints[$0])
      dash.addLine(to: innerPoints[$0])
      dash.close()
      
      path.append(dash)
    }
//    for i in 0...(Int(count) - 1) {
//      let dash = UIBezierPath()
//      dash.move(to: outerPoints[i])
//      dash.addLine(to: innerPoints[i])
//      dash.close()
//
//      path.append(dash)
//    }
    
    return path.cgPath
  }
  
  
  fileprivate func line(in rect: CGRect) -> CGPath {
    return UIBezierPath(roundedRect: rect, cornerRadius: rect.incircleRadius).cgPath
  }
}
