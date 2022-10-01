//
//  RTPaginationTableView.swift
//
//  Created by Ronit Tushir on 27/01/22.
//

import UIKit

struct RTPaginationConfig {
    var id = 0
    var limit = 10
    var currentPage = 1
    var lastAPIResponseCount = 0
    var contentLoading: Bool = false
    var refreshLoaderColor: UIColor = .black
}

class RTPaginationTableView: UITableView {

    private var paginationSetup = false
    private weak var vcDelegate: UITableViewDelegate?
    private var configs: [RTPaginationConfig] = []
    var isLoadingContent: Bool {
        if currentConfigID < configs.count {
            return configs[currentConfigID].contentLoading
        }
        return false
         }
    private var currentConfigID = 0
    var hitPaginationAPI: ((Int) -> Void)?
    var currentConfig: Int {
            currentConfigID
    }
    
    func configurePagination(inVC vc: UITableViewDelegate, pageConfigs: [RTPaginationConfig]) {
        if pageConfigs.count == 0 {
            return }
        configs = pageConfigs
        if !paginationSetup {
            self.showsVerticalScrollIndicator = false
            self.separatorStyle = .none
            self.delegate = self
            self.bounces = true
            vcDelegate = vc
        }
        self.register(UINib(nibName: "RTLoadingCell", bundle: nil), forCellReuseIdentifier: "RTLoadingCell")
    }
    
    func switchConfig(_ index: Int) {
        if index < configs.count {
            currentConfigID = index
        }
    }
    
    func reloadContent(addedItemsCount: Int, updatedPageNo: Int? = nil, configID: Int) {
        if configID < configs.count {
            configs[configID].lastAPIResponseCount = addedItemsCount
            configs[configID].contentLoading = false
            if updatedPageNo != nil {
                configs[configID].currentPage = updatedPageNo!
            }
            
        }
        if configID == currentConfigID {
            reloadData()
        }
        
    }
}

extension RTPaginationTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        vcDelegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        vcDelegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return vcDelegate?.tableView?(tableView, heightForRowAt: indexPath) ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vcDelegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        vcDelegate?.tableView?(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if currentConfigID < configs.count {
            self.refreshControl?.tintColor = configs[currentConfigID].refreshLoaderColor
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrolling(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        handleScrolling(scrollView)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        handleScrolling(scrollView)
    }
    
    private func handleScrolling(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height && checkConfigWhileScrolling() {
            
                configs[currentConfigID].contentLoading = true
                self.reloadData()
                let point = CGPoint(x: 0, y: self.contentSize.height + self.contentInset.bottom - self.frame.height)
                        if point.y >= 0 {
                            self.setContentOffset(point, animated: false)
                        }
                hitPaginationAPI?(configs[currentConfigID].currentPage + 1)
        }
    }
    
    private func checkConfigWhileScrolling() -> Bool {
        if configs[currentConfigID].lastAPIResponseCount == configs[currentConfigID].limit && !configs[currentConfigID].contentLoading {
            return true
        } else {
            return false
        }
    }
}

extension UITableView {
    func reloadAndScroll(to indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0, animations: {
                self.reloadData()
             }, completion: { _ in
                 self.scrollToRow(at: indexPath, at: .top, animated: true)
             })
      }
    
}
