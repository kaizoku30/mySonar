//
//  ExploreMenuSearchVC + View Operations.swift
//  Kudu
//
//  Created by Admin on 15/09/22.
//

import UIKit

extension ExploreMenuSearchVC {
	func toggleSearchState(searchBarActive: Bool) {
		self.searchContainer.borderColor = searchBarActive ? AppColors.ExploreMenuScreen.borderColor : .clear
		self.searchContainer.backgroundColor = searchBarActive ? AppColors.ExploreMenuScreen.searhBarBg : .white
	}
	
	func clearAllPressed() {
		self.isShowingMenuData = false
		self.searchTFView.isUserInteractionEnabled = true
		self.searchLine.isHidden = false
		self.clearButton.isHidden = true
		self.searchIcon.isHidden = false
		self.searchTFView.currentText = ""
		self.results = []
		self.suggestions = []
		self.currentViewType = .recentSearchTopCategories
		self.tableView.reloadData()
		self.tableView.isHidden = false
	}
	
	@objc  func searchIconPressed() {
		searchTFView.focus()
	}
}
