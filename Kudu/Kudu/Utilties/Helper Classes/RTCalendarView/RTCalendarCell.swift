//
//  RTCalendarCell.swift
//  Kudu
//
//  Created by Admin on 03/10/22.
//

import UIKit

class RTCalendarCell: UICollectionViewCell {

    @IBOutlet private weak var selectionView: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.semanticContentAttribute = .forceLeftToRight
        // Initialization code
    }
    
    private var selectedDate: Bool = false
    private var date: Date!
    
    func configure(_ configuration: RTCellConfig) {
        self.backgroundColor = configuration.backgroundColor
        self.selectedDate = configuration.selected
        self.date = configuration.date
        dateLabel.text = "\(self.date.day)"
        dateLabel.textColor = configuration.selected ? .white : configuration.textColor
        selectionView.isHidden = !configuration.selected
        selectionView.height = selectionView.width
        selectionView.layoutIfNeeded()
        selectionView.cornerRadius = selectionView.frame.height/2
        if configuration.date.month != Date().month {
            self.dateLabel.textColor = configuration.textColor.withAlphaComponent(0.25)
        }
    }
}
