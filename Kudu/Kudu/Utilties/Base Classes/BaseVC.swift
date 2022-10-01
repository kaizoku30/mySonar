import UIKit
import IQKeyboardManagerSwift
import AVFoundation
import FBSDKLoginKit
import GoogleSignIn

class BaseVC: UIViewController {
    
    var isShowingToast = false
    var safeAreaInsets: (top: CGFloat, bottom: CGFloat) = (0, 0)
    
    func getNavController() -> BaseNavVC? {
        return self.navigationController as? BaseNavVC
    }
    
    func push(vc: BaseVC, animated: Bool = true) {
        self.navigationController?.pushViewController(vc, animated: animated)
    }
    
    func pop(animated: Bool = true) {
        self.navigationController?.popViewController(animated: animated)
    }
    
    @discardableResult
    func popToSpecificViewController(kindOf viewController: UIViewController.Type, animated: Bool = true) -> Bool {
        if self.navigationController.isNil {
            return false }
        
        for vc in self.navigationController!.viewControllers where vc.isKind(of: viewController.classForCoder()) {
            self.navigationController!.popToViewController(vc, animated: animated)
            return true
        }
        return false
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        self.setupToHideKeyboardOnTapOnView()
        self.observeFor(.pushLoginVC, selector: #selector(pushLogin(notification:)))
        self.observeFor(.noConnection, selector: #selector(show404View))
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            let topPadding = window?.safeAreaInsets.top ?? 0
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            safeAreaInsets = (topPadding, bottomPadding)
        }
    }
    
    @objc private func show404View() {
        if DataManager.shared.noInternetViewAdded == false && !self.isKind(of: LaunchVC.self) {
            DataManager.shared.noInternetViewAdded = true
            let vc = NoInternetConnectionVC()
          //  vc.view = NoInternetConnectionView(frame: vc.view.frame)
            self.push(vc: vc)
        }
    }
    
    @objc private func pushLogin(notification: NSNotification) {
        guard let nav = self.navigationController, let loginExists = nav.viewControllers.first(where: { $0.isKind(of: LoginVC.self) }) else {
            
            let msg = notification.userInfo?["msg"] as? String ?? ""
            let loginVC = LoginVC.instantiate(fromAppStoryboard: .Onboarding)
            loginVC.viewModel = LoginVM(delegate: loginVC, flow: .comingFromLoggedInUser, _expiryError: msg)
            let fbLoginManager = LoginManager()
            fbLoginManager.logOut()
            GIDSignIn.sharedInstance.signOut()
            AppUserDefaults.removeValue(forKey: .cart)
            AppUserDefaults.removeValue(forKey: .recentSearchExploreMenu)
            AppUserDefaults.removeValue(forKey: .currentDeliveryAddress)
            AppUserDefaults.removeValue(forKey: .currentCurbsideRestaurant)
            AppUserDefaults.removeValue(forKey: .currentPickupRestaurant)
            AppUserDefaults.removeValue(forKey: .loginResponse)
            AppUserDefaults.removeValue(forKey: .hashIdsForFavourites)
            self.push(vc: loginVC)
            
            return
        }
        
        debugPrint("Login Exists \(loginExists) in stack already, avoid multiple push")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override var shouldAutorotate: Bool {
        false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first, let view = touch.view, view.isKind(of: UITextField.self) || view.isKind(of: UITextView.self) {
        self.view.endEditing(true)
        }
    }
}

extension BaseVC {
    func setupToHideKeyboardOnTapOnView() {
           let tap: UITapGestureRecognizer = UITapGestureRecognizer(
               target: self,
               action: #selector(BaseVC.dismissKeyboard))

           tap.cancelsTouchesInView = false
           view.addGestureRecognizer(tap)
       }

       @objc func dismissKeyboard() {
           view.endEditing(true)
       }
}
