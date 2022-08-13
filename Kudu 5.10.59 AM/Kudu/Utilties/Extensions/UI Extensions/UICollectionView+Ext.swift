import Foundation
import UIKit

// MARK: - UICollectionView Extension
extension UICollectionView {

    ///Returns cell for the given item
    func cell(forItem item: AnyObject) -> UICollectionViewCell? {
        if let indexPath = self.indexPath(forItem: item) {
            return self.cellForItem(at: indexPath)
        }
        return nil
    }

    ///Returns the indexpath for the given item
    func indexPath(forItem item: AnyObject) -> IndexPath? {
        let buttonPosition: CGPoint = item.convert(CGPoint.zero, to: self)
        return self.indexPathForItem(at: buttonPosition)
    }

    ///Registers the given cell
    func registerClass(cellType: UICollectionViewCell.Type) {
        register(cellType, forCellWithReuseIdentifier: cellType.defaultReuseIdentifier)
    }

    ///dequeues a reusable cell for the given indexpath
    func dequeueReusableCellForIndexPath<T: UICollectionViewCell>(indexPath: NSIndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath as IndexPath) as? T else {
            fatalError( "Failed to dequeue a cell with identifier \(T.defaultReuseIdentifier).  Ensure you have registered the cell" )
        }

        return cell
    }

    ///Register Collection View Cell Nib
    func registerCell(with identifier: UICollectionViewCell.Type) {
        self.register(UINib(nibName: "\(identifier.self)", bundle: nil), forCellWithReuseIdentifier: "\(identifier.self)")
    }
    
    ///Register Collection View Cell Nib
    func registerReusableView(with identifier: UICollectionReusableView.Type, isHeader: Bool ) {
        let forSupplementaryViewOfKind: String = isHeader ? UICollectionView.elementKindSectionHeader : UICollectionView.elementKindSectionFooter
        self.register(UINib(nibName: "\(identifier.self)", bundle: nil), forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: "\(identifier.self)")
    }
    
    ///Dequeue Collection View Cell
    func dequeueCell <T: UICollectionViewCell> (with identifier: T.Type, indexPath: IndexPath) -> T {
        weak var weakSelf = self
        return weakSelf?.dequeueReusableCell(withReuseIdentifier: "\(identifier.self)", for: indexPath) as! T
    }
    
    func dequeueReusableView<T: UICollectionReusableView> (with identifier: T.Type, indexPath: IndexPath, isHeader: Bool) -> T {
        let forSupplementaryViewOfKind: String = isHeader ? UICollectionView.elementKindSectionHeader : UICollectionView.elementKindSectionFooter
        return self.dequeueReusableSupplementaryView(ofKind: forSupplementaryViewOfKind, withReuseIdentifier: "\(identifier.self)", for: indexPath) as! T
    }
    
    func reloadItemsWithoutAnimation(indexPaths: [IndexPath]) {
        UIView.performWithoutAnimation {
            self.reloadItems(at: indexPaths)
        }
    }
    
    /// Calculates the current centered page.
    public var currentCenteredPage: Int? {
        let currentCenteredPoint = CGPoint(x: self.contentOffset.x + self.bounds.width/2, y: self.contentOffset.y + self.bounds.height/2)
        
        return self.indexPathForItem(at: currentCenteredPoint)?.row
    }
}

extension UICollectionViewCell {
    public static var defaultReuseIdentifier: String {
        return "\(self)"
    }
}

extension UICollectionView {
    
    /// This returns the last indexpath of the tableview.
    func lastIndexpath() -> IndexPath {
        let section = max(numberOfSections - 1, 0)
        let row = max(numberOfItems(inSection: section) - 1, 0)
        return IndexPath(row: row, section: section)
    }
}

extension UICollectionView {
    func currentCustomHeaderView(with tag: Int) -> UIView? {
        return self.viewWithTag(tag)
    }
    
    func asssignCustomHeaderView(headerView: UIView, sideMarginInsets: CGFloat = 0, tag: Int) {
        guard self.viewWithTag(tag) == nil else {
            return
        }
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerView.frame = CGRect(x: sideMarginInsets, y: -height + self.contentInset.top, width: self.frame.width - (2 * sideMarginInsets), height: height)
        headerView.tag = tag
        self.addSubview(headerView)
        self.contentInset = UIEdgeInsets(top: height, left: self.contentInset.left, bottom: self.contentInset.bottom, right: self.contentInset.right)
    }
    
    func removeCustomHeaderView(with tag: Int) {
        if let customHeaderView = self.viewWithTag(tag) {
            let headerHeight = customHeaderView.frame.height
            customHeaderView.removeFromSuperview()
            self.contentInset = UIEdgeInsets(top: self.contentInset.top - headerHeight, left: self.contentInset.left, bottom: self.contentInset.bottom, right: self.contentInset.right)
        }
    }
}
