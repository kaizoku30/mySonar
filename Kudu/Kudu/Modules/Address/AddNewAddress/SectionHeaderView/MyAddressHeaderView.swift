//
//  MyAddressHeaderView.swift
//  Kudu
//
//  Created by Admin on 14/07/22.
//

import UIKit

class MyAddressHeaderView: UIView {

    @IBOutlet private var mainContentView: UIView!
    @IBOutlet private weak var label: UILabel!
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
    func setTitle(_ title: String) {
        label.text = title
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MyAddressHeaderView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
