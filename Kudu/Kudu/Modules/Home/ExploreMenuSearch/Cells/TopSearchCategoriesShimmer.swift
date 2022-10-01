//
//  TopSearchCategoriesShimmer.swift
//  Kudu
//
//  Created by Admin on 15/09/22.
//

import UIKit

class TopSearchCategoriesShimmer: UITableViewCell {
	
	@IBOutlet private weak var titleShimmer: UIView!
	@IBOutlet private weak var categoryShimmer1: UIView!
	@IBOutlet private weak var categoryShimmer2: UIView!
	@IBOutlet private weak var categoryShimmer3: UIView!
	@IBOutlet private weak var categoryShimmer4: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		selectionStyle = .none
		[titleShimmer, categoryShimmer1, categoryShimmer2, categoryShimmer3, categoryShimmer4].forEach({
			$0?.startShimmering()
		})
	}
}
