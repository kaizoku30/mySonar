//
//  ExploreMenuView.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import UIKit

class ExploreMenuView: UIView {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var errorToastView: AppErrorToastView!
    
    @IBAction private func backButtonPressed(_ sender: Any) {
        handleViewActions?(.backButtonPressed)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        handleViewActions?(.searchButtonPressed)
    }
    @IBAction func browseMenuButtonPressed(_ sender: Any) {
        handleViewActions?(.browseMenuTapped)
    }
    
    var handleViewActions: ((ViewActions) -> Void)?
    
    enum ViewActions {
        case itemPressed
        case backButtonPressed
        case searchButtonPressed
        case leftSwiped
        case rightSwiped
        case browseMenuTapped
    }
    
    enum APICalled {
        case itemList
    }
    
    @IBOutlet weak var exploreMenuTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
        exploreMenuTitleLabel.text = LocalizedStrings.ExploreMenu.exploreMenuTitle
    }
    
    private func initialSetup() {
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerCell(with: ExploreMenuCategoryCollectionViewCell.self)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.registerCell(with: ItemTableViewCell.self)
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(leftSwiped))
        leftSwipe.direction = .left
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(rightSwiped))
        rightSwipe.direction = .right
        tableView.addGestureRecognizer(leftSwipe)
        tableView.addGestureRecognizer(rightSwipe)
    }
    
    @objc private func leftSwiped() {
        debugPrint("Left Swipe")
        self.handleViewActions?(.leftSwiped)
    }
    
    @objc private func rightSwiped() {
        debugPrint("Right Swipe")
        self.handleViewActions?(.rightSwiped)
    }
    
    func scrollToSelection(atIndex index: Int) {
        mainThread {
            if index < self.collectionView.numberOfItems(inSection: 0) {
                self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
                self.collectionView.reloadData()
            }
        }
    }
    
    func updateColletionView() {
        mainThread {
            self.collectionView.reloadData()
        }
    }
}

extension ExploreMenuView {
    func handleAPIRequest(_ api: APICalled) {
        mainThread {
            switch api {
            case .itemList:
                self.tableView.reloadData()
            }
        }
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, errorMsg: String?) {
        mainThread {
            switch api {
            case .itemList:
                self.tableView.reloadData()
                if !isSuccess {
                    let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
                    toast.show(message: errorMsg ?? "", view: self)
                }
            }
        }
    }
}
