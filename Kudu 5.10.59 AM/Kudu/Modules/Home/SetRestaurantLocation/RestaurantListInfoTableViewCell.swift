//
//  RestaurantListInfoTableViewCell.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import UIKit

class RestaurantListInfoTableViewCell: UITableViewCell {
    //@IBOutlet private weak var mapButtonStackView: UIStackView!
    //@IBOutlet private weak var mapButtonTitle: UILabel!
    @IBOutlet private weak var storeNearYouLabel: UILabel!
   // @IBOutlet private weak var shadowView: UIView!
    
    var mapPressed: (() -> Void)?
    @IBOutlet weak var mapButton: AppButton!
    
    @IBAction func mapButtonPressed(_ sender: Any) {
        self.mapPressed?()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        mapButton.setAttributedTitle(NSAttributedString(string: LocalizedStrings.SetRestaurant.map, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]), for: .normal)
        mapButton.layer.applySketchShadow(color: .black, alpha: 0.14, x: 0, y: 2, blur: 10, spread: 0)
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(numberOfStores: Int?) {
        storeNearYouLabel.isHidden = numberOfStores.isNil
        storeNearYouLabel.text = LocalizedStrings.SetRestaurant.xStoreNearYou.replace(string: CommonStrings.numberPlaceholder, withString: "\(numberOfStores ?? 0)")
    }

}
