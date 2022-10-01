//
//  SelectedStoreListVC.swift
//  Kudu
//
//  Created by Admin on 27/09/22.
//

import UIKit

class SelectedStoreListVC: BaseVC {
    @IBOutlet private weak var baseView: SelectedStoreListView!
    let viewModel = SelectedStoreListVM()
    private var debouncer = Debouncer(delay: 1)
    private var isFetchingStores = true
    private var searchKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchStores()
        self.baseView.handleViewActions = { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .backButtonPressed:
                strongSelf.dismiss(animated: true)
            case .textChanged(let text):
                debugPrint(text)
                strongSelf.searchKey = text
                strongSelf.debouncer.call()
            case .clearAllPressed:
                strongSelf.viewModel.emptyStores()
                strongSelf.isFetchingStores = false
                strongSelf.baseView.refreshTableView()
            }
        }
        handleDebouncer()
    }
    
    private func handleDebouncer() {
        debouncer.callback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.emptyStores()
            strongSelf.isFetchingStores = true
            strongSelf.baseView.refreshTableView()
            strongSelf.fetchStores(resetPage: true)
        }
    }
}

extension SelectedStoreListVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if viewModel.getStores.isEmpty {
            return 1
        }
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.getStores.isEmpty {
            return 5
        } else {
            if section == 0 {
                return viewModel.getStores.count
            } else {
                return viewModel.getStores.count < viewModel.getTotal ? 1 : 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.getStores.isEmpty {
            let cell = tableView.dequeueCell(with: StoreListShimmerCell.self)
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = tableView.dequeueCell(with: StoreListMinDetailCell.self)
                cell.configure(viewModel.getStores[indexPath.row])
                return cell
            } else {
                let cell = tableView.dequeueCell(with: StoreListShimmerCell.self
                )
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && isFetchingStores == false && viewModel.getStores.count < viewModel.getTotal && !viewModel.getStores.isEmpty {
            debugPrint("Hit Pagination")
            self.fetchStores()
        }
    }
    
    private func fetchStores(resetPage: Bool = false) {
        self.isFetchingStores = true
        let page = resetPage ? 1 : viewModel.getPageNo + 1
        self.viewModel.fetchStores(pageNo: page, searchKey: searchKey, fetched: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.isFetchingStores = false
            switch $0 {
            case .success:
                strongSelf.baseView.refreshTableView()
                strongSelf.baseView.setStoreCount(strongSelf.viewModel.getTotal)
                strongSelf.baseView.showNoResult(strongSelf.viewModel.getStores.isEmpty)
            case .failure(let error):
                strongSelf.baseView.refreshTableView()
                strongSelf.baseView.showNoResult(true)
                if strongSelf.isShowingToast { return }
                strongSelf.isShowingToast = true
                mainThread {
                    let appError = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: strongSelf.baseView.width - 32, height: 48))
                    appError.show(message: error.localizedDescription, view: strongSelf.baseView, completionBlock: { [weak self] in
                        self?.isShowingToast = false
                    })
                }
            }
        })
    }
}
