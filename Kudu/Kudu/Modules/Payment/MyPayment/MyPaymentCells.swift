//
//  MyPaymentCells.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit

class MyPaymentShimmerCell: UITableViewCell {
    @IBOutlet private weak var shimmerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerView.startShimmering()
    }
}

class MyPaymentCardCell: UITableViewCell {
    @IBOutlet private weak var holderNameLbl: UILabel!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var cardImg: UIImageView!
    @IBOutlet private weak var deleteButton: AppButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        cardImg.image = nil
        deleteButton.addTarget(self, action: #selector(deletePressed), for: .touchUpInside)
    }
    
    var deleteCardAtIndex: ((Int) -> Void)?
    
    @objc private func deletePressed() {
        deleteCardAtIndex?(index)
    }
    
    private var index: Int = 0
    
    func configure(holderName: String, last4: String, cardImage: UIImage, index: Int) {
        self.index = index
        cardImg.contentMode = .scaleToFill
        holderNameLbl.text = holderName
        cardNumberLabel.text = "XXXXXXXXXXXX\(last4)"
        if index == 0 {
            cardNumberLabel.text?.append(" (Default)")
        }
        cardImg.image = cardImage
    }
}
