//
//  MyFavouritesVC.swift
//  Kudu
//
//  Created by Admin on 18/08/22.
//

import UIKit

class MyFavouritesVC: BaseVC {
    @IBOutlet private weak var baseView: MyFavouritesView!
    var viewModel: MyFavouritesVM!
	private var initialFetchDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleActions()
        initialSetup()
        debugPrint("Current Hash Ids in System : \(AppUserDefaults.value(forKey: .hashIdsForFavourites) as? [String] ?? [])")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.viewModel.getItems.isEmpty == false {
            self.initialFetchDone = false
            self.baseView.refreshTableView()
            self.initialSetup()
            self.baseView.refreshCartLocally()
        }
    }
    
    private func initialSetup() {
        baseView.handleAPIRequest(.favouritesAPI)
        viewModel.getFavourites(pageNo: 1)
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] (action) in
            guard let strongSelf = self else { return }
            switch action {
            case .backButtonPressed:
                strongSelf.pop()
            case .viewCart:
                strongSelf.baseView.retainOffset()
                let vc = CartListViewController.instantiate(fromAppStoryboard: .CartPayment)
                vc.flow = .fromFavourites
                strongSelf.push(vc: vc)
            case .handleCartConflict(let count, let index):
                self?.viewModel.updateCountLocally(count: count, index: index)
                self?.baseView.refreshTableView()
                self?.baseView.refreshCartLocally()
            }
        }
    }
}

extension MyFavouritesVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
		
		if !initialFetchDone {
			return 1
		}
		
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if !initialFetchDone {
			return 5
		}
		
        if section == 0 {
			return viewModel.getItems.count
        } else {
			return viewModel.getItems.count < viewModel.getTotal ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
		if !initialFetchDone {
			let cell = tableView.dequeueCell(with: ResultShimmerTableViewCell.self, indexPath: indexPath)
			return cell
		}
		
        if indexPath.section == 0 {
			return getItemCell(tableView, cellForRowAt: indexPath)
        } else {
			let cell = tableView.dequeueCell(with: ResultShimmerTableViewCell.self, indexPath: indexPath)
			return cell
        }
        
    }
    
    private func getItemCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: ItemTableViewCell.self)
        if let item = viewModel.getItems[safe: indexPath.row] {
            cell.configure(item, index: indexPath.row)
            cell.configureForFavourites(index: indexPath.row)
        }
        cell.confirmCustomisationRepeatForFavourites = { [weak self] (item, countToUpdate, indexOfItem) in
            self?.handleCustomiseRepeat(item: item, count: countToUpdate, index: indexOfItem)
        }
        cell.cartCountUpdatedForFavourites = { [weak self] (_, count, index) in
            self?.viewModel.updateCountLocally(count: count, index: index)
            self?.baseView.refreshCartLocally()
        }
        cell.cartConflictForFavourites = { [weak self] in
            self?.baseView.showCartConflictAlert($0, index: $1)
        }
        cell.openItemDetailForFavourites = { [weak self] (result, index) in
            guard let strongSelf = self else { return }
            mainThread {
                guard let item = strongSelf.viewModel.getItems[safe: index] else { return }
                if result.isCustomised ?? false {
                    strongSelf.baseView.handleAPIRequest(.itemDetail)
                    var templateToLoad: CustomisationTemplate? = CustomisationTemplate(modGroups: item.modGroups ?? [], hashId: item.hashId ?? "")
                    if (item.modGroups ?? []).isEmpty {
                        templateToLoad = nil
                    }
                    strongSelf.viewModel?.fetchItemDetail(itemId: result._id ?? "", preLoadTemplate: templateToLoad, indexFavouriteArray: index)
                } else {
                    let vc = BaseVC()
                    vc.configureForCustomView()
                    strongSelf.tabBarController?.addOverlayBlack()
                    let itemDetailSheet = ItemDetailView(frame: CGRect(x: 0, y: 0, width: strongSelf.baseView.width, height: strongSelf.baseView.height))
                    itemDetailSheet.configureForExploreMenu(container: vc.view, itemId: result._id ?? "", serviceType: APIEndPoints.ServicesType(rawValue: item.itemDetails?.servicesAvailable ?? "") ?? .delivery)
                    itemDetailSheet.cartCountUpdated = { (count, item) in
                        let hashId = MD5Hash.generateHashForTemplate(itemId: item._id ?? "", modGroups: nil)
                        guard let indexofIncomingItem = self?.viewModel.getItems.firstIndex(where: { $0.hashId ?? "" == hashId}) else { return }
                        strongSelf.viewModel.updateCountLocally(count: count, index: indexofIncomingItem)
                        strongSelf.baseView.refreshTableView()
                    }
                    itemDetailSheet.handleDeallocation = {
                        vc.dismiss(animated: true, completion: { [weak self] in
                            self?.tabBarController?.removeOverlay()
                        })
                    }
                    strongSelf.present(vc, animated: true)
                }
            }
        }
        cell.removeFromFavourites = { [weak self] (id, index) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.removeFromFavourites(id: id, index: index)
            strongSelf.baseView.removeFromFavourites(index: index)
            NotificationCenter.postNotificationForObservers(.favouriteStateUpdatedFromCart)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && baseView.isFetchingItems == false && viewModel.getItems.count < viewModel.getTotal && !viewModel.getItems.isEmpty {
            debugPrint("Hit Pagination")
            baseView.handleAPIRequest(.favouritesAPI)
            viewModel.getFavourites(pageNo: viewModel.getPageNo + 1)
        }
    }
}

extension MyFavouritesVC: MyFavouritesVMDelegate {
    
    func itemDetailAPIResponse(responseType: Result<CustomisationTemplate?, Error>) {
        switch responseType {
        case .success(let template):
            baseView.handleAPIResponse(.itemDetail, isSuccess: true, noResult: false, errorMsg: nil)
            self.openCustomisedItemDetail(result: self.viewModel?.getItemDetailResponse, prefillTempate: template, favArrayItemIndex: self.viewModel.getItemDetailIndex ?? 0)
			self.baseView.removeLoadingOverlay()
        case .failure(let error):
            self.baseView.removeLoadingOverlay()
            baseView.handleAPIResponse(.itemDetail, isSuccess: false, noResult: false, errorMsg: error.localizedDescription)
        }
    }
    
    func favouriteAPIResponse(responseType: Result<String, Error>) {
        switch responseType {
        case .success(let string):
            debugPrint(string)
			self.initialFetchDone = true
            self.baseView.handleAPIResponse(.favouritesAPI, isSuccess: true, noResult: viewModel.getItems.isEmpty, errorMsg: nil)
        case .failure(let error):
            self.baseView.handleAPIResponse(.favouritesAPI, isSuccess: false, noResult: false, errorMsg: error.localizedDescription)
        }
    }
}

extension MyFavouritesVC {
    private func openCustomisedItemDetail(result: MenuItem?, prefillTempate: CustomisationTemplate? = nil, favArrayItemIndex: Int) {
        if let result = result {
            mainThread {
                let vc = BaseVC()
                vc.configureForCustomView()
                guard let serviceAvailable = self.viewModel.getItems[safe: favArrayItemIndex]?.itemDetails?.servicesAvailable, let serviceType = APIEndPoints.ServicesType(rawValue: serviceAvailable) else { return }
                let bottomSheet = CustomisableItemDetailView(frame: CGRect(x: 0, y: 0, width: self.baseView.width, height: self.baseView.height))
                bottomSheet.configure(item: result, container: vc.view, preLoadTemplate: prefillTempate, serviceType: serviceType)
                bottomSheet.addToCart = { [weak self] (modGroupArray, hashId, _) in
                    guard let strongSelf = self else { return }
                    let hashIdExists = strongSelf.viewModel.getItems.firstIndex(where: { $0.hashId ?? "" == hashId })
                    if hashIdExists.isNotNil {
                        let previousCount = strongSelf.viewModel.getItems[hashIdExists!].cartCount ?? 0
                        strongSelf.viewModel.updateCountLocally(count: previousCount + 1, index: hashIdExists!)
                        strongSelf.baseView.refreshCartLocally()
                        strongSelf.baseView.refreshTableView()
                    } else {
                        var copy = result
                        copy.servicesAvailable = serviceAvailable
                        strongSelf.viewModel.addToCartDirectly(menuItem: copy, hashId: hashId, modGroups: modGroupArray ?? [])
                        strongSelf.baseView.refreshCartLocally()
                    }
                }
                bottomSheet.handleDeallocation = { [weak self] in
                    vc.dismiss(animated: true, completion: {
                        self?.tabBarController?.removeOverlay()
                    })
                }
                self.tabBarController?.addOverlayBlack()
                self.present(vc, animated: true)
            }
        }
    }
}

extension MyFavouritesVC {
    private func handleCustomiseRepeat(item: MenuItem, count: Int, index: Int) {
        self.baseView.refreshTableView()
        let popUp = RepeatCustomisationView(frame: CGRect(x: 0, y: 0, width: self.view.width - AppPopUpView.HorizontalPadding, height: 0))
        popUp.configure(container: self.baseView)
        popUp.handleAction = { [weak self] (action) in
            mainThread {
                if action == .repeatCustomisation {
                    self?.viewModel.updateCountLocally(count: count, index: index)
                    self?.baseView.refreshCartLocally()
                } else {
                    //No Customisation
                    self?.baseView.addLoadingOverlay()
                    self?.viewModel?.fetchItemDetail(itemId: item._id ?? "", preLoadTemplate: nil, indexFavouriteArray: index)
                }
            }
        }
    }
}
