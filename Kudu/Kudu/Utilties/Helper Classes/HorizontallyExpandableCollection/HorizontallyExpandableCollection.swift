//
//  HorizontallyExpandableCollectionView.swift
//  ExpandableHorizontalCollectionProject
//
//  Created by Admin on 12/08/22.
//

import UIKit

class HorizontallyExpandableCollection: UIView {

    @IBOutlet private var mainContentView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var expandCollectionButton: UIButton!
    @IBOutlet private weak var collapseCollectionButton: UIButton!
    
    @IBAction private func expandCollectionPressed(_ sender: Any) {
        expanded = !expanded
		self.expandCollectionButton.setImage(expanded ? leftArrow : rightArrow, for: .normal)
        self.collectionView.reloadData()
    }
    @IBAction private func collapseCollectionPressed(_ sender: Any) {
        expanded = false
        collapseCollectionButton.isHidden = true
        expandCollectionButton.isHidden = false
        self.collectionView.reloadData()
    }
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
    private var expanded = false { didSet {
        self.allergenToggled?(self.expanded)
        mainThread {
			var calculatedWidth = self.expanded ? self.totalHorizontalWidth : CGFloat(self.allergenArray.count * 36)
            let widthReference = self.containerWidth.isNil ? self.width : self.containerWidth!
            if calculatedWidth > (widthReference - 48) {
                calculatedWidth = widthReference - 48
            }
            //calculatedWidth = self.expanded ? (widthReference - 48) : calculatedWidth
            self.collectionWidthConstraint.constant = calculatedWidth
            self.layoutIfNeeded()
        }
    }}
    private var allergenArray: [AllergicComponent] = []
    private var containerWidth: CGFloat?
	private var totalHorizontalWidth: CGFloat = 0
    var allergenToggled: ((Bool) -> Void)?
	private let leftArrow = UIImage(named: "k_allergenCollection_showShort")!
	private let rightArrow = UIImage(named: "k_allergenCollection_showLong")!
    private func commonInit() {
      Bundle.main.loadNibNamed("HorizontallyExpandableCollection", owner: self, options: nil)
      addSubview(mainContentView)
      mainContentView.frame = self.bounds
      mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "HorizontallyExpandableCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HorizontallyExpandableCollectionViewCell")
    }
    
    func configure(allergenArray: [AllergicComponent], expandedState: Bool? = nil, containerWidth: CGFloat? = nil) {
        self.allergenArray = allergenArray
        self.containerWidth = containerWidth
        var calculatedWidth = CGFloat(allergenArray.count * 36)
        let widthReference = containerWidth.isNil ? self.width : self.containerWidth!
        if calculatedWidth > (widthReference - 48) {
            calculatedWidth = widthReference - 48
        }
        if let expandedState = expandedState {
            self.expanded = expandedState
        }
        self.collectionWidthConstraint.constant = calculatedWidth
        self.layoutIfNeeded()
        self.collectionView.reloadData()
		for i in 0..<allergenArray.count {
			let font = AppFonts.mulishRegular.withSize(10)
			let fontAttributes = [NSAttributedString.Key.font: font]
			let text = AppUserDefaults.selectedLanguage() == .en ? allergenArray[i].name ?? "" : allergenArray[i].nameArabic ?? ""
			let size = (text as NSString).size(withAttributes: fontAttributes)
			totalHorizontalWidth += size.width + 20 + 24
		}
    }
}

extension HorizontallyExpandableCollection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if expanded == true, indexPath.row < allergenArray.count {
            let font = AppFonts.mulishRegular.withSize(10)
            let fontAttributes = [NSAttributedString.Key.font: font]
            let text = AppUserDefaults.selectedLanguage() == .en ? allergenArray[indexPath.row].name ?? "" : allergenArray[indexPath.row].nameArabic ?? ""
            let size = (text as NSString).size(withAttributes: fontAttributes)
            return CGSize(width: size.width + 20 + 24, height: 24)
        }
        return CGSize(width: 24, height: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allergenArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontallyExpandableCollectionViewCell", for: indexPath) as! HorizontallyExpandableCollectionViewCell
        let title = AppUserDefaults.selectedLanguage() == .en ? (allergenArray[indexPath.row].name ?? "") : (allergenArray[indexPath.row].nameArabic ?? "")
        cell.configure(expand: expanded, text: title, image: allergenArray[indexPath.row].imageUrl ?? "")
        return cell
    }
}
