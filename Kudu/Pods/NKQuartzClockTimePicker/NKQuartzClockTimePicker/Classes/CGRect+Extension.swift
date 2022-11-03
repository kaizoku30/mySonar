//
//  CGRect+RadialDivision.swift
//
//  Created by Nick Kopilovskii on 03.08.2018.
//  Copyright © 2018 Nick Kopilovskii. All rights reserved.
//

import CoreGraphics

protocol NKQCRect {

  var center: CGPoint { get set }
  
  var incircleRadius: CGFloat { get }
  
  var topControlPoint: CGPoint { get }
  
  var bottomControlPoint: CGPoint { get }
  
  var square: CGRect { get }
  
  func scaled(to value: CGFloat) -> CGRect
  
  func changedSize(with value: CGFloat) -> CGRect
  
  func new(with size: CGSize) -> CGRect
  
  func incircleDevidePoints(_ count: UInt) -> [CGPoint]
  
  func incircleDevidePoint(for index: UInt, in count: UInt) -> CGPoint
  
}


extension CGRect: NKQCRect {
  
  var center: CGPoint {
    set { self.origin = CGPoint(x: newValue.x - width / 2, y: newValue.y - height / 2) }
    get { return CGPoint(x: origin.x + width / 2, y: origin.y + height / 2) }
  }
  
  var incircleRadius: CGFloat {
    return min(width, height) / 2
  }
  
  var topControlPoint: CGPoint {
    return center.point(on: incircleRadius, with: 0)
  }
  
  var bottomControlPoint: CGPoint {
    return center.point(on: incircleRadius, with: .pi)
  }
  
  var square: CGRect {
    get {
      var sRect = CGRect(origin: CGPoint.zero, size: CGSize(width: min(width, height), height: min(width, height)))
      sRect.center = center
      return sRect
    }
  }

  func scaled(to value: CGFloat) -> CGRect {
    let nSize = CGSize(width: width * value, height: width * value)
    return new(with: nSize)
  }
  
  func changedSize(with value: CGFloat) -> CGRect {
    let nSize = CGSize(width: width + value, height: height + value)
    return new(with: nSize)
  }
  
  func new(with nSize: CGSize) -> CGRect {
    var nRect = CGRect(origin: .zero, size: nSize)
    nRect.center = center
    return nRect
  }
  
  func incircleDevidePoints(_ count: UInt) -> [CGPoint] {
    guard count > 0 else { return [CGPoint]() }
    
    var points = [CGPoint]()
    let radius = incircleRadius
    let singleAngle = 2 * .pi / CGFloat(count)
    let center = self.center
    
    (1...count).forEach { points.append(center.point(on: radius, with: singleAngle * CGFloat($0))) }
//    for i in 1...count {
//      points.append(center.point(on: radius, with: singleAngle * CGFloat(i)))
//    }
    
    return points
  }
  
  func incircleDevidePoint(for index: UInt, in count: UInt) -> CGPoint {
    return center.point(on: incircleRadius, with: 2 * .pi * CGFloat(index) / CGFloat(count))
  }
}
