 //
//  WebViewController.swift
//  FeedMyRSS
//
//  Created by Johannes Ebeling on 02.02.17.
//  Copyright © 2017 Johannes Ebeling. All rights reserved.
//
import UIKit
import Foundation

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var link: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: URL(string: link!)!)
        webView.loadRequest(request)
    }
}
