//
//  AnimatableImageView.swift
//  Kudu
//
//  Created by Admin on 13/06/22.
//

import UIKit
import Gifu

class GIFView: UIView, GIFAnimatable {
    public lazy var animator: Animator? = {
        return Animator(withDelegate: self)
      }()

      override public func display(_ layer: CALayer) {
        updateImageIfNeeded()
      }
}
