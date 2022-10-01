//
//  ExploreMenuView.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import UIKit

class ExploreMenuView: UIView {
	@IBOutlet weak var bottomPaddingButton: NSLayoutConstraint!
	@IBOutlet private weak var filterCollectionView: UICollectionView!
    @IBOutlet private weak var errorToastView: AppErrorToastView!
    @IBOutlet weak var browseMenuButton: AppButton!
    @IBOutlet private weak var tableContainerCollectionView: UICollectionView!
    @IBOutlet private weak var exploreMenuTitleLabel: UILabel!
    @IBAction private func backButtonPressed(_ sender: Any) {
        handleViewActions?(.backButtonPressed)
    }
    @IBAction private func searchButtonPressed(_ sender: Any) {
        handleViewActions?(.searchButtonPressed)
    }
    @IBAction private func browseMenuButtonPressed(_ sender: Any) {
        handleViewActions?(.browseMenuTapped)
    }
	@IBOutlet private weak var topPaddingVerticalCollection: NSLayoutConstraint!
	
	private var showingBrowseMenu = false
    var handleViewActions: ((ViewActions) -> Void)?
    private var scrollMetrics = ExploreMenuScrollMetrics()
    var getScrollMetrics: ExploreMenuScrollMetrics { scrollMetrics }
    
    enum ViewActions {
        case backButtonPressed
        case searchButtonPressed
        case browseMenuTapped
    }
    
    enum CollectionType {
        case filter
        case tables
    }
    
    enum APICalled {
        case itemList
        case itemDetail
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.filterCollectionView.isHidden = true
        self.tableContainerCollectionView.isHidden = true
		self.tableContainerCollectionView.semanticContentAttribute = .forceLeftToRight
		self.filterCollectionView.semanticContentAttribute = .forceLeftToRight
        initialSetup()
        exploreMenuTitleLabel.text = LocalizedStrings.ExploreMenu.exploreMenuTitle
        if AppUserDefaults.selectedLanguage() == .en {
            browseMenuButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        } else {
            browseMenuButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        }
    }
    
    private func initialSetup() {
        filterCollectionView.showsHorizontalScrollIndicator = false
        filterCollectionView.registerCell(with: ExploreMenuCategoryCollectionViewCell.self)
    }
    
    func setup(categories: [MenuCategory], selectedIndex: Int) {
        for i in 0..<categories.count {
                let font = AppFonts.mulishSemiBold.withSize(12)
                let fontAttributes = [NSAttributedString.Key.font: font]
                let item = categories[i]
                let text = AppUserDefaults.selectedLanguage() == .en ? item.titleEnglish ?? "" : item.titleArabic ?? ""
                let size = (text as NSString).size(withAttributes: fontAttributes)
                var itemSpecificWidth = size.width + 32
                if itemSpecificWidth < (48 + 32) {
                    itemSpecificWidth = 48 + 32
                }
                self.scrollMetrics.itemSpecificWidthArray.append(itemSpecificWidth)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            self.filterSelected(index: selectedIndex)
        })
    }
    
    func checkCollection(_ collectionView: UICollectionView) -> ExploreMenuView.CollectionType {
        if collectionView == tableContainerCollectionView { return .tables }
        return .filter
    }
    
    func synchronizeScrollView(scrollView: UIScrollView) {
        // Need to time to implement for complex views where one view's cellSize will be different than the other, hence varying speed of scrolling between two views
    }
    
    func scrolViewWillBeginDragging(scrollView: UIScrollView) {
        self.scrollMetrics.scrolling = true
    }
    
    func refreshTableViews(indexPath: IndexPath) {
        UIView.setAnimationsEnabled(false)
        self.tableContainerCollectionView.reloadItems(at: [indexPath])
        UIView.setAnimationsEnabled(true)
    }
    
    func scrollViewWillEndDeaccelerating(scrollView: UIScrollView) {
        self.scrollMetrics.previousPage = self.scrollMetrics.currentPage
        self.scrollMetrics.currentPage = Int(scrollView.contentOffset.x/self.width)
        self.scrollMetrics.scrolling = false
        UIView.setAnimationsEnabled(false)
        self.filterCollectionView.reloadItems(at: [IndexPath(item: self.scrollMetrics.previousPage, section: 0), IndexPath(item: self.scrollMetrics.currentPage, section: 0)])
        UIView.setAnimationsEnabled(true)
        self.filterCollectionView.scrollToItem(at: IndexPath(item: self.scrollMetrics.currentPage, section: 0), at: .centeredHorizontally, animated: true)
		self.scrollBrowseMenu(show: false)
    }
    
    func filterSelected(index: Int) {
        self.scrollMetrics.previousPage = self.scrollMetrics.currentPage
        self.scrollMetrics.currentPage = index
        UIView.setAnimationsEnabled(false)
        self.filterCollectionView.reloadItems(at: [IndexPath(item: self.scrollMetrics.previousPage, section: 0), IndexPath(item: self.scrollMetrics.currentPage, section: 0)])
        self.tableContainerCollectionView.reloadItems(at: [IndexPath(item: self.scrollMetrics.previousPage, section: 0), IndexPath(item: self.scrollMetrics.currentPage, section: 0)])
        UIView.setAnimationsEnabled(true)
        self.filterCollectionView.scrollToItem(at: IndexPath(item: self.scrollMetrics.currentPage, section: 0), at: .centeredHorizontally, animated: true)
        self.tableContainerCollectionView.scrollToItem(at: IndexPath(item: self.scrollMetrics.currentPage, section: 0), at: .centeredHorizontally, animated: true)
        
        if self.tableContainerCollectionView.isHidden == true {
            self.tableContainerCollectionView.isHidden = false
            self.filterCollectionView.isHidden = false
        }
		if self.scrollMetrics.previousPage != self.scrollMetrics.currentPage {
			self.scrollBrowseMenu(show: false)
		}
    }
	
	func scrollBrowseMenu(show: Bool) {
		if showingBrowseMenu == false && show == true || show == false && showingBrowseMenu == true {
			showingBrowseMenu = show
			UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: {
				self.bottomPaddingButton.constant = show ? 10 : -80
				self.topPaddingVerticalCollection.constant = show ? 0 : 89
				self.layoutIfNeeded()
				self.tableContainerCollectionView.reloadData()
			})
		}
	}
}

extension ExploreMenuView {
    func handleAPIRequest(_ api: APICalled, reloadIndexPath: IndexPath?) {
        mainThread {
            switch api {
            case .itemList:
                guard let reloadIndexPath = reloadIndexPath else {
                    return
                }
                UIView.setAnimationsEnabled(false)
                self.tableContainerCollectionView.reloadItems(at: [reloadIndexPath])
                UIView.setAnimationsEnabled(true)
            case .itemDetail:
                self.tableContainerCollectionView.isUserInteractionEnabled = false
            }
        }
    }
    
    func handleAPIResponse( _ api: APICalled, isSuccess: Bool, errorMsg: String?, reloadIndexPath: IndexPath) {
        mainThread {
            if !isSuccess {
                let toast = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.width - 32, height: 48))
                toast.show(message: errorMsg ?? "", view: self)
            }
            UIView.setAnimationsEnabled(false)
            self.tableContainerCollectionView.reloadItems(at: [reloadIndexPath])
            UIView.setAnimationsEnabled(true)
            self.tableContainerCollectionView.isUserInteractionEnabled = true
        }
    }
}

struct ExploreMenuScrollMetrics {
    var previousPage: Int = 0
    var currentPage: Int = 0
    var scrolling: Bool = false
    var itemSpecificWidthArray: [CGFloat] = []
}
