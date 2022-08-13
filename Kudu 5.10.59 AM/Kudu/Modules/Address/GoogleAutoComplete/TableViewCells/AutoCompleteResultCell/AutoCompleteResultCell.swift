//
//  AutoCompleteResultCell.swift
//  Kudu
//
//  Created by Admin on 15/07/22.
//

import UIKit
import NVActivityIndicatorView

class AutoCompleteResultCell: UITableViewCell {

    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var loader: NVActivityIndicatorView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var markerImgView: UIImageView!
    
    var cellTapped: ((Int) -> Void)?
    private var index = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        loaderView.isHidden = true
        loader.stopAnimating()
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped)))
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func containerTapped() {
        mainThread { [weak self] in
            self?.startLoader()
            self?.cellTapped?(self?.index ?? 0)
        }
    }
    
    func configure(title: String, subtitle: String, index: Int, addressType: WebServices.AddressLabelType? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        self.index = index
        if let type = addressType {
            markerImgView.image = type == .HOME ? AppImages.SetDeliveryLocation.home : AppImages.SetDeliveryLocation.work
            if type == .OTHER {
                markerImgView.image = AppImages.SetDeliveryLocation.pinMarker
            }
        }
    }
    
    private func startLoader() {
        loaderView.isHidden = false
        loader.startAnimating()
    }
    
}
