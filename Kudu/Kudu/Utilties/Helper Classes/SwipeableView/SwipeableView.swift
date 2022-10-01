//
//  SwipeableView.swift
//  Created by Admin on 04/01/22.
//

import UIKit

enum SwipeDirection {
    case left
    case right
    case up
    case down
}

class SwipeableView: UIView {
    
    var upSwipe: (() -> Void)?
    var downSwipe: (() -> Void)?
    var leftSwipe: (() -> Void)?
    var rightSwipe: (() -> Void)?
    
    var swipeGestures: [SwipeDirection]? {
        didSet {
            addSwipeGestures()
        }
    }
    
    func addSwipeGestures() {
        swipeGestures?.forEach({
            switch $0 {
            case .down:
                let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
                swipeDown.direction = .down
                self.addGestureRecognizer(swipeDown)
            case .left:
                let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
                swipeDown.direction = .left
                self.addGestureRecognizer(swipeDown)
            case .right:
                let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
                swipeDown.direction = .right
                self.addGestureRecognizer(swipeDown)
            case .up:
                let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
                swipeDown.direction = .up
                self.addGestureRecognizer(swipeDown)
            }
        })
    }

    @objc private func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
                self.rightSwipe?()
            case .down:
                print("Swiped down")
                self.downSwipe?()
            case .left:
                print("Swiped left")
                self.leftSwipe?()
            case .up:
                print("Swiped up")
                self.upSwipe?()
            default:
                break
            }
        }
    }
}
