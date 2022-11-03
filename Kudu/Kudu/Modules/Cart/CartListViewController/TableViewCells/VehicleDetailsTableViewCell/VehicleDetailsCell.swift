//
//  VehicleDetailsCell.swift
//  Kudu
//
//  Created by Admin on 21/09/22.
//

import UIKit

class VehicleDetailsCell: UITableViewCell {
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addedVehicleStack: UIView!
    @IBOutlet weak var addUpdateBtn: AppButton!
    @IBOutlet weak var addedVehicleName: UILabel!
    @IBOutlet weak var addedVehicleDetails: UILabel!
    @IBOutlet weak var addPlaceholder: UILabel!
    @IBAction func cellActionButtonPressed(_ sender: Any) {
        updateVehicleDetails?()
    }
    
    var updateVehicleDetails: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ vehicle: VehicleDetails?) {
        if let vehicle = vehicle, vehicle._id ?? "" != "" {
            addedVehicleName.text = vehicle.vehicleName ?? ""
            let carNumber = vehicle.vehicleNumber ?? ""
            var color = vehicle.colorName ?? ""
            let colorCode = vehicle.colorCode ?? "#"
            //colorCode.removeFirst()
            if color.isEmpty {
                color = colorCode.uiColorFor6CharHex.accessibilityName
            }
            
            addedVehicleDetails.text = carNumber + "(\(color))"
            addPlaceholder.isHidden = true
            addedVehicleStack.isHidden = false
            carImageView.isHidden = false
            addUpdateBtn.setTitle("Update", for: .normal)
        } else {
            carImageView.isHidden = true
            addedVehicleStack.isHidden = true
            addPlaceholder.isHidden = false
            addUpdateBtn.setTitle("Add", for: .normal)
        }
    }

}
