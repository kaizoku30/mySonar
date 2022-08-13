//
//  TwitterWebVC.swift
//  Kudu
//
//  Created by Admin on 23/05/22.
//

import WebKit
import UIKit

class TwitterWebVC: BaseVC, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    var url: URL!
    
    override func viewDidLoad() {
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15"
        webView.configuration.preferences.javaScriptEnabled = true
        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
                   decisionHandler(.allow)
                   return
               }
               debugPrint("URL CHANGE : \(url.absoluteString)")
        
        if url.absoluteString.contains("error") {
            let alert = UIAlertController(title: "Incorrect Credentials", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
            decisionHandler(.cancel)
            return
        }
        
        if url.absoluteString.contains("twittersdk") {
                   // this means login successful
                   // If the schemes match, we will include the URL in a the object of the notification and Post
        let notification = Notification(name: Notification.Name.init(rawValue: Constants.NotificationObservers.twitterCallBack.rawValue), object: url, userInfo: nil)
                   NotificationCenter.default.post(notification)
                   decisionHandler(.cancel)
                   self.dismiss(animated: true, completion: nil)
               } else {
                   decisionHandler(.allow)
               }
    }
}
