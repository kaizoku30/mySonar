//
//  HorizontalContentCollectionViewCell.swift
//  Kudu
//
//  Created by Admin on 13/09/22.
//

import UIKit

class HorizontalContentCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var tableView: UITableView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		tableView.registerCell(with: ItemTableViewCell.self)
	}
	
    private var serviceType: APIEndPoints.ServicesType = .delivery
	private var maxRowCount = 0
	private var isCurrentColumn = false
	private var columnArray: [MenuItem] = []
	var likeStatusUpdated: ((Bool, MenuItem, Int) -> Void)?
	var openItemDetail: ((MenuItem, Int) -> Void)?
	var cartCountUpdated: ((Int, MenuItem, Int) -> Void)?
	var confirmCustomisationRepeat: ((Int, MenuItem, Int) -> Void)?
	var triggerLoginFlow: ((AddCartItemRequest?, FavouriteRequest?) -> Void)?
    var cartConflict: ((Int, MenuItem) -> Void)?
    
    func configure(maxRowCount: Int, isCurrentColumn: Bool, columnArray: [MenuItem], serviceType: APIEndPoints.ServicesType) {
        self.serviceType = serviceType
		self.maxRowCount = maxRowCount
		self.isCurrentColumn = isCurrentColumn
		self.columnArray = columnArray
        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
	}
	
}

extension HorizontalContentCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
	
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isCurrentColumn {
            return UITableView.automaticDimension
        } else {
            return 197

        }
    }
    
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		maxRowCount
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if !isCurrentColumn {
			let cell = tableView.dequeueCell(with: ResultShimmerTableViewCell.self, indexPath: indexPath)
			return cell
		} else {
			let cell = tableView.dequeueCell(with: ItemTableViewCell.self, indexPath: indexPath)
			if indexPath.row < columnArray.count {
                cell.configure(columnArray[indexPath.row], serviceType: self.serviceType)
				cell.likeStatusUpdated = { [weak self] in
					self?.likeStatusUpdated?($0, $1, indexPath.item)
				}
				cell.openItemDetail = { [weak self] in
					self?.openItemDetail?($0, indexPath.item)
				}
				cell.cartCountUpdated = { [weak self] in
					self?.cartCountUpdated?($0, $1, indexPath.item)
				}
				cell.confirmCustomisationRepeat = { [weak self] in
					self?.confirmCustomisationRepeat?($0, $1, indexPath.item)
				}
				cell.triggerLoginFlow = { [weak self] in
                    self?.triggerLoginFlow?($0, $1)
				}
                cell.cartConflict = { [weak self] in
                    self?.cartConflict?($0, $1)
                }
				cell.isHidden = false
			} else {
				cell.stopShimmer()
				cell.isHidden = true
			}
			return cell
		}
	}
}
