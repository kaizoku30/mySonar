//
//  ExploreMenuVC + Search.swift
//  Kudu
//
//  Created by Admin on 15/09/22.
//

import UIKit

extension ExploreMenuSearchVC {
	func setupTF() {
		searchTFView.textFieldType = .address
		searchTFView.placeholderText = LSCollection.SearchMenu.searchByNameOrCategories
		searchTFView.font = AppFonts.mulishBold.withSize(14)
		searchTFView.textColor = .black
		
		searchTFView.textFieldDidChangeCharacters = { [weak self] in
			guard let strongSelf = self, let text = $0 else { return }
			if strongSelf.isFetchingMenuItems || strongSelf.isShowingMenuData { return }
			strongSelf.textQuery = text
			strongSelf.currentViewType = .suggestionAndTopCategories
			strongSelf.searchIcon.isHidden = !text.isEmpty
			strongSelf.clearButton.isHidden = text.isEmpty
			strongSelf.debouncer.call()
		}
		
		searchTFView.textFieldDidBeginEditing = { [weak self] in
			guard let strongSelf = self else { return }
			if strongSelf.searchTFView.currentText.isEmpty {
				strongSelf.suggestions = []
				strongSelf.currentViewType = .recentSearchTopCategories
				strongSelf.clearButton.isHidden = true
				strongSelf.searchIcon.isHidden = false
				strongSelf.tableView.reloadData()
				strongSelf.tableView.isHidden = false
			} else {
				strongSelf.currentViewType = .suggestionAndTopCategories
				strongSelf.searchIcon.isHidden = true
				strongSelf.clearButton.isHidden = false
				strongSelf.tableView.reloadData()
				strongSelf.tableView.isHidden = false
			}
		}
		
		searchTFView.textFieldFinishedEditing = { [weak self] _ in
			guard let strongSelf = self else { return }
			strongSelf.keyboardDismissed()
		}
	}
	
	func handleDebouncer() {
		debouncer.callback = { [weak self] in
			guard let strongSelf = self else { return }
			strongSelf.debouncerFunction()
		}
	}
	
	func debouncerFunction() {
		if self.textQuery.isEmpty {
			self.suggestions = []
			self.currentViewType = .recentSearchTopCategories
			self.tableView.reloadData()
			self.tableView.isHidden = false
			return
		}
		
		if self.currentViewType == .suggestionAndTopCategories {
			self.isFetchingSuggestions = true
			self.tableView.reloadData()
			self.tableView.isHidden = false
			self.getSuggetions()
		}
	}
	
	func keyboardDismissed() {
		if self.isFetchingMenuItems || self.isShowingMenuData || self.isShowingItemData { return }
		self.currentViewType = self.searchTFView.currentText.isEmpty ? .recentSearchTopCategories : .results
		self.searchLine.isHidden = false
		if self.searchTFView.currentText.isEmpty {
			self.clearButton.isHidden = true
			self.searchIcon.isHidden = false
			self.results = []
			self.currentViewType = .recentSearchTopCategories
			self.tableView.reloadData()
			self.tableView.isHidden = false
			return
		}
		self.clearButton.isHidden = self.searchTFView.currentText.isEmpty
		self.searchIcon.isHidden = !self.searchTFView.currentText.isEmpty
		self.results = []
		self.pageNo = 1
		self.total = 0
		self.isFetchingResults = true
		self.tableView.reloadData()
		self.getResults()
	}
}
