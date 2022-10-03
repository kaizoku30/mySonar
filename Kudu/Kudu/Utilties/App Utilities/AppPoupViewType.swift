//
//  AppPoupViewType.swift
//  Kudu
//
//  Created by Admin on 03/10/22.
//

import UIKit

class AppPopUpViewType: UIView {
    weak var containerView: UIView?
    
    func removeSelf() {
        self.containerView?.subviews.forEach({
            if $0.tag == Constants.CustomViewTags.alertTag {
                $0.removeFromSuperview()
            }
        })
        self.containerView?.subviews.forEach({
            if $0.tag == Constants.CustomViewTags.dimViewTag {
                $0.removeFromSuperview()
            }
        })
    }
}
