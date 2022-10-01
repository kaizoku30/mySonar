//
//  MyOffersVC.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import UIKit

class MyOffersVC: BaseVC {
    @IBOutlet private weak var baseView: MyOffersView!
    private let viewModel = MyOffersVM()
    private var isFetchingCoupons = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.dismissPressed = { [weak self] in
            self?.pop()
        }
        viewModel.fetchCoupons { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.isFetchingCoupons = false
            strongSelf.baseView.refreshTable()
        }
    }
}
extension MyOffersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFetchingCoupons {
            return 5
        } else {
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
        let vc = CouponDetailPopUpVC.instantiate(fromAppStoryboard: .Coupon)
        vc.configureForCustomView()
        vc.viewModel.configure(coupon: viewModel.getCoupons[indexPath.row])
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
