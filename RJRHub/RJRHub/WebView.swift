//
//  WebView.swift
//  RJR Hub
//
//  A UIViewRepresentable wrapping WKWebView that:
//   - Loads only https://rafsanjanirupok.com/
//   - Persists cookies / localStorage / sessions across launches
//     (WKWebsiteDataStore.default() is disk-backed automatically)
//   - Caches page resources aggressively so repeat visits open faster
//   - Shows no on-screen browser chrome (no address bar, no nav buttons)
//   - Opens links to OTHER domains in Safari instead of inside the app
//   - Falls back to the last cached copy of the page if there's no
//     internet connection, so the app still opens something useful.
//

import SwiftUI
@preconcurrency import WebKit
import Network

struct WebView: UIViewRepresentable {

    static let siteURL = URL(string: "https://rafsanjanirupok.com/")!

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // Use the persistent, disk-backed data store. This is what makes
        // cookies, localStorage, IndexedDB, and login/session state survive
        // between app launches.
        configuration.websiteDataStore = WKWebsiteDataStore.default()

        // Let the site play inline media without extra permission prompts,
        // and allow JavaScript (on by default, listed here for clarity).
        configuration.allowsInlineMediaPlayback = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        // Share one process pool so cached data / sessions are consistent
        // if this view is ever recreated.
        configuration.processPool = SharedWebKitState.processPool

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        // No visible browser UI: no swipe-to-navigate edge indicators,
        // no link-preview popups, no scroll bounce past content.
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false
        webView.scrollView.bounces = true
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black

        // Standard URLCache sizing bump so images/CSS/JS the site serves
        // get reused instead of re-downloaded (works alongside the
        // website data store for a genuinely faster second launch).
        URLCache.shared = URLCache(
            memoryCapacity: 50 * 1024 * 1024,   // 50 MB
            diskCapacity: 250 * 1024 * 1024,    // 250 MB
            diskPath: "rjrhub_url_cache"
        )

        context.coordinator.load(in: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Nothing to push down from SwiftUI; the web view manages its own
        // navigation state once loaded.
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let parent: WebView
        private let monitor = NWPathMonitor()
        private var isOnline = true

        init(_ parent: WebView) {
            self.parent = parent
            super.init()
            monitor.pathUpdateHandler = { [weak self] path in
                self?.isOnline = (path.status == .satisfied)
            }
            monitor.start(queue: DispatchQueue.global(qos: .background))
        }

        func load(in webView: WKWebView) {
            // Prefer cached content when we're offline so the app still
            // opens to something instead of an error screen; otherwise use
            // the default policy so the site's own cache headers decide.
            let policy: URLRequest.CachePolicy =
                isOnline ? .useProtocolCachePolicy : .returnCacheDataElseLoad
            let request = URLRequest(
                url: WebView.siteURL,
                cachePolicy: policy,
                timeoutInterval: 20
            )
            webView.load(request)
        }

        // Keep navigation confined to rafsanjanirupok.com. Anything else
        // (mailto:, tel:, or a link to a different site) is handed off to
        // the system instead of loading inside this single-purpose app.
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let isSameSite = url.host?.hasSuffix("rafsanjanirupok.com") ?? false
            let isHttpFamily = url.scheme == "https" || url.scheme == "http"

            if isSameSite || !isHttpFamily {
                decisionHandler(.allow)
            } else {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            }
        }

        // If a network load fails (no internet, DNS hiccup, etc.), retry
        // once from whatever is already cached on disk.
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            retryFromCacheIfNeeded(webView, error: error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            retryFromCacheIfNeeded(webView, error: error)
        }

        private func retryFromCacheIfNeeded(_ webView: WKWebView, error: Error) {
            let nsError = error as NSError
            guard nsError.domain == NSURLErrorDomain else { return }
            let request = URLRequest(
                url: WebView.siteURL,
                cachePolicy: .returnCacheDataDontLoad,
                timeoutInterval: 20
            )
            webView.load(request)
        }
    }
}

/// A single shared WKProcessPool for the app's lifetime.
enum SharedWebKitState {
    static let processPool = WKProcessPool()
}
