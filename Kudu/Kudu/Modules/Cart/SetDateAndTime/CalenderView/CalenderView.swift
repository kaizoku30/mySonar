//
//  CalenderBaseView.swift
//  CalenderUsingPOD
//
//  Created by Admin on 01/09/22.
//

import UIKit
import FSCalendar
import DropDown

class CalenderView: UIView {
    @IBOutlet private weak var monthBtn: UIButton!
    @IBOutlet private weak var yearBtn: UIButton!
    @IBOutlet private weak var calenderView: FSCalendar!
    let yearDropDown = DropDown()
    let monthDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.yearDropDown,
            self.monthDropDown
        ]
    }()
    enum ViewActions {
        case monthButtonPressed
        case yearButtonPressed
        case nextMonthButtonPressed
        case prevMonthButtonPressed
    }
    var handleViewActions: ((ViewActions) -> Void)?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    @IBAction private func prevMonthBtnPressed(_ sender: UIButton) {
        handleViewActions?(.prevMonthButtonPressed)
    }
    
    @IBAction private func nextMonthBtnPressed(_ sender: UIButton) {
        handleViewActions?(.nextMonthButtonPressed)
    }
    @IBAction private func monthBtnPressed(_ sender: UIButton) {
        let yearIndex = yearDropDown.dataSource.firstIndex(of: yearBtn.currentTitle ?? "") ?? 0
        yearDropDown.selectRow(at: yearIndex, scrollPosition: .top)
        handleViewActions?(.monthButtonPressed)
    }
    @IBAction private func yearBtnPressed(_ sender: UIButton) {
        let monthIndex = monthDropDown.dataSource.firstIndex(of: monthBtn.currentTitle ?? "") ?? 0
        monthDropDown.selectRow(at: monthIndex, scrollPosition: .top)
        handleViewActions?(.yearButtonPressed)
    }
}
// MARK: - custom Methods
extension CalenderView {
    func setUpCalenderView() {
        calenderView.calendarHeaderView.isHidden = true
        calenderView.calendarWeekdayView.isHidden = true
        calenderView.scrollEnabled = false
        calenderView.pagingEnabled = false
        calenderView.headerHeight = 0
        calenderView.weekdayHeight = 0
        calenderView.appearance.titleDefaultColor = .black
        calenderView.appearance.titleTodayColor = .black
        calenderView.appearance.todayColor = .red
        calenderView.appearance.selectionColor = UIColor(named: "dropDownSelected")
        calenderView.appearance.weekdayTextColor = UIColor(named: "weekDayColor")
        calenderView.appearance.borderRadius
        calenderView.select(Date())
    }
    func setUpYearAndMonthBtn(date: Date) {
        let month = date.monthString
        let year = "\(date.year)"
        monthBtn.setTitle(month, for: .normal)
        yearBtn.setTitle(year, for: .normal)
    }
    func moveMonths(byMonths: Int) {
        let date = calenderView.currentPage
        let modifiedDate = Calendar.current.date(byAdding: .month, value: byMonths, to: date)!
        setUpYearAndMonthBtn(date: modifiedDate)
        calenderView.setCurrentPage(modifiedDate, animated: true)
    }
    func setUpDropDowns() {
        dropDowns.forEach { dropDown in
            dropDown.cellHeight = 32
            dropDown.selectedTextColor = .white
            dropDown.selectionBackgroundColor = UIColor(named: "dropDownSelected") ?? .blue
        }
        setupYearDropDown()
        setupMonthDropDown()
    }
    func setupYearDropDown() {
        yearDropDown.width = 60
        yearDropDown.anchorView = yearBtn
        yearDropDown.backgroundColor = .white
        yearDropDown.bottomOffset = CGPoint(x: 5, y: yearBtn.bounds.height)
        
        for year in calenderView.minimumDate.year...calenderView.maximumDate.year {
            yearDropDown.dataSource.append("\(year)")
        }
        
        let yearIndex = yearDropDown.dataSource.firstIndex(of: "\(Date().year)")
        yearDropDown.selectRow(at: yearIndex, scrollPosition: .top)
        
        yearDropDown.selectionAction = { [weak self] (index, item) in
            self?.yearBtn.setTitle(item, for: .normal)
            debugPrint(item)
            guard let monthString = self?.monthBtn.currentTitle else { return }
            guard let monthIndex = self?.monthDropDown.dataSource.firstIndex(of: monthString) else { return }
            let modifiedDate = Date.date(day: 2, month: monthIndex + 1, year: Int(item) ?? Date().year)
            self?.setUpYearAndMonthBtn(date: modifiedDate)
            self?.calenderView.setCurrentPage(modifiedDate, animated: true)
        }
    }
    func setupMonthDropDown() {
        monthDropDown.width = 100
        monthDropDown.anchorView = monthBtn
        monthDropDown.backgroundColor = .white
        monthDropDown.bottomOffset = CGPoint(x: 0, y: monthBtn.bounds.height )
        
        let monthsName = DateFormatter().monthSymbols
        monthDropDown.dataSource = monthsName ?? []
        
        monthDropDown.selectRow(at: Date().month - 1, scrollPosition: .top)
        
        monthDropDown.selectionAction = { [weak self] (index, item) in
            self?.monthBtn.setTitle(item, for: .normal)
            guard let yearString = self?.yearBtn.currentTitle else { return }
            let modifiedDate = Date.date(day: 2, month: index + 1, year: Int(yearString) ?? Date().year)
            self?.setUpYearAndMonthBtn(date: modifiedDate)
            self?.calenderView.setCurrentPage(modifiedDate, animated: true)
        }
    }
    func updateMonth(date: Date) {
        calenderView.select(date, scrollToDate: true)
    }
}
