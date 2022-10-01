//
//  ExploreMenuVerticalListCell.swift
//  Kudu
//
//  Created by Admin on 26/08/22.
//

import UIKit

class ExploreMenuVerticalListCell: UICollectionViewCell {
    @IBOutlet private weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.registerCell(with: ItemTableViewCell.self)
    }
    
    private var menuItems: [MenuItem] = []
    private var tableIndex: Int = 0
	private var recentOffset: CGFloat = 0
	
    var openItemDetail: ((MenuItem, Int) -> Void)?
    var cartCountUpdated: ((Int, MenuItem, Int) -> Void)?
    var confirmCustomisationRepeat: ((Int, MenuItem, Int) -> Void)?
    var likeStatusUpdated: ((Bool, MenuItem, Int) -> Void)?
    var triggerLoginFlow: (() -> Void)?
    var lastCellOfInterest: ((Int, Int) -> Void)?
	var scrollBrowseMenu: ((Bool) -> Void)?
	var scrolled: ((Int) -> Void)?
	
	private var showingBrowseMenu = false
	
    func configure(data: [MenuItem], tableIndex: Int, recentMenuItemForAction: MenuItem?) {
        self.menuItems = data
        self.tableIndex = tableIndex
        if recentMenuItemForAction.isNil {
            self.tableView.relaodDataWithAnimation()
        } else {
			//, let index = self.menuItems.firstIndex(where: { recentMenuItemForAction!._id ?? "" == $0._id ?? "" })
            if recentMenuItemForAction.isNotNil {
				self.tableView.reloadData()
				self.tableView.layoutIfNeeded()
				self.recentOffset = recentMenuItemForAction?.verticalOffset ?? 0
				self.tableView.setContentOffset(CGPoint(x: 0, y: recentMenuItemForAction?.verticalOffset ?? self.tableView.contentOffset.y), animated: false)
//                self.tableView.scrollToRow(at: IndexPath(item: index, section: 0), at: .none, animated: false)
            }
        }
    }
}

extension ExploreMenuVerticalListCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.isEmpty ? 5 : self.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: ItemTableViewCell.self)
        cell.backgroundColor = .clear
        cell.openItemDetail = { [weak self] in
            guard let strongSelf = self else { return }
			var copy = $0
			copy.verticalOffset = Double(self?.tableView.contentOffset.y ?? 0)
            strongSelf.openItemDetail?(copy, strongSelf.tableIndex)
        }
        cell.cartCountUpdated = { [weak self] in
            guard let strongSelf = self else { return }
			var copy = $1
			copy.verticalOffset = Double(self?.tableView.contentOffset.y ?? 0)
            strongSelf.cartCountUpdated?($0, copy, strongSelf.tableIndex)
        }
        cell.confirmCustomisationRepeat = { [weak self] in
            guard let strongSelf = self else { return }
			var copy = $1
			copy.verticalOffset = Double(self?.tableView.contentOffset.y ?? 0)
            strongSelf.confirmCustomisationRepeat?($0, copy, strongSelf.tableIndex)
        }
        cell.likeStatusUpdated = { [weak self] in
            guard let strongSelf = self else { return }
			var copy = $1
			copy.verticalOffset = Double(self?.tableView.contentOffset.y ?? 0)
            strongSelf.likeStatusUpdated?($0, copy, strongSelf.tableIndex)
        }
        cell.triggerLoginFlow = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.triggerLoginFlow?()
        }
        if indexPath.item < menuItems.count {
            let item = menuItems[indexPath.item]
            cell.configure(item, serviceType: .delivery)
        } else {
            cell.configureLoading()
        }
        return cell
    }
}

extension ExploreMenuVerticalListCell: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		self.scrolled?(tableIndex)
		
		if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y > self.recentOffset && showingBrowseMenu == false {
			showingBrowseMenu = true
			self.scrollBrowseMenu?(true)
		}
		
		if scrollView.contentOffset.y == 0 {
			showingBrowseMenu = false
			self.scrollBrowseMenu?(false)
		}
		
		self.recentOffset = scrollView.contentOffset.y
		
//		if scrollView.contentOffset.y < recentOffset && scrollView.contentOffset.y < 89 && scrollView.contentOffset.y > 0 {
//			debugPrint("Height before : \(self.tableView.contentSize.height)")
//			self.tableView.height = self.tableHeight - scrollView.contentOffset.y
//			debugPrint("Height after : \(self.tableView.contentSize.height)")
//			self.scrollBrowseMenu?(self.tableView.contentOffset.y)
//		}
	}
}
