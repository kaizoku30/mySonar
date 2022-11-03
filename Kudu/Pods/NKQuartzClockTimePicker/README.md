# NKQuartzClockTimePicker

![Swift](https://img.shields.io/badge/Swift-4.0-orange.svg) [![CI Status](https://img.shields.io/travis/nkopilovskii/NKQuartzClockTimePicker.svg?style=flat)](https://travis-ci.org/nkopilovskii/NKQuartzClockTimePicker) [![Version](https://img.shields.io/cocoapods/v/NKQuartzClockTimePicker.svg?style=flat)](https://cocoapods.org/pods/NKQuartzClockTimePicker) [![License](https://img.shields.io/cocoapods/l/NKQuartzClockTimePicker.svg?style=flat)](https://cocoapods.org/pods/NKQuartzClockTimePicker) [![Platform](https://img.shields.io/cocoapods/p/NKQuartzClockTimePicker.svg?style=flat)](https://cocoapods.org/pods/NKQuartzClockTimePicker)

## Description

Custom time component picker in the form of a round mechanical clock with the possibility of full adjustment of  display of the clockface.

## Interface

### Configurations

**NKQCTimeComponent** - public enum; required to indicate type of selectable time component
```swift
enum NKQCTimeComponent {
  case second
  case minute
  case hour12
  case hour24
}
```

**NKQCTimeButtonConfiguration** - struct for setting the display of time button of clockface.
```swift
struct NKQCTimeButtonConfiguration {
  var textConfig: NKQCTextConfiguration
  var sideLength: CGFloat
  var backgroundColor: UIColor
  var cornerRadius: CGFloat
  var borderWidth: CGFloat
  var borderColor: CGColor

  var size: CGSize {
    return CGSize(width: sideLength, height: sideLength)
  }
}
```

**NKQCTextConfiguration** - struct for setting text display format.
```swift
struct NKQCTextConfiguration {
  var fontName: String
  var size: CGFloat
  var color: UIColor

  func font() -> UIFont {
    return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
  }
}
```

**NKQCHandConfiguration** - struct for setting clock hand display format.
```swift
struct NKQCHandConfiguration {
  var color: UIColor
  var width: CGFloat
}
```

**NKQCNotchConfiguration** -  struct for setting clockface notches display format.
```swift
struct NKQCNotchConfiguration {
  var style: Style
  var width: CGFloat
  var color: UIColor
  var count: UInt?
  
  //style of the notch
  public enum Style {
    case line
    case dashes(CGFloat)
    case dots
    }
}
```
In the case `dashes(CGFloat)`  incoming defining the length of each dash.

### Protocols
**NKQuartzClockTimePickerDataSource** - protocol declares the methods necessary to display the button and its title in accordance with the indicated time.
```swift
@objc protocol NKQuartzClockTimePickerDataSource: class {
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
```

**NKQuartzClockTimePickerDelegate** - protocol declares the methods to be called when the state of the picker changes.
```swift
@objc protocol NKQuartzClockTimePickerDelegate: class {
  /**Method is called when time picker value is changed*/
  func clockPicker(_ picker: NKQuartzClockTimePicker, didChange time: Int)
}
```

### Class
**NKQuartzClockTimePicker** 
```swift
class NKQuartzClockTimePicker: UIView {

  /**Object that implements protocol NKQuartzClockTimePickerDataSource*/
  @IBOutlet weak var dataSource: NKQuartzClockTimePickerDataSource?
  
  /**Object that implements protocol NKQuartzClockTimePickerDelegate*/
  @IBOutlet weak var delegate: NKQuartzClockTimePickerDelegate?


  /**
    Type of selectable time component.

    Default value = NKQCTimeComponent.second
  */
  var timeComponent: NKQCTimeComponent = .second {
    didSet { putTimeButtons() }
  }

  /**
    Current time component value.

    Values for seconds and minutes in range 0...59

    Values for 12 hours format in range 1...12

    Values for 24 hours format in range 0...23
  */
  private (set) var time: Int = 0

  /**
    Indent buttons from the nearest NKQuartzClockTimePicker view side
  */
  @IBInspectable var timeButtonsMargin: CGFloat = 0.0 {
    didSet { putTimeButtons() }
  }

  /**
    Settings clockface time button display format for normal (unselected) state.

    Default value = NKQCTimeButtonConfiguration()
  */
  var timeButtonNormalConfig: NKQCTimeButtonConfiguration = NKQCTimeButtonConfiguration() {
    didSet { putTimeButtons() }
  }

  /**
    Settings clockface time button display format for selected state.

    Default value = NKQCTimeButtonConfiguration()
  */
  var timeButtonSelectedConfig: NKQCTimeButtonConfiguration = NKQCTimeButtonConfiguration() {
    didSet { putTimeButtons() }
  }

  /**
    Indent notches from the nearest NKQuartzClockTimePicker view side.
  */
  @IBInspectable var notchMargin: CGFloat = 0.0 {
    didSet { drawNotch() }
  }

  /**
    Array of NKQCNotchConfiguration for combining notches on clockface.

    Notche's layers are superimposed in the order of adding to the array
  */
  var notches: [NKQCNotchConfiguration]? {
    didSet { drawNotch() }
  }

  /**
    Indent of clock hand end from the nearest NKQuartzClockTimePicker view side
  */
  @IBInspectable var handMargin: CGFloat = 0.0 {
    didSet { drawHand() }
  }

  /**
    Settings clock hand display format.
  */
  var hand: NKQCHandConfiguration = NKQCHandConfiguration() {
    didSet { drawHand() }
  }

  /**
    Method for set self.time with animation
  */
  func setTime(_ value: Int) {
    rotate(to: abs(value % timeComponent.count))
  }

}
```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Screenshots
![image](https://github.com/nkopilovskii/NKQuartzClockTimePicker/blob/master/Example/NKQuartzClockTimePicker/screenshot_24_hours.png?raw=true)   ![image](https://github.com/nkopilovskii/NKQuartzClockTimePicker/blob/master/Example/NKQuartzClockTimePicker/screenshot_12_hours.png?raw=true)   
![image](https://github.com/nkopilovskii/NKQuartzClockTimePicker/blob/master/Example/NKQuartzClockTimePicker/screenshot_minutes_seconds.png?raw=true)   ![image](https://github.com/nkopilovskii/NKQuartzClockTimePicker/blob/master/Example/NKQuartzClockTimePicker/screenshot_emoji.png?raw=true)

## Requirements
iOS 10.0
Xcode 9
Swift 4.0

## Installation

NKQuartzClockTimePicker is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NKQuartzClockTimePicker'
```

## Author

Nick Kopilovskii, nkopilovskii@gmail.com

## License

NKQuartzClockTimePicker is available under the MIT license. See the LICENSE file for more info.
