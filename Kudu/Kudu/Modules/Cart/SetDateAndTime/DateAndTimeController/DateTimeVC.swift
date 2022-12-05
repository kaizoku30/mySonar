//
//  DateTimeVC.swift
//  Kudu
//
//  Created by Admin on 27/09/22.
//

import UIKit
import FSCalendar
import DropDown
import NKQuartzClockTimePicker

class DateTimeVC: BaseVC {
    
    @IBOutlet var baseView: DateTimeView!
    @IBOutlet weak var calenderBaseView: RTCalendarView!
    @IBOutlet weak var clockBaseView: ClockView!
    var dateTimeSelected: ((Int) -> Void)?
    var date: Date?
    var time: Double?
    var handleDeallocation: (() -> Void)?
    var prefill: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleActions()
        calenderSetup()
        handleClockViewActions()
        if prefill.isNil {
            let date = Date().timeIntervalSince1970 + (60*60)
            prefill = Int(date)
        }
        if prefill.isNotNil {
            let date = Date(timeIntervalSince1970: Double(prefill!))
            let dateString = date.toString(dateFormat: "dd/MM/yy")
            self.date = date
            self.baseView.setDateLabel(text: dateString)
            let components = date.totalMinutes.convertMinutesToAMPM(smallcase: false, safelyRemovingArabic: true).getHourMinComponents()
            let timeInterval = Double(components.hour * 60 * 60) + Double(components.min * 60)
            self.time = timeInterval
            self.date = self.date?.addingTimeInterval(-timeInterval)
            self.baseView.setTimeLabel(text: date.totalMinutes.convertMinutesToAMPM())
            self.baseView.enableSetDateTimeButton(enable: self.date.isNotNil && self.time.isNotNil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        baseView.semanticContentAttribute = .forceLeftToRight
        baseView.enableSetDateTimeButton(enable: date.isNotNil && time.isNotNil)
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.appearance().semanticContentAttribute = AppUserDefaults.selectedLanguage() == .en ? .forceLeftToRight : .forceRightToLeft
    }
    
    private func handleActions() {
        baseView.handleViewActions = {[weak self] (action) in
            guard let strongSelf = self else { return }
            switch action {
            case .closeBtnPressed:
                strongSelf.handleDeallocation?()
            case .calenderBtnPressed:
                if strongSelf.date.isNotNil {
                    strongSelf.calenderBaseView.configure(selectedDate: strongSelf.date)
                }
                strongSelf.calenderBaseView.isHidden = false
            case .timeClockBtnPressed:
                strongSelf.clockBaseView.isHidden = false
            case .setDeliveryDateTime:
                if strongSelf.date.isNotNil && strongSelf.time.isNotNil {
                    let finalDate = strongSelf.date!.addingTimeInterval(strongSelf.time!)
                    if finalDate < Date() {
                        let error = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: strongSelf.view.width - 32, height: 48))
                        error.show(message: "You cannot schedule order on the past date and time. Please update the date and time.", view: strongSelf.view)
                        return
                    }
                    strongSelf.dateTimeSelected?(Int(finalDate.unixTimestamp))
                }
            }
        }
    }
    
    private func calenderSetup() {
        calenderBaseView.configure(selectedDate: nil)
        calenderBaseView.dateSelected = { [weak self] in
            guard let strongSelf = self else { return }
            let date = $0
            let dateString = date.toString(dateFormat: "dd/MM/yy")
            strongSelf.date = $0
            self?.baseView.setDateLabel(text: dateString)
            strongSelf.baseView.enableSetDateTimeButton(enable: strongSelf.time.isNotNil)
            self?.calenderBaseView.isHidden = true
        }
        calenderBaseView.dismissed = { [weak self] in
            self?.calenderBaseView.isHidden = true
        }
    }
    
    private func handleClockViewActions() {
        clockBaseView.handleViewActions = { [weak self] (action) in
            guard let strongSelf = self else { return }
            switch action {
            case .okButtonPressed(let time) :
                debugPrint("Components : \(time.getHourMinComponents())")
                let components = time.getHourMinComponents()
                let timeInterval = Double(components.hour * 60 * 60) + Double(components.min * 60)
                strongSelf.time = timeInterval
                strongSelf.clockBaseView.isHidden = true
                strongSelf.baseView.setTimeLabel(text: time)
                strongSelf.baseView.enableSetDateTimeButton(enable: strongSelf.date.isNotNil)
            case .cancelButtonPressed :
                strongSelf.clockBaseView.isHidden = true
            }
        }
    }
    
}

extension DateTimeVC: NKQuartzClockTimePickerDataSource, NKQuartzClockTimePickerDelegate {
    func clockPicker(_ picker: NKQuartzClockTimePicker, shouldAddTitleFor time: Int) -> Bool {
        return true
    }
    func clockPicker(_ picker: NKQuartzClockTimePicker, titleFor time: Int) -> String? {
        return clockBaseView.buttonTitles[time - 1]
    }
    
    func clockPicker(_ picker: NKQuartzClockTimePicker, didChange time: Int) {
        switch clockBaseView.clockCondition {
        case .hour :
            clockBaseView.currentTimeHour = time
            clockBaseView.hourButton.setTitle("\(time)", for: .normal)
        case .minute :
            clockBaseView.currentTimeMinute = time
            time < 10 ? clockBaseView.minuteButton.setTitle("0\(time)", for: .normal) :  clockBaseView.minuteButton.setTitle("\(time)", for: .normal)
        }
    }
}
