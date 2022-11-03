//
//  CAShapeLayer+Hand.swift
//
//  Created by Nick Kopilovskii on 08.08.2018.
//  Copyright © 2018 Nick Kopilovskii. All rights reserved.
//

import UIKit

protocol NKQCHandDrawable {
  static func layer(with handConfig: NKQCHandConfiguration, in rect: CGRect) -> CAShapeLayer
  func drawHand(_ config: NKQCHandConfiguration)
  
}

extension CAShapeLayer: NKQCHandDrawable {
  
  static func layer(with handConfig: NKQCHandConfiguration, in rect: CGRect) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.frame = rect
    layer.backgroundColor = UIColor.clear.cgColor
    layer.drawHand(handConfig)
    return layer
  }
  
  func drawHand(_ config: NKQCHandConfiguration) {
    let hand = UIBezierPath()
    hand.move(to: bounds.center)
    hand.addLine(to: bounds.center.point(on: bounds.incircleRadius, with: 0) )
    
    path = hand.cgPath
    strokeColor = config.color.cgColor
    lineWidth = config.width
    strokeStart = 0
    strokeEnd = 1
  }
  
  

}

