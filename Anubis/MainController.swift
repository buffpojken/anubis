//
//  MainController.swift
//  Anubis
//
//  Created by Daniel Sundström on 2017-05-10.
//  Copyright © 2017 Daniel Sundström. All rights reserved.
//

import UIKit
import WebKit

class MainController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate{

    private var webView: WKWebView?
    private let contentController: WKUserContentController = WKUserContentController()
    private let beaconManager: BeaconManager = BeaconManager()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        contentController.add(self, name: "beacons");
        
    }
    
    override func viewDidLoad() {
        
        let config = WKWebViewConfiguration()
        
        config.userContentController = contentController
        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        
        self.webView?.navigationDelegate = self
        self.webView?.navigationDelegate = self
        
        self.view.addSubview(self.webView!)
        
        let request = URLRequest(url: URL(string: "http://localhost:8000/index.html")!)
        self.webView?.load(request)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("fetto....")
        print(message.body)
    }
    
}
