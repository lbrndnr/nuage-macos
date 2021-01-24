//
//  WebView.swift
//  Nuage
//
//  Created by Laurin Brandner on 24.01.21.
//

import SwiftUI
import AppKit
import WebKit

typealias CookieHandler = ((HTTPCookie) -> ())

struct WebView: NSViewRepresentable {
    
    private var url: URL
    private var coordinator = WebViewCoordinator()
    
    init(url: URL) {
        self.url = url
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        return coordinator
    }
    
    func makeNSView(context: Self.Context) -> WKWebView {
        let conf = WKWebViewConfiguration()
        conf.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        
        let view = WKWebView(frame: .zero, configuration: conf)
        view.load(URLRequest(url: url))
        view.navigationDelegate = context.coordinator
        
        return view
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {}
    
    func cookie(name: String, handler: @escaping CookieHandler) -> WebView {
        coordinator.handlers.append((name, handler))
        return self
    }
    
}

class WebViewCoordinator: NSObject, WKNavigationDelegate {
    
    var handlers = [(String, CookieHandler)]()
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let store = webView.configuration.websiteDataStore
        store.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                for (name, handler) in self.handlers {
                    if name == cookie.name {
                        handler(cookie)
                    }
                }
            }
        }
        
        decisionHandler(.allow)
    }
    
}
