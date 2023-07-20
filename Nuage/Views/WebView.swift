//
//  WebView.swift
//  Nuage
//
//  Created by Laurin Brandner on 24.01.21.
//

import SwiftUI
import AppKit
import WebKit
import Combine

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
        view.uiDelegate = context.coordinator
        
        return view
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {}
    
    func cookie(name: String, handler: @escaping CookieHandler) -> WebView {
        coordinator.handlers.append((name, handler))
        return self
    }
    
}

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, ObservableObject {

    var handlers = [(String, CookieHandler)]()
    private var cancellables = Set<AnyCancellable>()

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.observeURLChanges(webView: webView)
        self.scanCookiesForAccessToken(webView: webView)
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = self
        view.uiDelegate = self
        
        let size = NSSize(width: windowFeatures.width?.doubleValue ?? 500, height: windowFeatures.height?.doubleValue ?? 500)
        let window = NSWindow(contentRect: NSRect(origin: .zero, size: size), styleMask: [.closable, .titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = view
        window.makeKeyAndOrderFront(nil)
        window.center()
        
        return view
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        webView.window?.close()
    }

    private func observeURLChanges(webView: WKWebView) {
        webView
          .publisher(for: \.url)
          .sink { _url in self.scanCookiesForAccessToken(webView: webView) }
          .store(in: &cancellables)
    }
    
    private func scanCookiesForAccessToken(webView: WKWebView) {
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
    }
    
}
