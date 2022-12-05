//
//  HomeTabBarVC+Ext.swift
//  Kudu
//
//  Created by Admin on 03/11/22.
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

extension HomeTabBarVC {
    func addShadowToTabBar() {
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
