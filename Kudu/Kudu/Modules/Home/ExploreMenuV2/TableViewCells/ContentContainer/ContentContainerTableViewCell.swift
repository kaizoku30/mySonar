//
//  ContentContainerTableViewCell.swift
//  Kudu
//
//  Created by Admin on 13/09/22.
//

import UIKit

struct ContentContainerTableViewCellVM {
    let categories: [MenuCategory]
    let columnData: [[MenuItem]]
    let metrics: ExploreMenuViewScrollMetrics
    let queueScroll: Bool
    let reloadData: Bool
    let serviceType: APIEndPoints.ServicesType
}

class ContentContainerTableViewCell: UITableViewCell {
	@IBOutlet weak var collectionView: UICollectionView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.semanticContentAttribute = .forceLeftToRight
	}
	
	private var categories: [MenuCategory] = []
    var columnData: [[MenuItem]] = []
    var metrics: ExploreMenuViewScrollMetrics!
	
	var queueScrollComplete: (() -> Void)?
	var likeStatusUpdated: ((Bool, MenuItem, Int) -> Void)?
	var openItemDetail: ((MenuItem, Int) -> Void)?
	var cartCountUpdated: ((Int, MenuItem, Int) -> Void)?
	var confirmCustomisationRepeat: ((Int, MenuItem, Int) -> Void)?
	var triggerLoginFlow: ((AddCartItemRequest?, FavouriteRequest?) -> Void)?
    var cartConflict: ((Int, MenuItem) -> Void)?
    var cellSwipedToIndex: ((Int) -> Void)?
    
	private var reloadData = false
    private var serviceType: APIEndPoints.ServicesType = .delivery
	
    func refreshTable() {
        mainThread {
            self.collectionView.reloadItems(at: [IndexPath(item: self.metrics.currentColumnIndex, section: 0)])
        }
    }
    
    func configure(_ vm: ContentContainerTableViewCellVM) {
        self.serviceType = vm.serviceType
        self.categories = vm.categories
        self.columnData = vm.columnData
        self.metrics = vm.metrics
        if vm.queueScroll {
            if self.collectionView.numberOfItems(inSection: 0) != self.categories.count {
                self.collectionView.reloadData()
            } else {
                self.collectionView.reloadItems(at: [IndexPath(item: self.metrics.currentColumnIndex, section: 0)])
            }
            self.collectionView.performBatchUpdates({ //Let collection view update
            }, completion: { _ in
                self.collectionView.scrollToItem(at: IndexPath(item: self.metrics.currentColumnIndex, section: 0), at: .centeredHorizontally, animated: true)
            })
            self.queueScrollComplete?()
		}
        if vm.reloadData {
            self.reloadData = vm.reloadData
			self.collectionView.reloadItems(at: [IndexPath(item: self.metrics.currentColumnIndex, section: 0)])
			self.layoutIfNeeded()
			self.collectionView.scrollToItem(at: IndexPath(item: self.metrics.currentColumnIndex, section: 0), at: .centeredHorizontally, animated: false)
		}
	}
	
}

extension ContentContainerTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        return CGSize(width: self.width, height: self.collectionView.height - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom )
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		categories.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueCell(with: HorizontalContentCollectionViewCell.self, indexPath: indexPath)
        cell.configure(maxRowCount: metrics.maxRows, isCurrentColumn: metrics.currentColumnIndex == indexPath.item, columnArray: columnData[indexPath.item], serviceType: self.serviceType)
		cell.likeStatusUpdated = { [weak self] in
			self?.likeStatusUpdated?($0, $1, $2)
		}
		cell.openItemDetail = { [weak self] in
			self?.openItemDetail?($0, $1)
		}
		cell.cartCountUpdated = { [weak self] in
			self?.cartCountUpdated?($0, $1, $2)
		}
		cell.confirmCustomisationRepeat = { [weak self] in
			self?.confirmCustomisationRepeat?($0, $1, $2)
		}
		cell.triggerLoginFlow = { [weak self] in
            self?.triggerLoginFlow?($0, $1)
		}
        cell.cartConflict = { [weak self] in
            self?.cartConflict?($0, $1)
        }
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		0
	}
}

extension ContentContainerTableViewCell: UIScrollViewDelegate {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageNo = Int(scrollView.contentOffset.x/scrollView.width)
		debugPrint("Current Page : \(pageNo)")
		self.metrics.currentColumnIndex = pageNo
        self.collectionView.reloadItems(at: [IndexPath(item: self.metrics.currentColumnIndex, section: 0)])
        self.collectionView.performBatchUpdates({ //Let collectionview update
        }, completion: { [weak self] _ in
            self?.cellSwipedToIndex?(pageNo)
        })
	}
}
