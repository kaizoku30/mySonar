//
//  OrderDetailVC.swift
//  Kudu
//
//  Created by Admin on 11/10/22.
//

import UIKit

class OrderDetailVC: BaseVC {
    @IBOutlet weak private var baseView: OrderDetailView!
    let viewModel = OrderDetailVM()
    private var fetchingDetails = true
    
    struct OrderDetailConfig {
        var orderStatusExpanded = false
        var billingDetailExpanded = false
        var orderDetailsExpanded = false
    }
    
    private var tableConfig = OrderDetailConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleActions()
        baseView.addRefreshControl()
        self.observeFor(.orderNotificationReceived, selector: #selector(initialSetup))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialSetup()
    }
    
    @objc private func initialSetup() {
        self.baseView.showLoader(show: true)
        self.viewModel.fetchOrderDetail(completion: {
            switch $0 {
            case .success:
                self.fetchingDetails = false
                self.baseView.refreshTableView()
                self.baseView.showLoader(show: false)
                let status = self.viewModel.getOrderDetail.getOrderStatus()
                let service = self.viewModel.getOrderDetail.getServiceType()
                if service != .delivery {
                    if status as! CurbsidePickupOrderStatus == .orderPlaced {
                        self.baseView.showCancelOrder(show: true)
                    } else {
                        self.baseView.showCancelOrder(show: false)
                    }
                }
                if !status.isActiveOrder {
                    self.baseView.showCancelOrder(show: false)
                    self.baseView.showReorder(show: true)
                }
            case .failure(let error):
                self.baseView.showLoader(show: false)
                self.baseView.showError(msg: error.localizedDescription)
            }
        })
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            switch $0 {
            case .pullToRefreshCalled:
                self?.initialSetup()
            case .backButtonPressed:
                self?.pop()
            case .supportButtonPressed:
                let supportDetails = SupportDetailsVC.instantiate(fromAppStoryboard: .Setting)
                self?.push(vc: supportDetails)
            case .cancelOrder:
                self?.viewModel.cancelOrder(completion: { [weak self] in
                    self?.baseView.showCancelOrder(show: false)
                    self?.baseView.showReorder(show: true)
                    switch $0 {
                    case .success:
                        self?.baseView.refreshTableView()
                    case .failure(let error):
                        self?.baseView.refreshTableView()
                        self?.baseView.showError(msg: error.localizedDescription)
                    }
                })
            case .rateOrderPressed:
                self?.goToRateOrderVC()
            case .reorderTrigger:
                self?.baseView.isUserInteractionEnabled = false
                self?.viewModel.reorderItems(completion: { [weak self] in
                    switch $0 {
                    case .success:
                        self?.baseView.isUserInteractionEnabled = true
                        self?.baseView.removePopup()
                        let vc = CartListViewController.instantiate(fromAppStoryboard: .CartPayment)
                        self?.push(vc: vc)
                    case .failure(let error):
                        self?.baseView.isUserInteractionEnabled = true
                        self?.baseView.removePopup()
                        self?.baseView.refreshTableView()
                        self?.baseView.showError(msg: error.localizedDescription)
                    }
                })
            }
        }
    }
    
    private func goToRateOrderVC() {
        let vc = RatingVC.instantiate(fromAppStoryboard: .Rating)
        vc.setOrderId(self.viewModel.getOrderDetail._id ?? "")
        self.push(vc: vc)
    }
}

extension OrderDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if fetchingDetails {
            return 0
        }
        
        return OrderDetailView.Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = OrderDetailView.Sections(rawValue: section) ?? .OrderInfo
        if section == .OrderDetails {
            return 2
        } else if section == .BillingDetails {
            var cellsInBillingDetails = 1
            //Header Cell - 1 cell
            if tableConfig.billingDetailExpanded {
                //Item Cells -
                let items = viewModel.getOrderDetail.items?.count ?? 0
                cellsInBillingDetails += items
                // Breakdown - 1 - 3 views managed through stack
                let breakdownCells = 1
                cellsInBillingDetails += breakdownCells
            }
            //TotalCell
            cellsInBillingDetails += 1
            return cellsInBillingDetails
        } else if section == .Rating {
            return viewModel.getOrderDetail.rating.isNotNil ? 1 : 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = OrderDetailView.Sections(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        switch section {
        case .OrderInfo:
            let cell = tableView.dequeueCell(with: OrderInfoTableViewCell.self)
            cell.selectionStyle = .none
            cell.callRestaurant = {
                if let url = NSURL(string: "tel://\(920006999)"), UIApplication.shared.canOpenURL(url as URL) {
                    UIApplication.shared.open(url as URL)
                }
            }
            cell.triggerMapRedirect = { [weak self] in
                guard let strongSelf = self else { return }
                guard let lat = self?.viewModel.getOrderDetail.restaurantLocation?.coordinates?.last, let long = self?.viewModel.getOrderDetail.restaurantLocation?.coordinates?.first else { return }
                OpenMapDirections.present(destinationLat: lat, destinationLong: long, in: strongSelf, sourceView: strongSelf.baseView)
            }
            cell.triggerRateOrder = { [weak self] in
                self?.goToRateOrderVC()
            }
            cell.ihaveArrived = { [weak self] in
                self?.viewModel.markArrival(completion: { [weak self] in
                    switch $0 {
                    case .success:
                        self?.baseView.refreshTableView()
                    case .failure(let error):
                        self?.baseView.refreshTableView()
                        self?.baseView.showError(msg: error.localizedDescription)
                    }
                })
            }
            cell.configure(orderId: viewModel.getOrderDetail.orderId ?? "", serviceType: APIEndPoints.ServicesType(rawValue: viewModel.getOrderDetail.servicesAvailable ?? "") ?? .delivery, arrivalInfo: (viewModel.getOrderDetail.isArrived ?? false, viewModel.getOrderDetail.arrivedStatus ?? "-1"), orderStatus: viewModel.getOrderDetail.orderStatus ?? "", rating: viewModel.getOrderDetail.rating)
            return cell
        case .OrderStatus:
            let serviceType = APIEndPoints.ServicesType(rawValue: viewModel.getOrderDetail.servicesAvailable ?? "") ?? .delivery
            if serviceType == .delivery {
                let cell = tableView.dequeueCell(with: DeliveryOrderStatusTableViewCell.self)
                cell.selectionStyle = .none
                cell.updateExpandedConfig = { [weak self] in
                    self?.tableConfig.orderStatusExpanded = $0
                    self?.baseView.changeHeightWithoutReload()
                }
                cell.configure(expanded: tableConfig.orderStatusExpanded, statusArray: viewModel.getOrderDetail.timeWithStatus ?? [], orderDelayed: viewModel.getOrderDetail.checkIfOrderDelayed(), etaTime: viewModel.getOrderDetail.calculateETA())
                return cell
            } else {
                let cell = tableView.dequeueCell(with: NonDeliveryOrderStatusTableViewCell.self)
                cell.selectionStyle = .none
                cell.updateExpandedConfig = { [weak self] in
                    self?.tableConfig.orderStatusExpanded = $0
                    self?.baseView.changeHeightWithoutReload()
                }
                cell.configure(expanded: tableConfig.orderStatusExpanded, statusArrayInc: viewModel.getOrderDetail.timeWithStatus ?? [], orderDelayed: viewModel.getOrderDetail.checkIfOrderDelayed(), etaTime: viewModel.getOrderDetail.calculateETA(), cancelledOrder: viewModel.getOrderDetail.getOrderStatus() as! CurbsidePickupOrderStatus == .cancelled)
                return cell
            }
        case .BillingDetails:
            return getBillingDetailsSectionCells(tableView, cellForRowAt: indexPath)
        case .OrderDetails:
            return getOrderDetailsSectionCells(tableView, cellForRowAt: indexPath)
        case .Rating:
            let cell = tableView.dequeueCell(with: RatingOrderTableViewCell.self)
            cell.selectionStyle = .none
            cell.configure(rating: viewModel.getOrderDetail.rating?.rate ?? 0.0, desc: viewModel.getOrderDetail.rating?.description ?? "")
            return cell
        }
        
    }
}

extension OrderDetailVC {
    private func getBillingDetailsSectionCells(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueCell(with: BillingDetailsHeaderCell.self)
            cell.updateExpandedConfig = { [weak self] in
                self?.tableConfig.billingDetailExpanded = $0
                self?.baseView.refreshTableView()
            }
            cell.selectionStyle = .none
            cell.configure(expanded: tableConfig.billingDetailExpanded)
            return cell
        }
        
        if tableConfig.billingDetailExpanded {
            if indexPath.row == tableView.numberOfRows(inSection: OrderDetailView.Sections.BillingDetails.rawValue) - 1 {
                //Last Row
                return getTotalPayableCell(tableView, cellForRowAt: indexPath)
            }
            if indexPath.row == tableView.numberOfRows(inSection: OrderDetailView.Sections.BillingDetails.rawValue) - 2 {
                //Second Last Row
                return getBillBreakDownCell(tableView, cellForRowAt: indexPath)
            }
            // Rest of the rows
            return getItemCell(tableView, cellForRowAt: indexPath)
        } else {
            return getTotalPayableCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    private func getTotalPayableCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: TotalPayableCell.self)
        cell.selectionStyle = .none
        let vat = viewModel.getOrderDetail.vat ?? 0.0
        cell.configure(vat: "\(vat.round(to: 2).removeZerosFromEnd())", totalAmount: viewModel.getOrderDetail.totalAmount ?? 0.0 - (viewModel.getOrderDetail.discount ?? 0.0))
        return cell
    }
    
    private func getItemCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: BillDetailItemTableViewCell.self)
        if indexPath.row - 1 < viewModel.getOrderDetail.items?.count ?? 0, let item = viewModel.getOrderDetail.items?[indexPath.row - 1] {
            let nameEnglish = item.itemDetails?.nameEnglish ?? ""
            let nameArabic = item.itemDetails?.nameArabic ?? ""
            let price = CartUtility.getPriceForAnItem(item)
            let quantity = item.quantity ?? 0
            cell.configure(quantity: quantity, nameEnglish: nameEnglish, nameArabic: nameArabic, price: price)
        }
        return cell
    }
    
    private func getBillBreakDownCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: BillDetailBreakdownCell.self)
        cell.selectionStyle = .none
        cell.configure(deliveryChargeAmount: viewModel.getOrderDetail.deliveryCharge ?? 0.0, discount: viewModel.getOrderDetail.discount ?? 0.0, itemTotal: viewModel.getOrderDetail.totalItemAmount ?? 0.0)
        return cell
    }
}

extension OrderDetailVC {
    private func getOrderDetailsSectionCells(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return getOrderDetailsSectionHeaderCell(tableView, cellForRowAt: indexPath)
        } else {
            if tableConfig.orderDetailsExpanded {
                return getOrderDetailBreakdownCell(tableView, cellForRowAt: indexPath)
            } else {
                return getOrderIdCell(tableView, cellForRowAt: indexPath)
            }
        }
        
    }
    
    private func getOrderDetailsSectionHeaderCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: OrderDetailsSectionHeaderCell.self)
        cell.selectionStyle = .none
        cell.updateExpandedConfig = { [weak self] in
            self?.tableConfig.orderDetailsExpanded = $0
            self?.baseView.refreshTableView()
        }
        cell.configure(expanded: tableConfig.orderDetailsExpanded)
        return cell
    }
    
    private func getOrderIdCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: OrderIdCell.self)
        cell.selectionStyle = .none
        cell.configure(orderId: viewModel.getOrderDetail.orderId ?? "")
        return cell
    }
    
    private func getOrderDetailBreakdownCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: OrderDetailBreakdownCell.self)
        var phoneNumber: String = DataManager.shared.loginResponse?.mobileNo ?? ""
        let serviceType = viewModel.getOrderDetail.getServiceType()
        var address: String = viewModel.getOrderDetail.restaurantLocation?.areaNameEnglish ?? ""
        if AppUserDefaults.selectedLanguage() == .ar {
            address = viewModel.getOrderDetail.restaurantLocation?.areaNameArabic ?? ""
        }
        if serviceType == .delivery {
            phoneNumber = viewModel.getOrderDetail.userAddress?.phoneNumber ?? ""
            if phoneNumber.isEmpty {
                phoneNumber = DataManager.shared.loginResponse?.mobileNo ?? ""
            }
            address = viewModel.getOrderDetail.userAddress?.buildingName ?? ""
        }
        let payment = viewModel.getOrderDetail.paymentType ?? ""
        var paymentString = ""
        if payment == "2" {
            switch APIEndPoints.ServicesType(rawValue: viewModel.getOrderDetail.servicesAvailable ?? "") ?? .delivery {
            case .delivery:
                paymentString = "Cash on Delivery"
            case .pickup:
                paymentString = "Cash on Pickup"
            case .curbside:
                paymentString = "Cash on Curbside"
            }
        } else {
            if payment == "1" {
                paymentString = "Card"
            } else {
                paymentString = "Apple Pay"
            }
        }
        cell.configure(payment: paymentString, orderId: viewModel.getOrderDetail.orderId ?? "", phoneNumber: phoneNumber, serviceType: APIEndPoints.ServicesType(rawValue: viewModel.getOrderDetail.servicesAvailable ?? "") ?? .delivery, address: address, orderStatus: viewModel.getOrderDetail.orderStatus ?? "")
        cell.selectionStyle = .none
        return cell
    }
}
