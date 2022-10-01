//
//  SelectedStoreListView.swift
//  Kudu
//
//  Created by Admin on 27/09/22.
//

import UIKit

class SelectedStoreListView: UIView {
    @IBOutlet private weak var storeCount: UILabel!
    @IBOutlet private weak var searchBarTF: AppTextFieldView!
    @IBOutlet private weak var noResult: NoResultFoundView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBarContainerView: UIView!
    @IBAction private func backButtonPressed(_ sender: Any) {
        self.handleViewActions?(.backButtonPressed)
    }
    @IBOutlet private weak var clearButton: AppButton!
    @IBAction private func clearAllPressed(_ sender: Any) {
        self.searchBarTF.currentText = ""
        self.handleViewActions?(.clearAllPressed)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        noResult.backgroundColor = AppColors.offWhiteTableBg
        noResult.alpha = 1
        tableView.backgroundColor = AppColors.offWhiteTableBg
        searchBarTF.placeholderText = "Search Store"
        noResult.contentType = .noResultFound
        searchBarContainerView.layer.applySketchShadow(color: UIColor(r: 39, g: 69, b: 136, alpha: 0.08), alpha: 1, x: 0, y: 2, blur: 136, spread: 0)
        searchBarTF.textFieldType = .address
        handleSearchBar()
    }
    
    enum ViewAction {
        case clearAllPressed
        case backButtonPressed
        case textChanged(updatedText: String)
        
    }
    
    var handleViewActions: ((ViewAction) -> Void)?
    
    func setStoreCount(_ count: Int) {
        mainThread {
            self.storeCount.text = "\(count) Stores"
        }
    }
    
    func refreshTableView() {
        mainThread {
            self.tableView.reloadData()
        }
    }
    
    func showNoResult(_ show: Bool) {
        mainThread {
            if show {
                self.storeCount.isHidden = true
                self.bringSubviewToFront(self.noResult)
                self.tableView.isHidden = true
            } else {
                self.storeCount.isHidden = false
                self.sendSubviewToBack(self.noResult)
                self.tableView.isHidden = false
            }
        }
    }
    
    func handleSearchBar() {
        searchBarTF.textFieldDidChangeCharacters = { [weak self] in
            self?.clearButton.isHidden = ($0 ?? "").isEmpty
            self?.handleViewActions?(.textChanged(updatedText: $0 ?? ""))
        }
        searchBarTF.textFieldFinishedEditing = { [weak self] in
            self?.clearButton.isHidden = ($0 ?? "").isEmpty
        }
    }
    
}
