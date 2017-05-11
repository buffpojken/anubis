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
        
        let appFlag = WKUserScript(source: "window.inApp = true", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(appFlag)

        config.userContentController = contentController
        config.websiteDataStore = WKWebsiteDataStore.nonPersistent()

        
        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        
        self.webView?.navigationDelegate = self
        self.webView?.navigationDelegate = self
        
        self.view.addSubview(self.webView!)
        
        let request = URLRequest(url: URL(string: Config.initialURL)!)
        self.webView?.load(request)
        
        self.beaconManager.beaconDetected = {beacon in
            self.postEventToContext(event: "beaconDetected", payload: beacon)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.beaconManager.startObserving();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.beaconManager.stopObserving();
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated{
            if let url = navigationAction.request.url,
                let host = url.host, !host.hasPrefix(Config.gameHost),
                UIApplication.shared.canOpenURL(url){
                UIApplication.shared.openURL(url)
                decisionHandler(.cancel)
            }else{
                decisionHandler(.allow)
            }
        }else{
            decisionHandler(.allow)
        }
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    private func postEventToContext(event: String, payload: ObservedBeacon){
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: payload.payload, options: JSONSerialization.WritingOptions()) as Data
            let handler = String(format: "Anubis.receiveMessage('%@', '%@', %@)", payload.identifier, event, String(data: jsonData, encoding:.utf8)!)
            self.webView?.evaluateJavaScript(handler, completionHandler: nil)
        }catch _ {
            print("json error")
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let payload = message.body as? NSDictionary{
            let tag = payload.object(forKey: "tag") as! String
            switch(tag){
            case "registerBeacons":
                let beacons = payload.object(forKey: "beacons") as? Array<Dictionary<String, Any>>
                let identifier = payload.object(forKey: "identifier") as! String
                self.beaconManager.registerBeacons(beacons, forIdentifier: identifier)
            default:
                print("nothing")
            }
        }
    }
    
}
