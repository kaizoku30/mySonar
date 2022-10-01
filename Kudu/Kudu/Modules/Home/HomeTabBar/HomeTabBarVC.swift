//
//  HomeTabBarVC.swift
//  Kudu
//
//  Created by Admin on 22/09/22.
//

import UIKit

extension UITabBarController {
    func addOverlayBlack() {
        let dimmedView = UIView(frame: view.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        view.addSubview(dimmedView)
    }
    
    func removeOverlay() {
        self.view?.subviews.forEach({
            if $0.tag == Constants.CustomViewTags.dimViewTag {
                $0.removeFromSuperview()
            }
        })
    }
    
    func removeLoaderOverlay() {
        let overlay = self.view?.subviews.first(where: { $0.tag == Constants.CustomViewTags.detailOverlay })
        overlay?.removeFromSuperview()
    }
    
    func addLoaderOverlay() {
        self.view.addSubview(LoadingDetailOverlay.create(withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), atCenter: self.view.center))
    }
}

class HomeTabBarVC: BaseTabBarVC, UITabBarControllerDelegate {
    
    private var shadowAdded = false
    private var homeVC: HomeVC!
    private var menuVC: ExploreMenuV2VC!
    private var ourStoreVC: OurStoreVC!
    private var accountVC: AccountProfileVC!
    
    enum TabOptions: Int {
        case home = 0
        case menu
        case ourStore
        case account
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        UITabBar.appearance().barTintColor = .systemBackground
        tabBar.tintColor = AppColors.kuduThemeYellow
        tabBar.unselectedItemTintColor = AppColors.tabBarUnselectedColor
        setupVCs()
        removeOtherViewControllers()
        // Do any additional setup after loading the view.
    }
    
    private func removeOtherViewControllers() {
        guard let vcInNav = self.navigationController?.viewControllers else { return }
        var viewControllerToRemove: [Int] = []
        for i in 0..<vcInNav.count {
            if vcInNav[i].isKind(of: HomeTabBarVC.self) == false {
                viewControllerToRemove.append(i)
            }
        }
        viewControllerToRemove.forEach({
            debugPrint("Removed a VC from Stack")
            self.navigationController?.viewControllers.remove(at: $0)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shadowAdded { return }
        shadowAdded = true
        addShadowToTabBar()
    }
    
    func setupVCs() {
        homeVC = HomeVC.instantiate(fromAppStoryboard: .Home)
        homeVC.viewModel = HomeVM(delegate: homeVC)
        let homeTab: UITabBarItem = UITabBarItem(title: "Home", image: AppImages.TabBar.homeUnselected, selectedImage: AppImages.TabBar.homeSelected)
        homeVC.tabBarItem = homeTab
        menuVC = ExploreMenuV2VC.instantiate(fromAppStoryboard: .Home)
        menuVC.viewModel = ExploreMenuV2VM(categories: [], storeId: DataManager.shared.currentStoreId, serviceType: DataManager.shared.currentServiceType)
        let exploreTab: UITabBarItem = UITabBarItem(title: "Menu", image: AppImages.TabBar.menuUnselected, selectedImage: AppImages.TabBar.menuSelected)
        menuVC.tabBarItem = exploreTab
        ourStoreVC = OurStoreVC.instantiate(fromAppStoryboard: .Home)
        let ourStoreTab: UITabBarItem = UITabBarItem(title: "Our Store", image: AppImages.TabBar.ourStoreUnSelected, selectedImage: AppImages.TabBar.ourStoreSelected)
        ourStoreVC.tabBarItem = ourStoreTab
        ourStoreVC.viewModel = OurStoreVM(delegate: ourStoreVC)
        var vcAccount: AccountProfileVC!
        if AppUserDefaults.value(forKey: .loginResponse).isNotNil {
            vcAccount = ProfileVC.instantiate(fromAppStoryboard: .Home)
        } else {
            vcAccount = GuestProfileVC.instantiate(fromAppStoryboard: .Home)
        }
        accountVC = vcAccount
        let accountTab: UITabBarItem = UITabBarItem(title: "Account", image: AppImages.TabBar.profileUnselected, selectedImage: AppImages.TabBar.profileSelected)
        accountVC.tabBarItem = accountTab
        viewControllers = [
            createNav(homeVC),
            createNav(menuVC),
            createNav(ourStoreVC),
            createNav(accountVC)
        ]
    }
}

extension HomeTabBarVC {
    private func createNav(_ rootViewController: BaseVC) -> BaseNavVC {
        let navController = BaseNavVC(rootViewController: rootViewController)
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = ""
        return navController
    }
}

extension HomeTabBarVC {
    func updateMenuIndex(_ index: Int?) {
        menuVC.updateQueueScrollIndex(index)
    }
    
    func navigateToUsingCoupon(_ obj: CouponObject) {
        guard let navigationData = obj.promoData?.navigationTo?.first else { return }
        let navigateToMenu = navigationData.isCategory ?? false
        if navigateToMenu {
            menuVC.updateMenuLookUp(menuId: navigationData.id ?? "")
        } else {
            //Navigation to item
            menuVC.updateItemLookUp(itemId: navigationData.id ?? "", itemIdAssociatedMenuId: navigationData.menuId ?? "")
        }
    }
    
    func navigateToUsingBanner(_ obj: BannerItem, categoryFlow: Bool) {
        if categoryFlow {
            menuVC.updateMenuLookUp(menuId: obj.categoryId ?? "")
        } else {
            menuVC.updateItemLookUp(itemId: obj.itemId ?? "", itemIdAssociatedMenuId: obj.categoryId ?? "")
        }
    }
}

extension HomeTabBarVC {
    private func addShadowToTabBar() {
        let tabGradientView = UIView(frame: tabBar.bounds)
        tabGradientView.backgroundColor = UIColor.white
        tabGradientView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(tabGradientView)
        tabBar.sendSubviewToBack(tabGradientView)
        tabGradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tabGradientView.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabGradientView.layer.shadowRadius = 8
        tabGradientView.layer.shadowColor = UIColor.black.cgColor
        tabGradientView.layer.shadowOpacity = 0.12
        tabBar.clipsToBounds = false
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
    }
}
