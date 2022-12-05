//
//  HomeTabBarVC.swift
//  Kudu
//
//  Created by Admin on 22/09/22.
//

import UIKit

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
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        weak var weakSelf = self.navigationController as? BaseNavVC
        weakSelf?.disableSwipeBackGesture = true
        intialSetup()
        setupVCs()
        removeOtherViewControllers()
        self.observeFor(.goToNotifications, selector: #selector(goToNotifications))
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shadowAdded { return }
        shadowAdded = true
        addShadowToTabBar()
    }
}

extension HomeTabBarVC {
    
    // MARK: Initial Setup
    private func intialSetup() {
        view.backgroundColor = .systemBackground
        UITabBar.appearance().barTintColor = .systemBackground
        tabBar.tintColor = AppColors.kuduThemeYellow
        tabBar.unselectedItemTintColor = AppColors.tabBarUnselectedColor
    }
    
    private func setupVCs() {
        homeVC = HomeVC.instantiate(fromAppStoryboard: .Home)
        homeVC.viewModel = HomeVM(delegate: homeVC)
        let homeTab: UITabBarItem = UITabBarItem(title: LSCollection.AddNewAddress.home, image: AppImages.TabBar.homeUnselected, selectedImage: AppImages.TabBar.homeSelected)
        homeVC.tabBarItem = homeTab
        menuVC = ExploreMenuV2VC.instantiate(fromAppStoryboard: .Home)
        menuVC.viewModel = ExploreMenuV2VM(categories: [], storeId: DataManager.shared.currentStoreId, serviceType: DataManager.shared.currentServiceType)
        let exploreTab: UITabBarItem = UITabBarItem(title: LSCollection.Profile.menu, image: AppImages.TabBar.menuUnselected, selectedImage: AppImages.TabBar.menuSelected)
        menuVC.tabBarItem = exploreTab
        ourStoreVC = OurStoreVC.instantiate(fromAppStoryboard: .Home)
        let ourStoreTab: UITabBarItem = UITabBarItem(title: LSCollection.Profile.ourStore, image: AppImages.TabBar.ourStoreUnSelected, selectedImage: AppImages.TabBar.ourStoreSelected)
        ourStoreVC.tabBarItem = ourStoreTab
        ourStoreVC.viewModel = OurStoreVM(delegate: ourStoreVC)
        var vcAccount: AccountProfileVC!
        if DataManager.shared.isUserLoggedIn {
            vcAccount = ProfileVC.instantiate(fromAppStoryboard: .Home)
        } else {
            vcAccount = GuestProfileVC.instantiate(fromAppStoryboard: .Home)
        }
        accountVC = vcAccount
        let accountTab: UITabBarItem = UITabBarItem(title: LSCollection.TabBar.accountTabTitle, image: AppImages.TabBar.profileUnselected, selectedImage: AppImages.TabBar.profileSelected)
        accountVC.tabBarItem = accountTab
        viewControllers = [
            createNav(homeVC, type: .home),
            createNav(menuVC, type: .menu),
            createNav(ourStoreVC, type: .ourStore),
            createNav(accountVC, type: .account)
        ]
        if DataManager.shared.isLaunchedFromNotification {
            DataManager.shared.setLaunchedFromNotification(false)
            goToNotifications()
        }
    }
}

extension HomeTabBarVC {
    
    // MARK: View Hierarchy Setup
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
    
    private func createNav(_ rootViewController: BaseVC, type: HomeTabBarVC.TabOptions) -> BaseNavVC {
        let navController = BaseNavVC(rootViewController: rootViewController)
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = ""
        switch type {
        case .home:
            Router.shared.homeNav = navController
        case .menu:
            Router.shared.menuNav = navController
        case .ourStore:
            Router.shared.ourStoreNav = navController
        case .account:
            Router.shared.accountNav = navController
        }
        return navController
    }
}

extension HomeTabBarVC {
    
    // MARK: Navigation/Routing
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
    
    func navigateForGuest(itemId: String, menuId: String) {
        self.selectedIndex = TabOptions.menu.rawValue
        menuVC.updateItemLookUp(itemId: itemId, itemIdAssociatedMenuId: menuId, guestUserFlow: true)
    }
    
    @objc private func goToNotifications() {
        mainThread {
            if DataManager.shared.isUserLoggedIn {
                self.selectedIndex = 0
                self.homeVC.goToNotifications()
            }
        }
    }
}
