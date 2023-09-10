//
//  WebKitPage.swift
//  TinkoffLab
//
//  Created by Roman Tverdokhleb on 03.02.2023.
//

import UIKit
import WebKit

class WebKitPage: UIViewController {
    
    let webView = WKWebView()
    var url: String

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)
        
        guard let url = URL(string: url) else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
