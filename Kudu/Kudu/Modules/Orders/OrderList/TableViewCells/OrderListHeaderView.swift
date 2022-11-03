//
//  OrderListHeaderView.swift
//  Kudu
//
//  Created by Admin on 10/10/22.
//

import UIKit

class OrderListHeaderView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var mainContentView: UIView!
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("OrderListHeaderView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
