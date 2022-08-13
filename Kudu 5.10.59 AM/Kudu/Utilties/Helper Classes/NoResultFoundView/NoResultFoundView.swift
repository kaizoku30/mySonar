//
//  NoResultFoundView.swift
//  VIDA
//
//  Created by Admin on 02/02/22.
//

import UIKit
import MapKit

class NoResultFoundView: UIView {

    enum ResultType {
        case noMyAddress
        case noResultFound
        case none
    }
    
    // MARK: IBOutlets
    @IBOutlet private weak var mainContentView: UIView!
    @IBOutlet private weak var resultLabel: UILabel!
    
    var contentType: ResultType = .none {
        didSet {
            updateLabel()
        }
    }
    
    var show: Bool = false {
        didSet {
            self.alpha = show ? 1 : 0
        }
    }
    
    var enableSwipeGestures: Bool = false {
        didSet {
            if enableSwipeGestures == true {
                let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(leftSwiped))
                leftSwipe.direction = .left
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(rightSwiped))
                rightSwipe.direction = .right
                self.addGestureRecognizer(leftSwipe)
                self.addGestureRecognizer(rightSwipe)
            }
        }
    }
    
    var leftSwipe: (() -> Void)?
    var rightSwipe: (() -> Void)?
        
    @objc private func leftSwiped() {
        self.leftSwipe?()
    }
    
    @objc private func rightSwiped() {
        self.rightSwipe?()
    }
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
}

extension NoResultFoundView {
    private func commonInit() {
        Bundle.main.loadNibNamed("NoResultFoundView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func updateLabel() {
        switch contentType {
        case .noMyAddress:
            resultLabel.text = "No address added"
        case .noResultFound:
            resultLabel.text = "No result found"
        default:
            resultLabel.text = "Under Development"
        }
    }
}
