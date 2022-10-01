//
//  HapticFeedbackGenerator.swift
//  Kudu
//
//  Created by Admin on 06/09/22.
//

import UIKit

final class HapticFeedbackGenerator {

	enum HapticFeedbackType {
		case error
		case success
		case warning
		case lightTap
		case mediumTap
		case heavyTap
		case selectionChanged
	}
	
	static func triggerVibration(type: HapticFeedbackType) {
		mainThread {
			switch type {
			case .error:
				let generator = UINotificationFeedbackGenerator()
				generator.prepare()
				generator.notificationOccurred(.error)
			case .success:
				let generator = UINotificationFeedbackGenerator()
				generator.prepare()
				generator.notificationOccurred(.success)
			case .warning:
				let generator = UINotificationFeedbackGenerator()
				generator.prepare()
				generator.notificationOccurred(.warning)
			case .lightTap:
				let generator = UIImpactFeedbackGenerator(style: .light)
				generator.prepare()
				generator.impactOccurred()
			case .mediumTap:
				let generator = UIImpactFeedbackGenerator(style: .medium)
				generator.prepare()
				generator.impactOccurred()
			case .heavyTap:
				let generator = UIImpactFeedbackGenerator(style: .heavy)
				generator.prepare()
				generator.impactOccurred()
			case .selectionChanged:
				let generator = UISelectionFeedbackGenerator()
				generator.prepare()
				generator.selectionChanged()
			}
		}
	}
}
