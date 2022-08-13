//
//  WebViewVC.swift
//  Kudu
//
//  Created by Admin on 19/07/22.
//

import UIKit
import WebKit

class WebViewVC: BaseVC {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet weak var pageTitle: UILabel!
    
    // MARK: - IBActions
    @IBAction func backButtonPressed(_ sender: Any) {
        self.pop()
    }
    
    var pageType: Constants.StaticContentType = .aboutUs
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.pageTitle.text = pageType.title
    }
    
    private func load() {
        self.webView.load(URLRequest(url: self.pageType.url))
    }
}
