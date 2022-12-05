//
//  RTCalendarView.swift
//  Kudu
//
//  Created by Admin on 03/10/22.
//

import UIKit

struct RTCellConfig {
    var backgroundColor: UIColor = .clear
    var selected: Bool = false
    var date: Date
    var textColor: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
}

class RTCalendarView: AppPopUpViewType {
    @IBOutlet private weak var mainContentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var weekdayCollection: UICollectionView!
    
    @IBAction private func crossButtonPressed(_ sender: Any) {
        self.dismissed?()
    }
    
    var dateSelected: ((Date) -> Void)?
    var dismissed: (() -> Void)?
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RTCalendarView", owner: self, options: nil)
        addSubview(mainContentView)
        self.semanticContentAttribute = .forceLeftToRight
        mainContentView.semanticContentAttribute = .forceLeftToRight
        collectionView.semanticContentAttribute = .forceLeftToRight
        weekdayCollection.semanticContentAttribute = .forceLeftToRight
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.registerCell(with: RTCalendarCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        weekdayCollection.delegate = self
        weekdayCollection.dataSource = self
        weekdayCollection.registerCell(with: RTWeekdayCell.self)
        let monthWeek = Date().toString(dateFormat: Date.DateFormat.MMMYYYY.rawValue)
        monthYearLabel.text = monthWeek
        self.layer.applySketchShadow(color: .black.withAlphaComponent(0.25), alpha: 1, x: 0, y: 0, blur: 4, spread: 0)
        self.layer.cornerRadius = 7.72
        
    }
    
    private var weekdays: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private var configs: [RTCellConfig] = []
    private var allowedIndex: [Int] = []
    private var selectedIndex: Int?
    
    func configure(selectedDate: Date?) {
        let currentDate = Date()
        let firstDay = RTCalendarViewModel.firstDayOfMonth(month: currentDate.month, year: currentDate.year)
        let firstDayWeekday = firstDay.weekday
        if firstDayWeekday == 1 {
            configs = [RTCellConfig(date: firstDay)]
        } else {
            var weekdayToStart = firstDayWeekday
            configs = [RTCellConfig(date: firstDay)]
            while weekdayToStart != 1 {
                weekdayToStart -= 1
                configs.append(RTCellConfig(date: configs.last!.date.addingTimeInterval(-60*60*24)))
            }
        }
        let lastDate = configs.last!.date
        configs = [RTCellConfig(date: lastDate)]
        
        for _ in 1..<42 {
            let lastDate = configs.last!.date
            let object = RTCellConfig(date: lastDate.addingTimeInterval(60*60*24))
            configs.append(object)
        }
        let indexOfCurrentDate = configs.firstIndex(where: { ($0.date.day  == currentDate.day) && ($0.date.month == currentDate.month) })
        configs[indexOfCurrentDate!].backgroundColor = AppColors.kuduThemeYellow.withAlphaComponent(0.1)
        configs[indexOfCurrentDate!].textColor = .black
        configs[indexOfCurrentDate! + 1].backgroundColor = AppColors.kuduThemeYellow.withAlphaComponent(0.1)
        configs[indexOfCurrentDate! + 1].textColor = .black
        configs[indexOfCurrentDate! + 2].backgroundColor = AppColors.kuduThemeYellow.withAlphaComponent(0.1)
        configs[indexOfCurrentDate! + 2].textColor = .black
        if let selectedDate = selectedDate {
            if configs[indexOfCurrentDate!].date.day == selectedDate.day {
                configs[indexOfCurrentDate!].selected = true
                selectedIndex = indexOfCurrentDate!
            } else if configs[indexOfCurrentDate! + 1].date.day == selectedDate.day {
                configs[indexOfCurrentDate! + 1].selected = true
                selectedIndex = indexOfCurrentDate! + 1
            } else if configs[indexOfCurrentDate! + 2].date.day == selectedDate.day {
                configs[indexOfCurrentDate! + 2].selected = true
                selectedIndex = indexOfCurrentDate! + 2
            }
        }
        allowedIndex = [indexOfCurrentDate!, indexOfCurrentDate! + 1, indexOfCurrentDate! + 2]
        collectionView.reloadData()
    }
}

extension RTCalendarView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == weekdayCollection {
            return 7
        }
        
        return configs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == weekdayCollection {
            return
        }
        
        let item = indexPath.item
        if allowedIndex.contains(where: { $0 == item }) {
            let previousIndex = selectedIndex ?? 0
            let newIndex = item
            configs[previousIndex].selected = false
            configs[newIndex].selected = true
            selectedIndex = newIndex
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: [IndexPath(item: previousIndex, section: 0), IndexPath(item: newIndex, section: 0)])
            }
            self.dateSelected?(configs[newIndex].date)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.width
        let cellWidth = totalWidth/7
        
        if collectionView == weekdayCollection {
            return CGSize(width: cellWidth, height: collectionView.height)
        }
        
        let totalHeight = collectionView.height
        let cellHeight = totalHeight/6
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == weekdayCollection {
            let cell = collectionView.dequeueCell(with: RTWeekdayCell.self, indexPath: indexPath)
            cell.weekdayLabel.text = weekdays[indexPath.item]
            return cell
        }
        
        let cell = collectionView.dequeueCell(with: RTCalendarCell.self, indexPath: indexPath)
        cell.configure(configs[indexPath.item])
        return cell
    }
}
