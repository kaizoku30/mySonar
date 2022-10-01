//
//  LoadingDetailOverlay.swift
//  Kudu
//
//  Created by Admin on 14/09/22.
//

import UIKit
import NVActivityIndicatorView

final class LoadingDetailOverlay {
	static func create(withFrame frame: CGRect, atCenter containerCenter: CGPoint) -> UIView {
		let view = UIView(frame: frame)
		view.backgroundColor = .black.withAlphaComponent(0.5)
		let loader = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 30), type: .ballPulse, color: AppColors.kuduThemeYellow, padding: 0)
		view.addSubview(loader)
		loader.center = containerCenter
		loader.startAnimating()
		view.tag = Constants.CustomViewTags.detailOverlay
		return view
	}
}
