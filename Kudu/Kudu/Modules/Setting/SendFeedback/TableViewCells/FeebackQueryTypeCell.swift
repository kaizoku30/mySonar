//
//  FeebackQueryTypeCell.swift
//  Kudu
//
//  Created by Admin on 07/09/22.
//

import UIKit

enum FeedbackQueryType: String {
	case feedback
	case enquiry
	case complaint
	
	var title: String {
		switch self {
		case .feedback:
			return "Feedback"
		case .enquiry:
			return "Enquiry"
		case .complaint:
			return "Complaint"
		}
	}
}

class FeebackQueryTypeCell: UITableViewCell {
	@IBOutlet private weak var buttonView: UIStackView!
	@IBOutlet private weak var queryLabel: UILabel!
	@IBOutlet private weak var optionsStackView: UIStackView!
	@IBOutlet private weak var feedbackTypeView: UIView!
	@IBOutlet private weak var feedbackImgView: UIImageView!
	@IBOutlet private weak var enquiryTypeView: UIView!
	@IBOutlet private weak var enquiryImgView: UIImageView!
	@IBOutlet private weak var complaintTypeView: UIView!
	@IBOutlet private weak var complaintImgView: UIImageView!
	
	@IBAction private func dropDownPressed(_ sender: Any) {
			setOptionsUI()
	}
	
	var queryTypeSelected: ((FeedbackQueryType?, Bool) -> Void)?
	private var query: FeedbackQueryType?
	private var openDropDown: Bool = false
	override func awakeFromNib() {
		super.awakeFromNib()
		selectionStyle = .none
		queryLabel.textAlignment = .center
		buttonView.isUserInteractionEnabled = true
		buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(queryTypePressed)))
		optionsStackView.isHidden = true
		[feedbackTypeView, enquiryTypeView, complaintTypeView].forEach({ $0?.isHidden = true })
		feedbackTypeView.addGestureRecognizer((UITapGestureRecognizer(target: self, action: #selector(feedbackTapped))))
		enquiryTypeView.addGestureRecognizer((UITapGestureRecognizer(target: self, action: #selector(enquiryTapped))))
		complaintTypeView.addGestureRecognizer((UITapGestureRecognizer(target: self, action: #selector(complaintTapped))))
	}
	
	@objc private func queryTypePressed() {
		setOptionsUI()
	}
	
	@objc private func feedbackTapped() {
		self.query = .feedback
		setOptionsUI()
	}
	
	@objc private func complaintTapped() {
		self.query = .complaint
		setOptionsUI()
	}
	
	@objc private func enquiryTapped() {
		self.query = .enquiry
		setOptionsUI()
	}
	
	private func setOptionsUI() {
		let selected = AppImages.AddAddress.radioSelected
		let unselected = AppImages.AddAddress.radioUnselected
		feedbackImgView.image = query == .feedback ? selected : unselected
		complaintImgView.image = query == .complaint ? selected : unselected
		enquiryImgView.image = query == .enquiry ? selected : unselected
		self.queryTypeSelected?(self.query, !openDropDown)
	}
	
	func configure(queryTypeSelected: FeedbackQueryType?, queryDropDownOpen: Bool = false) {
		self.query = queryTypeSelected
		self.openDropDown = queryDropDownOpen
		optionsStackView.isHidden = !queryDropDownOpen
		[feedbackTypeView, enquiryTypeView, complaintTypeView].forEach({ $0?.isHidden = !queryDropDownOpen })
		if let queryTypeSelected = queryTypeSelected {
			queryLabel.text = queryTypeSelected.title
		} else {
			queryLabel.text = "Query Type"
		}
	}
}
