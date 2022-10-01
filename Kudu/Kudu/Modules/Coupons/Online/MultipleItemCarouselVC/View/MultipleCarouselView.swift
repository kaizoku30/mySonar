//
//  MultipleCarouselView.swift
//  Kudu
//
//  Created by Admin on 27/09/22.
//

import UIKit
import NVActivityIndicatorView
import AdvancedPageControl

class MultipleCarouselView: UIView {
    
    @IBOutlet weak var pageControl: AdvancedPageControlView!
    @IBOutlet private weak var tapGestureView: UIView!
    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var loader: NVActivityIndicatorView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dismissPopUp: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bringSubviewToFront(loaderView)
        loader.startAnimating()
        pageControl.drawer = ExtendedDotDrawer(numberOfPages: 0, height: 8, width: 8, space: 4, raduis: 4, currentItem: 0, indicatorColor: UIColor(r: 244, g: 224, b: 177, alpha: 1), dotsColor: UIColor(r: 252, g: 242, b: 219, alpha: 1), isBordered: false, borderColor: .clear, borderWidth: 0, indicatorBorderColor: .clear, indicatorBorderWidth: 0)
      //  tapGestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlayTapped)))
    }
    
    @objc private func overlayTapped() {
        self.dismissPopUp?()
    }
    
    func hideLoader() {
        mainThread {
            self.loader.stopAnimating()
            self.collectionView.reloadData()
            self.loaderView.isHidden = true
            self.sendSubviewToBack(self.loaderView)
        }
    }

}


