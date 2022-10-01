//
//  MultipleCarouselVC.swift
//  Kudu
//
//  Created by Admin on 27/09/22.
//

import UIKit
import NVActivityIndicatorView
import AdvancedPageControl

class MultipleCarouselVC: BaseVC {
    @IBOutlet private weak var baseView: MultipleCarouselView!
    let viewModel = MultipleCarouselVM()
    var handleDeallocation: (() -> Void)?
    var addItem: ((MenuItem) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.dismissPopUp = { [weak self] in
            mainThread {
                self?.handleDeallocation?()
            }
        }
//        guard let collectionView = self.baseView.collectionView else { fatalError() }
//        collectionView.isPagingEnabled = true
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.dataSource = self
//        collectionView.collectionViewLayout = flowLayout
//        collectionView.contentInsetAdjustmentBehavior = .always
        viewModel.fetchDetails(completed: { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .success:
//                strongSelf.baseView.pageControl.numberOfPages = strongSelf.viewModel.getItems.count
                  guard let carouselCollectionView = strongSelf.baseView.collectionView else { return }
                mainThread {
                    let pages = self?.viewModel.getItems.count ?? 0
                    debugPrint("Pages passed : \(pages)")
                    self?.baseView.pageControl.numberOfPages = pages
                    
                }
//                let cellWidth: CGFloat = 158//carouselCollectionView.width - 60
//                let cellHeight: CGFloat = 171//carouselCollectionView.height - 20
//                let insetX: CGFloat = 10
//                let insetY: CGFloat = 0
//                let layout = carouselCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
//                layout?.scrollDirection = .horizontal
//                layout?.itemSize = CGSize(width: cellWidth, height: cellHeight)
//                carouselCollectionView.collectionViewLayout = layout ?? UICollectionViewFlowLayout()
//                carouselCollectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
                carouselCollectionView.reloadData()
                strongSelf.baseView.hideLoader()
            case .failure(let error):
                strongSelf.baseView.hideLoader()
                if strongSelf.isShowingToast { return }
                strongSelf.isShowingToast = true
                mainThread {
                    let appError = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: strongSelf.baseView.width - 32, height: 48))
                    appError.show(message: error.localizedDescription, view: strongSelf.baseView, completionBlock: { [weak self] in
                        self?.isShowingToast = false
                        self?.handleDeallocation?()
                    })
                }
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension MultipleCarouselVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 134, height: 171)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.getItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.getItems[indexPath.item]
        self.addItem?(item)
        self.handleDeallocation?()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: ItemCarouselCell.self, indexPath: indexPath)
        cell.addItem = { [weak self] (item) in
            self?.addItem?(item)
            self?.handleDeallocation?()
        }
        cell.configure(viewModel.getItems[indexPath.item])
        return cell
    }
}

extension MultipleCarouselVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collection = baseView.collectionView, let centerIndex = collection.getCurrentIndex() else {
            return
        }
        self.baseView.pageControl.setPage(centerIndex.item)
    }
}

extension UICollectionView {
    func getCurrentIndex() -> IndexPath? {
        let centerPoint = CGPoint(x: self.contentOffset.x + (self.frame.width / 2), y: (self.frame.height / 2))
        return self.indexPathForItem(at: centerPoint)
    }
}
