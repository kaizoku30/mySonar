//
//  CartCouponListVC.swift
//  Kudu
//
//  Created by Admin on 26/09/22.
//

import UIKit

class CartCouponListVC: BaseVC {
    @IBOutlet private weak var baseView: CartCouponListView!
    let viewModel = CartCouponListVM()
    private var expanded: [String: Bool] = [:]
    var syncCart: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleActions()
        viewModel.fetchCoupons { [weak self] in
            self?.baseView.refreshTable()
        }
    }
    
    private func handleActions() {
        baseView.handleViewActions = { [weak self] in
            switch $0 {
            case .applyButtonPressed(let text):
                self?.tryApply(coupon: text)
            case .backButtonPressed:
                self?.pop()
            }
        }
    }
}

extension CartCouponListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getCoupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: CartCouponListCell.self)
        cell.applyCoupon = { [weak self] in
            guard let couponCode = self?.viewModel.getCoupons[safe: $0]?.couponCode?.first?.couponCode, couponCode.isEmpty == false else {
                return
            }
            self?.baseView.prepareForCouponApplication()
            self?.tryApply(coupon: couponCode)
        }
        cell.expandPointers = { [weak self] in
            let couponId = self?.viewModel.getCoupons[indexPath.row]._id ?? ""
            self?.expanded[couponId] = !(self?.expanded[couponId] ?? false)
            self?.baseView.reloadRow(index: $0)
        }
        let couponId = viewModel.getCoupons[indexPath.row]._id ?? ""
        let isExpanded = self.expanded[couponId] ?? false
        cell.configure(viewModel.getCoupons[indexPath.row], isExpanded: isExpanded, index: indexPath.row)
        return cell
    }
}

extension CartCouponListVC {
    private func tryApply(coupon: String) {
        
        // MARK: ASK DAWOOD TO HANDLE THIS PROPERLY SO NO CHECK ON FRONTEND NEEDED
        
        let coupons = viewModel.getCoupons
        if let couponCodeExists = coupons.first(where: { $0.couponCode?.first?.couponCode ?? "" == coupon }) {
            // API HIT NOT NEEDED AS DATA ALREADY PRESENT
            let couponInvalid = CartUtility.checkCouponValidationError(couponCodeExists)
            if couponInvalid.isNil {
                self.viewModel.updateAppliedCoupon(couponCodeExists, completion: { [weak self] in
                    switch $0 {
                    case .success:
                        self?.applyCoupon()
                    case .failure(let error):
                        self?.baseView.stopButtonLoader()
                        if self?.isShowingToast ?? false { return }
                        self?.isShowingToast = true
                        self?.baseView.showError(msg: error.localizedDescription, completionBlock: { [weak self] in
                            self?.isShowingToast = false
                        })
                    }
                })
            } else {
                self.baseView.stopButtonLoader()
                if self.isShowingToast { return }
                self.isShowingToast = true
                self.baseView.showError(msg: couponInvalid!.errorMsg, completionBlock: { [weak self] in
                    self?.isShowingToast = false
                })
            }
        } else {
            viewModel.fetchCouponDetail(code: coupon, fetched: { [weak self] in
                guard let strongSelf = self else { return }
                switch $0 {
                case .success(let couponValid):
                    if couponValid {
                        strongSelf.applyCoupon()
                    } else {
                        strongSelf.baseView.stopButtonLoader()
                        if strongSelf.isShowingToast { return }
                        strongSelf.isShowingToast = true
                        strongSelf.baseView.showError(msg: "Could not apply coupon", completionBlock: { [weak self] in
                            self?.isShowingToast = false
                        })
                    }
                case .failure(let error):
                    strongSelf.baseView.stopButtonLoader()
                    if strongSelf.isShowingToast { return }
                    strongSelf.isShowingToast = true
                    strongSelf.baseView.showError(msg: error.localizedDescription, completionBlock: { [weak self] in
                        self?.isShowingToast = false
                    })
                }
            })
        }
    }
    
    private func applyCoupon() {
        self.baseView.stopButtonLoader()
        self.baseView.showSuccessPopUp(.couponAdded(couponCode: viewModel.getAppliedCoupon?.couponCode?.first?.couponCode ?? "")) {
            self.syncCart?()
            self.pop()
        }
    }
}
