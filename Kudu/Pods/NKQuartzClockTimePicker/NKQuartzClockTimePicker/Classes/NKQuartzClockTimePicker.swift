//
//  NKQuartzClockTimePicker.swift
//
//  Created by Nick Kopilovskii on 07.08.2018.
//  Copyright © 2018 Nick Kopilovskii. All rights reserved.
//

import UIKit

//MARK: - NKQCTimeComponentPickerDataSource
/**
 Protocol declares the methods necessary to display the button and its title in accordance with the indicated time.
 */
@objc public protocol NKQuartzClockTimePickerDataSource: class {
  /**
   Returns BOOL value specifying the need to display a button corresponding to the incoming time
   */
  func clockPicker(_ picker: NKQuartzClockTimePicker, shouldAddTitleFor time: Int) -> Bool
  
  /**
   Returns String value that specifies the title of the button corresponding to the transmitted time.
   
   If returned value == nil, as value will be setted default String(time)
   */
  func clockPicker(_ picker: NKQuartzClockTimePicker, titleFor time: Int) -> String?
}

//MARK: - NKQCTimeComponentPickerDelegate
/**
 Protocol declares the methods to be called when the state of the picker changes
 */
@objc public protocol NKQuartzClockTimePickerDelegate: class {
  /**
   Method is called when time picker value is changed
   */
  func clockPicker(_ picker: NKQuartzClockTimePicker, didChange time: Int)
}



//MARK: - NKQCTimeComponentPicker
//MARK: Properties & lifecicle

@IBDesignable
public class NKQuartzClockTimePicker: UIView {

  /**
   Object that implements protocol NKQuartzClockTimePickerDataSource
   */
  @IBOutlet public weak var dataSource: NKQuartzClockTimePickerDataSource?
  
  /**
   Object that implements protocol NKQuartzClockTimePickerDelegate
   */
  @IBOutlet public weak var delegate: NKQuartzClockTimePickerDelegate?
  
  
  /**
   Type of selectable time component.
   
   Default value = NKQCTimeComponent.second
   */
  public var timeComponent: NKQCTimeComponent = .second {
    didSet { putTimeButtons() }
  }
  
  /**
   Current time component value.
   
   Values for seconds and minutes in range 0...59
   
   Values for 12 hours format in range 1...12
   
   Values for 24 hours format in range 0...23
   */
  private (set) public var time: Int = 0
  
  /**
   Indent buttons from the nearest NKQuartzClockTimePicker view side
   */
  @IBInspectable public var timeButtonsMargin: CGFloat = 0.0 {
    didSet { putTimeButtons() }
  }
  
  /**
   Settings clockface time button display format for normal (unselected) state.
   
   Default value = NKQCTimeButtonConfiguration()
   */
  public var timeButtonNormalConfig: NKQCTimeButtonConfiguration = NKQCTimeButtonConfiguration() {
    didSet { putTimeButtons() }
  }
  
  /**
   Settings clockface time button display format for selected state.
   
   Default value = NKQCTimeButtonConfiguration()
   */
  public var timeButtonSelectedConfig: NKQCTimeButtonConfiguration = NKQCTimeButtonConfiguration() {
    didSet { putTimeButtons() }
  }
  
  /**
   Indent notches from the nearest NKQuartzClockTimePicker view side.
   */
  @IBInspectable public var notchMargin: CGFloat = 0.0 {
     didSet { drawNotch() }
  }
  
  /**
   Array of NKQCNotchConfiguration for combining notches on clockface.
   
   Notche's layers are superimposed in the order of adding to the array
   */
  public var notches: [NKQCNotchConfiguration]? {
    didSet { drawNotch() }
  }
  
  /**
   Indent of clock hand end from the nearest NKQuartzClockTimePicker view side
   */
  @IBInspectable public var handMargin: CGFloat = 0.0 {
    didSet { drawHand() }
  }
  
  /**
   Settings clock hand display format.
   */
  public var hand: NKQCHandConfiguration = NKQCHandConfiguration() {
    didSet { drawHand() }
  }
  
  /*-----Clock Time Buttons private properties-----*/
  //array of dispalyed buttons
  private var timeButtons: [NKQCTimeButton] = [NKQCTimeButton]()
  //tag of last selected button
  private var selectedTimeButtonTag: Int?
  //area for placing buttons
  private var timeButtonsFrame: CGRect {
    return  bounds.changedSize(with: -timeButtonNormalConfig.sideLength - timeButtonsMargin)
  }
  
  /*-----Clock Notches private properties-----*/
  //area for drawing notches
  private var notchFrame: CGRect {
    return bounds.square.changedSize(with: -notchMargin * 2)
  }
  
  //notch layer key
  private static let kNKQCNotchLayer = "kNKQCNotchLayer"
  
  //layer for drawing notches
  //notchLayer located below handLayer
  private var notchLayer: CALayer {
    guard let nLayer = self.layer.sublayer(with: NKQuartzClockTimePicker.kNKQCNotchLayer) else {
      let layer = NKQCLayer.layer(with: notchFrame)
      layer.key = NKQuartzClockTimePicker.kNKQCNotchLayer
      self.layer.insertSublayer(layer, below: handLayer)
      return layer
    }
    nLayer.frame = notchFrame
    return nLayer
  }
  
  /*-----Clock Hand private properties-----*/
  //area for drawing clock hand
  private var handFrame: CGRect {
    return bounds.square.changedSize(with: -handMargin * 2)
  }
  
  //hand layer key
  private static let kNKQCHandLayer = "kNKQCHandLayer"
  
  //layer for drawing clock hand
  //handLayer located above notchLayer
  private var handLayer: NKQCLayer {
    guard let hLayer = self.layer.sublayer(with: NKQuartzClockTimePicker.kNKQCHandLayer) else {
      let layer = NKQCLayer.layer(with: handFrame)
      layer.key = NKQuartzClockTimePicker.kNKQCHandLayer
      self.layer.addSublayer(layer)
      return layer
    }
    hLayer.frame = handFrame
    return hLayer
  }
  
  //haptic feedback
  private var feedbackGenerator : UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
  
  
  override public func draw(_ rect: CGRect) {
    super.draw(rect)
    drawNotch()
    drawHand()
    putTimeButtons()
    setGestures()
  }
  
  /**
   Method for set self.time with animation
   */
  public func setTime(_ value: Int) {
    rotate(to: abs(value % timeComponent.count))
  }

}

//MARK: User Interaction, Hand Animation
fileprivate extension NKQuartzClockTimePicker {

  @objc func onBtnTap(_ sender: NKQCTimeButton)  {
    rotate(to: sender.tag)
  }
  
  @objc func onPanChanged(_ sender: UIPanGestureRecognizer)  {
    let position = sender.location(in: self)
    
    switch sender.state {
    case .began, .changed: rotate(basedOn: position)
    case .ended, .cancelled, .failed : rotate(to: time)
    default: return
    }
  }
  
  @objc func onTap(_ sender: UITapGestureRecognizer) {
    let position = sender.location(in: self)
    let absoluteAngle = bounds.center.angle(with: bounds.topControlPoint, position)
    let angle = position.x < bounds.center.x ? .pi * 2 - absoluteAngle : absoluteAngle
    let val = round(angle / timeComponent.singleAngle())
    rotate(to: Int(val))
  }
  
  func rotate(basedOn point: CGPoint) {
    let absoluteAngle = bounds.center.angle(with: bounds.topControlPoint, point)
    let angle = point.x < bounds.center.x ? .pi * 2 - absoluteAngle : absoluteAngle
    handLayer.rotate(to: angle, speed: 3)
    let val = round(angle / timeComponent.singleAngle())
    selectTimeButton(for: Int(val))
  }
  
  func rotate(to value: Int) {
    let angle = timeComponent.singleAngle() * CGFloat(value)
    handLayer.rotate(to: angle, speed: 1)
    selectTimeButton(for: value)
  }
  
  func selectTimeButton(for tag: Int) {
    guard tag != time else { return }
    
    delegate?.clockPicker(self, didChange: tag)
    time = tag
    
    if let selectedTimeButtonTag = self.selectedTimeButtonTag, let btn = timeButtons.first(where: { tBtn -> Bool in return tBtn.tag == selectedTimeButtonTag}) {
      btn.selection = false
    }
    
    if let btn = timeButtons.first(where: { tBtn -> Bool in return tBtn.tag == tag})  {
      feedbackGenerator.selectionChanged()
      btn.selection = true
      selectedTimeButtonTag = tag
    } else {
      selectedTimeButtonTag = nil
    }
  }
  
}

//MARK: UI setup
fileprivate extension NKQuartzClockTimePicker {
  
  func drawNotch() {
    notchLayer.sublayers?.forEach({ $0.removeFromSuperlayer() })
    notches?.forEach({ notchLayer.addSublayer(CAShapeLayer.layer(with: $0, in: notchLayer.bounds)) })
    
#if TARGET_INTERFACE_BUILDER
//    layer.addSublayer(CAShapeLayer.layer(with: NKQCNotchConfiguration(style: .line, width: 1, color: .black, count: nil), in: bounds.changedSize(with: -notchMargin)))
#endif
  }
  
  func drawHand() {
    handLayer.sublayers?.forEach({ $0.removeFromSuperlayer() })
    handLayer.addSublayer(CAShapeLayer.layer(with: hand, in: handLayer.bounds))
    
#if TARGET_INTERFACE_BUILDER
    layer.addSublayer(CAShapeLayer.layer(with: hand, in: bounds.changedSize(with: -handMargin)))
#endif
  }
  
  func putTimeButtons() {
    timeButtons.forEach({ $0.removeFromSuperview() })
    timeButtons = [NKQCTimeButton]()
    let delegate = self.delegate
    
    (1...timeComponent.count).forEach {
      let shouldPut = delegate == nil ? true : dataSource?.clockPicker(self, shouldAddTitleFor: $0)
      if shouldPut == true {
        let btn = timeButton(for: $0)
        timeButtons.append(btn)
        addSubview(btn)
      }
    }
    
  }
  
  func timeButton(for index: Int) -> NKQCTimeButton {
    let frame = timeButtonsFrame
    
    let btn = NKQCTimeButton()
    btn.tag = index != timeComponent.count ? index : timeComponent.lastValue()
    btn.normalStateConfig = timeButtonNormalConfig
    btn.selectedStateConfig = timeButtonSelectedConfig
    btn.center = frame.incircleDevidePoint(for: UInt(btn.tag), in: UInt(timeComponent.count))
    btn.selection = index == time
    let title = dataSource?.clockPicker(self, titleFor: index) ?? timeComponent.stringValue(for: index)
    btn.setTitle(title, for: .normal)
    
    btn.addTarget(self, action: #selector(onBtnTap(_:)), for: .touchUpInside)
    
    return btn
  }
  
  func setGestures() { 
    guard gestureRecognizers != nil else {
      let pan = UIPanGestureRecognizer(target: self, action: #selector(onPanChanged(_:)))
      addGestureRecognizer(pan)
      
      let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
      addGestureRecognizer(tap)
      return
    }
    
  }
  
}

//MARK:- Additionals
fileprivate class NKQCLayer: CALayer {
  var key: String?
  
  func rotate(to eAngle: CGFloat, speed: Float) {
    self.speed = speed
    var rotation = CATransform3DMakeRotation(eAngle, 0, 0, 0.5)
    rotation.m34 = 1.0 / -500

    transform  = rotation
  }

}

fileprivate extension CALayer {
  
  static func layer(with frame: CGRect) -> NKQCLayer {
    let layer = NKQCLayer()
    layer.frame = frame
    layer.backgroundColor = UIColor.clear.cgColor
    return layer
  }
  
  func sublayer(with key: String) -> NKQCLayer? {
    return sublayers?.first(where: { sublayer -> Bool in
      guard let nkLayer = sublayer as? NKQCLayer else { return false }
      return nkLayer.key == key
    }) as? NKQCLayer
  }
  
  
}
