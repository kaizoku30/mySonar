//
//  clockView.swift
//  Kudu
//
//  Created by Admin on 30/09/22.
//

import UIKit
import NKQuartzClockTimePicker

enum PickerCondition {
    case hour
    case minute
}
class ClockView: UIView {
    
    @IBOutlet private weak var clockView: NKQuartzClockTimePicker!
    @IBOutlet private weak var amPmButton: UIButton!
    @IBOutlet private weak var ambutton: UIButton!
    @IBOutlet private weak var pmButton: UIButton!
    @IBOutlet private weak var centerDot: UIView!
    @IBOutlet private weak var amPmView: UIView!
    @IBOutlet weak var hourButton: UIButton!
    @IBOutlet weak var minuteButton: UIButton!
    var clockCondition: PickerCondition = .hour
    var currentTimeHour = Int()
    var currentTimeMinute = Int()
    var buttonTitles = [String]()
    enum ViewActions {
        case cancelButtonPressed
        case okButtonPressed(time: String)
    }
    var handleViewActions: ((ViewActions) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    override func draw(_ rect: CGRect) {
        setUpClockCornerRadius()
    }
    func initialSetup() {
        changePickerFormat(pickerCondition: .hour)
        setUpCustomization()
        setTime()
    }
}
// MARK: - Configuration of clock view
extension ClockView {
    var buttonConfig: NKQCTimeButtonConfiguration {
        var textConfig = NKQCTextConfiguration()
        textConfig.size = 12
        textConfig.color = .black
        var buttonConfig = NKQCTimeButtonConfiguration()
        buttonConfig.textConfig = textConfig
        buttonConfig.sideLength = 30
        buttonConfig.backgroundColor = .clear
        buttonConfig.cornerRadius = 15
        buttonConfig.borderWidth = 0
        buttonConfig.borderColor = UIColor.clear.cgColor
        return buttonConfig
    }
    var SelectedbuttonConfig: NKQCTimeButtonConfiguration {
        var textConfig = NKQCTextConfiguration()
        textConfig.size = 12
        textConfig.color = .white
        var buttonConfig = NKQCTimeButtonConfiguration()
        buttonConfig.textConfig = textConfig
        buttonConfig.sideLength = 30
        buttonConfig.backgroundColor = UIColor(named: "customBlue") ?? .blue
        buttonConfig.cornerRadius = 15
        buttonConfig.borderWidth = 0
        buttonConfig.borderColor = UIColor.clear.cgColor
        return buttonConfig
    }
    var hand: NKQCHandConfiguration {
        var hand = NKQCHandConfiguration()
        hand.color = UIColor(named: "customBlue") ?? .blue; hand.width = 2
        return hand
    }
    func hourClockSetup() {
        setButtonColors(btnColor1: UIColor(named: "customYellow"), btnColor2: .black, btn1: hourButton, btn2: minuteButton)
        buttonTitles.removeAll()
        for num in 1...12 {
            buttonTitles.append("\(num)")
        }
        clockView.timeComponent = .hour12
        clockView.timeButtonsMargin = 8
        clockView.timeButtonNormalConfig = buttonConfig
        clockView.timeButtonSelectedConfig = SelectedbuttonConfig
//             clockView.backgroundColor = .white
        clockView.hand = hand
        clockView.handMargin = 30
        clockView.setTime(currentTimeHour)
    }
    func minuteClockSetup() {
        setButtonColors(btnColor1: UIColor(named: "customYellow"), btnColor2: .black, btn1: minuteButton, btn2: hourButton)
        buttonTitles.removeAll()
        for num in 1...60 {
            switch num {
            case 60 :
                buttonTitles.append("0")
            case 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55:
                buttonTitles.append("\(num)")
            default :
                buttonTitles.append("")
            }
        }
        clockView.timeComponent = .minute
        clockView.timeButtonsMargin = 8
        clockView.timeButtonNormalConfig = buttonConfig
        clockView.timeButtonSelectedConfig = SelectedbuttonConfig
        clockView.backgroundColor = .white
        clockView.hand = hand
        clockView.handMargin = 30
        //currentTimeMinute -= currentTimeMinute%5
        clockView.setTime(currentTimeMinute)
    }
    func changePickerFormat(pickerCondition: PickerCondition) {
        clockCondition = pickerCondition
        switch pickerCondition {
        case .hour:
            hourClockSetup()
        case .minute:
            minuteClockSetup()
        }
    }
    func setTime(date: Date = Date()) {
        let date = date
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a"
        let amPmString = dateFormatter.string(from: date)
        if amPmString == "AM" {
            setButtonColors(btnColor1: UIColor(named: "customBlue"), btnColor2: UIColor(named: "lightGrey"), btn1: ambutton, btn2: pmButton)
        } else {
            setButtonColors(btnColor1: UIColor(named: "customBlue"), btnColor2: UIColor(named: "lightGrey"), btn1: pmButton, btn2: ambutton)
        }
        currentTimeHour = calendar.component(.hour, from: date)
        currentTimeMinute = calendar.component(.minute, from: date)
        hourButton.setTitle("\(currentTimeHour)", for: .normal)
        currentTimeMinute < 10 ? minuteButton.setTitle("0\(currentTimeMinute)", for: .normal) : minuteButton.setTitle("\(currentTimeMinute)", for: .normal)
        amPmButton.setTitle(amPmString, for: .normal)
        clockView.setTime(currentTimeHour)
    }
}
// MARK: - Customization of views
private extension ClockView {
    func setUpCustomization() {
        centerDot.layer.cornerRadius = 4
        amPmView.layer.borderWidth = 2
        amPmView.layer.borderColor = UIColor(named: "customYellow")?.cgColor
        amPmView.layer.cornerRadius = 12
    }
    func setUpClockCornerRadius() {
        clockView.layer.cornerRadius = clockView.bounds.height / 2
        clockView.clipsToBounds = true
    }
    func setButtonColors(btnColor1: UIColor?, btnColor2: UIColor?, btn1 : UIButton, btn2 : UIButton) {
        btn1.setTitleColor(btnColor1 ?? .black, for: .normal)
        btn2.setTitleColor(btnColor2 ?? .black, for: .normal)
    }
}

// MARK: - IBActions of buttons
private extension ClockView {
    @IBAction private func hourButtonPressed(_ sender: UIButton) {
        changePickerFormat(pickerCondition: .hour)
    }
    @IBAction private func minuteButtonPressed(_ sender: UIButton) {
        changePickerFormat(pickerCondition: .minute)
    }
    @IBAction private func amButtonPressed(_ sender: UIButton) {
        setButtonColors(btnColor1: UIColor(named: "customBlue"), btnColor2: UIColor(named: "lightGrey"), btn1: ambutton, btn2: pmButton)
        amPmButton.setTitle("AM", for: .normal)
    }
    @IBAction private func pmButtonPressed(_ sender: UIButton) {
        setButtonColors(btnColor1: UIColor(named: "customBlue"), btnColor2: UIColor(named: "lightGrey"), btn1: pmButton, btn2: ambutton)
        amPmButton.setTitle("PM", for: .normal)
    }
    @IBAction private func cancelButtonPressed(_ sender: UIButton) {
        handleViewActions?(.cancelButtonPressed)
    }
    @IBAction private func okButtonPressed(_ sender: UIButton) {
        guard let hour = hourButton.currentTitle, let minute = minuteButton.currentTitle, let amPm = amPmButton.currentTitle else {
            return
        }
        debugPrint("\(hour) : \(minute) \(amPm)")
        handleViewActions?(.okButtonPressed(time: "\(hour):\(minute) \(amPm)"))
    }
}
