import Foundation
import UIKit
import AssetsLibrary
import AVFoundation
import Photos
import MobileCoreServices

//extension NSLayoutConstraint {
//
//    override public var description: String {
//        let id = identifier ?? ""
//        return id
//       // return "id: \(id), constant: \(constant), firstItem : \(self.firstItem.debugDescription) second item : \(self.secondItem.debugDescription))" //you may print whatever you want here
//    }
//}

extension UIViewController {
    func configureForCustomView() {
        hidesBottomBarWhenPushed = true
        modalPresentationStyle = .overFullScreen
    }
}

extension UIViewController {
    
    //UIViewController extension for Image picker
    typealias ImagePickerDelegateController = (UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate)
    
    ///Adds Child View Controller to Parent View Controller
    func add(childViewController: UIViewController, containerView: UIView? = nil) {
        let mainView: UIView = containerView ?? self.view
        self.addChild(childViewController)
        childViewController.view.frame = mainView.bounds
        mainView.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }
    
    ///Removes Child View Controller From Parent View Controller
    var removeFromParent: Void {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    ///Updates navigation bar according to given values
    func updateNavigationBar(withTitle title: String? = nil, leftButton: [UIBarButtonItem]? = nil, rightButtons: [UIBarButtonItem]? = nil, tintColor: UIColor? = nil, barTintColor: UIColor? = nil, titleTextAttributes: [NSAttributedString.Key: Any]? = nil) {
        self.navigationController?.isNavigationBarHidden = false
        if let tColor = barTintColor {
            self.navigationController?.navigationBar.barTintColor = tColor
        }
        if let tColor = tintColor {
            self.navigationController?.navigationBar.tintColor = tColor
        }
        if let button = leftButton {
            self.navigationItem.leftBarButtonItems = button
        }
        if let rightBtns = rightButtons {
            self.navigationItem.rightBarButtonItems = rightBtns
        }
        if let ttle = title {
            self.title = ttle
        }
        if let ttleTextAttributes = titleTextAttributes {
            self.navigationController?.navigationBar.titleTextAttributes =   ttleTextAttributes
        }
    }
}
