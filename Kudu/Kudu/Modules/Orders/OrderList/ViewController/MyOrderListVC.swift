//
//  MyOrderListVC.swift
//  Kudu
//
//  Created by Admin on 10/10/22.
//

import UIKit

class MyOrderListVC: BaseVC {
    
    @IBOutlet weak private var baseView: MyOrderListView!
    
    private let viewModel = MyOrderListVM()
    private var initialFetchDone = false
    private var fetchingData = true
    private var operationalIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleActions()
        initialSetup()
        addObservers()
    }
    
    private func initialSetup() {
        self.initialFetchDone = false
        self.baseView.refreshTable()
        viewModel.getOrderList(pageNo: 1, fetched: { [weak self] in
            self?.initialFetchDone = true
            self?.fetchedOrders($0)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialSetup()
    }
    
    private func addObservers() {
        self.observeFor(.updateOrderObject, selector: #selector(handleOrderUpdate(notification:)))
        self.observeFor(.orderNotificationReceived, selector: #selector(handleOrderUpdate(notification:)))
    }
    
    @objc private func handleOrderUpdate(notification: NSNotification) {
        self.viewModel.getOrderList(pageNo: 1) { [weak self] in
            self?.fetchedOrders($0)
        }
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .pullToRefreshCalled:
                strongSelf.viewModel.getOrderList(pageNo: 1) { [weak self] in
                    self?.fetchedOrders($0)
                }
            case .backButtonPressed:
                strongSelf.pop()
            case .reorderTrigger:
                strongSelf.viewModel.reorderItems(completion: { [weak self] in
                    switch $0 {
                    case .success:
                        self?.baseView.stopInteraction(stop: false)
                        let vc = CartListViewController.instantiate(fromAppStoryboard: .CartPayment)
                        self?.baseView.removePopup()
                        self?.push(vc: vc)
                    case .failure(let error):
                        self?.baseView.stopInteraction(stop: false)
                        self?.baseView.removePopup()
                        self?.baseView.showError(msg: error.localizedDescription)
                    }
                })
            }
        }
    }
    
    private func rateOrderFlow(orderId: String) {
        let vc = RatingVC.instantiate(fromAppStoryboard: .Rating)
        vc.setOrderId(orderId)
        self.push(vc: vc)
    }
}

extension MyOrderListVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if !initialFetchDone {
            return 1
        }
        
        return MyOrderListView.Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !initialFetchDone {
            return UIView.init(frame: CGRect.zero)
        }
        let section = MyOrderListView.Sections(rawValue: section)!
        switch section {
        case .activeOrders:
            if viewModel.getActiveOrders.isEmpty { return UIView.init(frame: CGRect.zero) }
            let uiView = OrderListHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 48))
            uiView.titleLabel.text = "Active Orders"
            return uiView
        case .previousOrders:
            if viewModel.getPreviousOrders.isEmpty { return UIView.init(frame: CGRect.zero) }
            let uiView = OrderListHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 48))
            uiView.titleLabel.text = LSCollection.Orders.previousOrders
            return uiView
        default:
            return UIView.init(frame: CGRect.zero)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !initialFetchDone {
            return 0
        }
        let section = MyOrderListView.Sections(rawValue: section)!
        switch section {
        case .activeOrders:
            if viewModel.getActiveOrders.isEmpty { return 0 }
            return 48
        case .previousOrders:
            if viewModel.getPreviousOrders.isEmpty { return 0 }
            return 48
        default:
            return 0 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !initialFetchDone {
            return 5
        }
        
        if !fetchingData {
            self.baseView.showNoResult(viewModel.getOrders.isEmpty)
        }
        
        let section = MyOrderListView.Sections(rawValue: section)!
        if section == .activeOrders {
            return viewModel.getActiveOrders.count
        } else if section == .previousOrders {
            return viewModel.getPreviousOrders.count
        } else {
            return viewModel.getOrders.count < viewModel.getTotal ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !initialFetchDone || indexPath.section == tableView.numberOfSections - 1 || ((indexPath.row == self.operationalIndex ?? -1) && indexPath.section == MyOrderListView.Sections.activeOrders.rawValue) {
            let cell = tableView.dequeueCell(with: MyOrderListShimmerCell.self, indexPath: indexPath)
            cell.selectionStyle = .none
            return cell
        }
        
        let section = MyOrderListView.Sections(rawValue: indexPath.section)!
        
        if section == .activeOrders {
            let item = viewModel.getActiveOrders[indexPath.row]
            let serviceType = item.getServiceType()
            if serviceType == .delivery {
                let cell = tableView.dequeueCell(with: ActiveOrderDeliveryCell.self)
                cell.configure(viewModel.getActiveOrders[indexPath.row])
                cell.selectionStyle = .none
                return cell
            } else {
               return getCurbsidePickupCell(tableView, cellForRowAt: indexPath)
            }
        } else if section == .previousOrders {
            let cell = tableView.dequeueCell(with: PreviousOrderCell.self)
            cell.reOrder = { [weak self] (orderId) in
                self?.viewModel.setupReorder(orderId)
                self?.baseView.stopInteraction(stop: true)
                if CartUtility.fetchCartLocally().isEmpty {
                    self?.baseView.handleViewActions?(.reorderTrigger)
                } else {
                    self?.baseView.stopInteraction(stop: false)
                    self?.baseView.showCartClearanceAlert()
                }
            }
            cell.rateOrder = { [weak self] (orderId) in
                self?.rateOrderFlow(orderId: orderId)
            }
            cell.configure(viewModel.getPreviousOrders[indexPath.row])
            cell.selectionStyle = .none
            return cell
        } else {
            // case will not happen, handled above already
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1, self.fetchingData == false, viewModel.getOrders.count < viewModel.getTotal, !viewModel.getOrders.isEmpty {
            debugPrint("HIT PAGINATION")
            fetchingData = true
            viewModel.getOrderList(pageNo: viewModel.getPageNo + 1, fetched: { [weak self] in
                self?.fetchedOrders($0)
            })
        }
    }
    
    func getCurbsidePickupCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: ActiveOrderNonDeliveryCell.self)
        let item = viewModel.getActiveOrders[indexPath.row]
        cell.triggerMapRedirect = { [weak self] (index) in
            guard let strongSelf = self else { return }
            guard let item = strongSelf.viewModel.getActiveOrders[safe: index], let lat = item.restaurantLocation?.coordinates?.last, let long = item.restaurantLocation?.coordinates?.first else { return }
            
            OpenMapDirections.present(destinationLat: lat, destinationLong: long, in: strongSelf, sourceView: strongSelf.baseView)
        }
        cell.markAsArrived = { [weak self] (index) in
            self?.handleMarkAsArrivedFlow(forIndex: index)
        }
        cell.cellIndex = indexPath.row
        cell.configure(item)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = MyOrderListView.Sections(rawValue: indexPath.section)!
        var orderId: String?
        if section == .activeOrders {
            orderId = viewModel.getActiveOrders[indexPath.row]._id ?? ""
        }
        
        if section == .previousOrders {
            orderId = viewModel.getPreviousOrders[indexPath.row]._id ?? ""
        }
        
        if orderId.isNotNil && section == .activeOrders || section == .previousOrders {
            let vc = OrderDetailVC.instantiate(fromAppStoryboard: .CartPayment)
            vc.viewModel.configure(orderId: orderId!)
            self.push(vc: vc)
        }
    }
    
    private func handleMarkAsArrivedFlow(forIndex index: Int) {
        guard let relevantItem = self.viewModel.getActiveOrders[safe: index], let orderId = relevantItem._id, let arrivalStatus = relevantItem.arrivedStatus, let arrivalStatusType = ArrivalStatus(rawValue: arrivalStatus) else { return }
        if arrivalStatusType != .willArive { return }
        self.operationalIndex = index
        self.baseView.refreshTable()
        self.baseView.restrictInteraction(true)
        self.viewModel.markArrived(forOrderId: orderId, completed: { [weak self] in
            switch $0 {
            case .success(let updatedData):
                self?.operationalIndex = nil
                self?.baseView.restrictInteraction(false)
                let orderStatus = CurbsidePickupOrderStatus(rawValue: updatedData.orderStatus ?? "")
                if orderStatus == .collected || orderStatus == .cancelled {
                    //Order has completed
                    self?.initialFetchDone = false
                    self?.fetchingData = true
                    self?.initialSetup()
                    return
                }
                self?.viewModel.updateSpecificActiveOrder(index: index, updatedObj: updatedData)
                self?.baseView.refreshIndex(index, section: .activeOrders)
            case .failure(let error):
                self?.operationalIndex = nil
                self?.baseView.refreshTable()
                self?.baseView.restrictInteraction(false)
                self?.baseView.showError(msg: error.localizedDescription)
            }
        })
    }
}

extension MyOrderListVC {
    private func fetchedOrders(_ result: Result<Bool, Error>) {
        mainThread {
            self.fetchingData = false
            switch result {
            case .success:
                self.baseView.refreshTable()
            case .failure(let error):
                self.baseView.refreshTable()
                self.baseView.showError(msg: error.localizedDescription)
            }
        }
    }
}
