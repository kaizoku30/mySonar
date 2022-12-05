//
//  RTWeekdayCell.swift
//  Kudu
//
//  Created by Admin on 03/10/22.
//

import UIKit

class RTWeekdayCell: UICollectionViewCell {
    @IBOutlet weak var weekdayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.semanticContentAttribute = .forceLeftToRight
        // Initialization code
    }

}
