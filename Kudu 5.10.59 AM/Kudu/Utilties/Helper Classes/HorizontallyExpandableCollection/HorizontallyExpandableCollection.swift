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
        expanded = true
        expandCollectionButton.isHidden = true
        collapseCollectionButton.isHidden = false
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
        mainThread {
            var calculatedWidth = CGFloat(self.allergenArray.count * 36)
            if calculatedWidth > (self.width - 48) {
                calculatedWidth = self.width - 48
            }
            calculatedWidth = self.expanded ? (self.width - 48) : calculatedWidth
            self.collectionWidthConstraint.constant = calculatedWidth
            self.layoutIfNeeded()
        }
    }}
    private var allergenArray: [AllergicComponent] = []
    
    private func commonInit() {
      Bundle.main.loadNibNamed("HorizontallyExpandableCollection", owner: self, options: nil)
      addSubview(mainContentView)
      mainContentView.frame = self.bounds
      mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "HorizontallyExpandableCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HorizontallyExpandableCollectionViewCell")
    }
    
    func configure(allergenArray: [AllergicComponent]) {
        self.allergenArray = allergenArray
        var calculatedWidth = CGFloat(allergenArray.count * 36)
        if calculatedWidth > (self.width - 48) {
            calculatedWidth = self.width - 48
        }
        self.collectionWidthConstraint.constant = calculatedWidth
        self.layoutIfNeeded()
        self.collectionView.reloadData()
    }
}

extension HorizontallyExpandableCollection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if expanded == true, indexPath.row < allergenArray.count {
            let font = AppFonts.mulishRegular.withSize(10)
            let fontAttributes = [NSAttributedString.Key.font: font]
            let text = allergenArray[indexPath.row].name ?? ""
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
        cell.configure(expand: expanded, text: allergenArray[indexPath.row].name ?? "", image: allergenArray[indexPath.row].imageUrl ?? "")
        return cell
    }
}
