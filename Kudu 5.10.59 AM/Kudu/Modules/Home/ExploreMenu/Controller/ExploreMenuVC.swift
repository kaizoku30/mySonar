//
//  ExploreMenuVC.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import UIKit

class ExploreMenuVC: BaseVC {
    @IBOutlet weak private var baseView: ExploreMenuView!
    var viewModel: ExploreMenuVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedIndex = viewModel?.getSelectedIndex, selectedIndex.magnitude != 0 {
            baseView.scrollToSelection(atIndex: Int(selectedIndex.magnitude))
        }
        viewModel?.fetchMenuItems()
        baseView.handleAPIRequest(.itemList)
        handleActions()
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            switch $0 {
            case .backButtonPressed:
                self?.pop()
            case .searchButtonPressed:
                let exploreSearchVC = ExploreMenuSearchVC.instantiate(fromAppStoryboard: .Home)
                self?.push(vc: exploreSearchVC)
            case .leftSwiped:
                self?.handleLeftSwipe()
            case .rightSwiped:
                self?.handleRightSwipe()
            case .browseMenuTapped:
                guard let baseView = self?.baseView else { return }
                let browseView = BrowseMenuView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                mainThread {
                    browseView.configure(categories: self?.viewModel?.getMenuCategories ?? [], container: baseView)
                }
                browseView.categorySelected = { [weak self] (index) in
                    self?.viewModel?.updateSelection(index)
                    self?.baseView.updateColletionView()
                    self?.viewModel?.fetchMenuItems()
                    self?.baseView.handleAPIRequest(.itemList)
                    mainThread {
                        self?.baseView.scrollToSelection(atIndex: index)
                    }
                }
            default:
                break
            }
        }
    }
    
}
extension ExploreMenuVC {
    
    private func handleLeftSwipe() {
        guard let currentCategories = viewModel?.getMenuCategories, let selectedIndex = viewModel?.getSelectedIndex else { return }
        if selectedIndex == currentCategories.count - 1 { return }
        let newIndex = selectedIndex + 1
        viewModel?.updateSelection(newIndex)
        baseView.updateColletionView()
        viewModel?.fetchMenuItems()
        mainThread {
            self.baseView.scrollToSelection(atIndex: newIndex)
        }
        baseView.handleAPIRequest(.itemList)
    }
    
    private func handleRightSwipe() {
        guard let selectedIndex = viewModel?.getSelectedIndex else { return }
        if selectedIndex == 0 { return }
        let newIndex = selectedIndex - 1
        viewModel?.updateSelection(newIndex)
        baseView.updateColletionView()
        viewModel?.fetchMenuItems()
        mainThread {
            self.baseView.scrollToSelection(atIndex: newIndex)
        }
        baseView.handleAPIRequest(.itemList)
    }
}

extension ExploreMenuVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: ExploreMenuCategoryCollectionViewCell.self, indexPath: indexPath)
        if indexPath.row < (viewModel?.getMenuCategories ?? []).count {
            let item = viewModel!.getMenuCategories![indexPath.row]
            cell.configure(item: item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel?.getMenuCategories ?? []).count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < (viewModel?.getMenuCategories ?? []).count {
            viewModel?.updateSelection(indexPath.row)
            baseView.updateColletionView()
            viewModel?.fetchMenuItems()
            baseView.handleAPIRequest(.itemList)
        }
    }
}

extension ExploreMenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel?.getMenuItems.isNil ?? false) ? 5 : (viewModel?.getMenuItems ?? []).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: ItemTableViewCell.self, indexPath: indexPath)
        cell.openItemDetail = { [weak self] (result) in
            guard let strongSelf = self else { return }
            mainThread {
                let bottomSheet = ItemDetailView(frame: CGRect(x: 0, y: 0, width: strongSelf.baseView.width, height: strongSelf.baseView.height))
                bottomSheet.configure(container: strongSelf.baseView, item: result)
            }
        }
        cell.likeStatusUpdated = { [weak self] (liked, itemId) in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return }
                viewModel.updateLikeStatus(liked, id: itemId)
        }
        cell.triggerLoginFlow = { [weak self] in
            let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
            loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromGuestUser)
            self?.push(vc: loginVC)
        }
        cell.backgroundColor = .clear
        if indexPath.row < (viewModel?.getMenuItems ?? []).count {
            let item = viewModel!.getMenuItems![indexPath.row]
            cell.configure(item)
        } else {
            cell.configureLoading()
        }
        return cell
    }
}

extension ExploreMenuVC: ExploreMenuVMDelegate {
    
    func itemListAPIResponse(responseType: Result<String, Error>) {
        switch responseType {
        case .success(let string):
            debugPrint(string)
            baseView.handleAPIResponse(.itemList, isSuccess: true, errorMsg: nil)
        case .failure(let error):
            baseView.handleAPIResponse(.itemList, isSuccess: false, errorMsg: error.localizedDescription)
        }
    }
}
