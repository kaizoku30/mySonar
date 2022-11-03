//
//  CGPoint+Extension.swift
//
//  Created by Nick Kopilovskii on 06.08.2018.
//  Copyright © 2018 Nick Kopilovskii. All rights reserved.
//

import CoreGraphics

protocol Radial {
  
  func distance(to point: CGPoint) -> CGFloat
  
  func angle(with p1: CGPoint, _ p2: CGPoint) -> CGFloat
  
  func point(on distance: CGFloat, with angle: CGFloat) -> CGPoint
  
  
}

extension CGPoint: Radial {
  
  func distance(to point: CGPoint) -> CGFloat {
    return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
  }

  func angle(with p1: CGPoint, _ p2: CGPoint) -> CGFloat {
    let a = distance(to: p1)
    let b = distance(to: p2)
    let c = p1.distance(to: p2)
    
    return acos((pow(a,2) + pow(b,2) - pow(c,2))/(2 * a * b))
  }
  
  func point(on distance: CGFloat, with angle: CGFloat) -> CGPoint {
    return CGPoint(x: x + distance * cos(angle - .pi / 2), y: y + distance * sin(angle - .pi / 2))
  }
  
}
