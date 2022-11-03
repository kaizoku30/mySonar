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
    private let subtitleColor = UIColor(r: 149, g: 157, b: 177, alpha: 1)
    private let subtitleFont = AppFonts.mulishMedium.withSize(12)
    var cellTapped: ((Int) -> Void)?
    private var index = 0
    private var restrictLoader = false
    
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
    
    func configure(title: String, subtitle: String, index: Int, addressType: APIEndPoints.AddressLabelType? = nil) {
        restrictLoader = false
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
    
    func setClosedMarker() {
        restrictLoader = true
        let subtitleExisting = NSMutableAttributedString(string: subtitleLabel.text ?? "")
        let closedString = NSMutableAttributedString(string: " (Closed)", attributes: [.foregroundColor: UIColor.red])
        subtitleExisting.append(closedString)
        subtitleLabel.attributedText = subtitleExisting
    }
    
    private func startLoader() {
        if restrictLoader { return }
        loaderView.isHidden = false
        loader.startAnimating()
    }
    
}
