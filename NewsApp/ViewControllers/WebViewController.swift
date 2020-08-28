//
//  WebViewController.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/28/20.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    let webViewURL: String?
    
    
    fileprivate lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate =  self
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()
    
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    convenience init() {
        self.init(webViewURL: nil)
    }
    
    
    init(webViewURL: String?) {
        self.webViewURL = webViewURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        webView.navigationDelegate = self
        
        view = webView
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        activityIndicator.startAnimating()
        if let webViewURL = webViewURL {
            let url = URL(string: webViewURL)!
            webView.load(URLRequest(url: url))
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}
