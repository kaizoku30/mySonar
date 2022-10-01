//
//  Shimmer+UIView.swift
//  KUDU
//
//  Created by Ronit Tushir on 28/01/22.
//

import UIKit
import SwiftUI

extension UIView {
    var gradientColorOne: CGColor {
        return AppColors.kuduThemeYellow.withAlphaComponent(0.1).cgColor }
        //UIColor(white: 0.85, alpha: 0.5).cgColor }
    var gradientColorTwo: CGColor {
        return AppColors.kuduThemeBlue.withAlphaComponent(0.1).cgColor }
        //UIColor(white: 0.95, alpha: 0.5).cgColor }

    private func addAnimation() -> CABasicAnimation {
           
            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [-1.0, -0.5, 0.0]
            animation.toValue = [1.0, 1.5, 2.0]
            animation.repeatCount = .infinity
            animation.duration = 0.9
            return animation
        }
        
    func startShimmering() {
        
        let alreadyAdded = layer.sublayers?.contains(where: {$0.name == "ShimmerLayer"}) ?? false
        if alreadyAdded, let index = layer.sublayers?.firstIndex(where: {$0.name == "ShimmerLayer"}) {
            layer.sublayers?.remove(at: index)
        }
        let gradientLayer = addGradientLayer()
        let animation = addAnimation()
        gradientLayer.add(animation, forKey: animation.keyPath)
        
    }
    
    private func addGradientLayer() -> CAGradientLayer {
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
            gradientLayer.name = "ShimmerLayer"
            gradientLayer.locations = [0.0, 0.5, 1.0]
            gradientLayer.frame = self.bounds
        self.layer.addSublayer(gradientLayer)
            return gradientLayer
        }
    
    var isShimmering: Bool {
        let alreadyAdded = layer.sublayers?.contains(where: {$0.name == "ShimmerLayer"}) ?? false
        return alreadyAdded
    }
    
    func stopShimmering() {
        self.layer.sublayers?.forEach({
            if $0.name == "ShimmerLayer" { $0.removeFromSuperlayer()}
        })
    }
}
