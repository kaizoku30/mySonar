//
//  NKQCTimeButton.swift
//
//  Created by Nick Kopilovskii on 07.08.2018.
//  Copyright © 2018 Nick Kopilovskii. All rights reserved.
//

import UIKit


class NKQCTimeButton: UIButton {
  
  var normalStateConfig: NKQCTimeButtonConfiguration = NKQCTimeButtonConfiguration() {
    didSet {
      if selection == false { set(normalStateConfig) }
    }
  }
  
  var selectedStateConfig: NKQCTimeButtonConfiguration = NKQCTimeButtonConfiguration(){
    didSet {
      if selection == true { set(selectedStateConfig) }
    }
  }
  
  var selection: Bool = false {
    didSet {
      set(selection == true ? selectedStateConfig : normalStateConfig)
    }
  }
  
  var currentConfig: NKQCTimeButtonConfiguration {
    return selection == true ? selectedStateConfig : normalStateConfig
  }

  
  func set(_ config: NKQCTimeButtonConfiguration) {
    UIView.animate(withDuration: 0.15) {
      self.setTitleColor(config.textConfig.color, for: .normal)
      self.titleLabel?.font = config.textConfig.font()
      
      self.frame = self.frame.new(with: config.size)
      
      self.backgroundColor = config.backgroundColor
      self.layer.cornerRadius = config.cornerRadius
      self.layer.borderWidth = config.borderWidth
      self.layer.borderColor = config.borderColor
      self.clipsToBounds = true
    }
  }
  
}
