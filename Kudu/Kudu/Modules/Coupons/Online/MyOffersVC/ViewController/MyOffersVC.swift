//
//  MyOffersVC.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import UIKit

enum MyOffersVCType {
    case myoffer
    case promo
}

class MyOffersVC: BaseVC {
    
    @IBOutlet private weak var baseView: MyOffersView!
    
    private let viewModel = MyOffersVM()
    private var isFetchingCoupons = true
    var controllerType: MyOffersVCType = .myoffer
    var indexToLaunchForInStore: Int = -1
    
    @objc private func refreshInStorePromos() {
        if controllerType == .promo {
            self.isFetchingCoupons = true
            self.baseView.refreshTable()
            viewModel.fetchPromo { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.isFetchingCoupons = false
                strongSelf.baseView.refreshTable()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.baseView.refreshTable()
        self.observeFor(.updateOffers, selector: #selector(refreshInStorePromos))
        
        baseView.dismissPressed = { [weak self] in
            self?.pop()
        }
        
        switch controllerType {
        case .myoffer:
            self.baseView.titleLabel.text = LSCollection.MyOfferScreenTtile.offers_and_Deals
            viewModel.fetchCoupons { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.isFetchingCoupons = false
                strongSelf.baseView.refreshTable()
            }
        case .promo:
            self.baseView.titleLabel.text = LSCollection.MyOfferScreenTtile.in_Store_Promos
            viewModel.fetchPromo { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.isFetchingCoupons = false
                strongSelf.baseView.refreshTable()
                if strongSelf.indexToLaunchForInStore != -1 {
                    strongSelf.tabBarController?.addOverlayBlack()
                    strongSelf.openDetail(index: strongSelf.indexToLaunchForInStore)
                }
            }
        }
        
    }
}

extension MyOffersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFetchingCoupons {
            return 5
        } else {
            if viewModel.getCoupons.isEmpty {
                self.baseView.showNoResult()
            }
            return viewModel.getCoupons.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFetchingCoupons {
            let cell = tableView.dequeueCell(with: MyOfferShimmerCell.self)
            cell.configure()
            return cell
        }
        let cell = tableView.dequeueCell(with: MyOffersTableViewCell.self, indexPath: indexPath)
        let object = viewModel.getCoupons[indexPath.row]
        let image = AppUserDefaults.selectedLanguage() == .en ? object.imageEnglish ?? "" : object.imageArabic ?? ""
        cell.configure(img: image)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tabBarController?.addOverlayBlack()
        openDetail(index: indexPath.row)
        
    }
}

extension MyOffersVC {
    func openDetail(index: Int) {
        let vc = CouponDetailPopUpVC.instantiate(fromAppStoryboard: .Coupon)
        vc.redeemTime = self.viewModel.timeForRedemption
        vc.controllerType = self.controllerType
        vc.configureForCustomView()
        vc.viewModel.configure(coupon: viewModel.getCoupons[index])
        vc.dimissPopUp = { [weak self] (coupon) in
            vc.dismiss(animated: true, completion: { [weak self] in
                self?.tabBarController?.removeOverlay()
                let obj = coupon
                if obj.isNotNil {
                    guard let tabBar = self?.tabBarController else { return }
                    let homeTab = tabBar as! HomeTabBarVC
                    homeTab.navigateToUsingCoupon(obj!)
                    self?.tabBarController?.selectedIndex = HomeTabBarVC.TabOptions.menu.rawValue
                }
            })
        }
        present(vc, animated: true)
    }
}
