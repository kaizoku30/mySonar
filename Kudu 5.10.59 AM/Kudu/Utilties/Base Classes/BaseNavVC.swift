import UIKit

enum PushTransition: Int {
    case vertical = 0
    case horizontal
}

class BaseNavVC: UINavigationController, UIGestureRecognizerDelegate {

    var disableSwipeBackGesture = false
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setNavigationBarHidden(true, animated: false)
    }
    
    func popToSpecific(viewcontroller: UIViewController.Type) {
        for vc in self.viewControllers where vc.isKind(of: viewcontroller.classForCoder()) {
            self.popToViewController(vc, animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //NotificationCenter.postNotificationForObservers(.removeDimView)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
           if disableSwipeBackGesture {
            return false
           }
           return viewControllers.count > 1
       }
    
    func push(vc: BaseVC, animated: Bool = true) {
        pushViewController(vc, animated: animated)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)
    }
    
}

extension UINavigationController {
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }}
