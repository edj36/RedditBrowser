//
//  DetailViewController.swift
//  Reddit
//
//  Created by Eric Johnson  on 9/26/15.
//  Copyright (c) 2015 Eric Johnson . All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var url: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var URL = NSURL(string: url)
        self.title = URL!.absoluteString
        let webView = UIWebView(frame:view.frame)
        webView.scalesPageToFit = true
        
        let request = NSURLRequest(URL: URL!)
        webView.loadRequest(request)
        view.addSubview(webView)
    }

}
