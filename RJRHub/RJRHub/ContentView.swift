//
//  ContentView.swift
//  RJR Hub
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // Your webview code will remain, just without the safe area modifier attached below it
        WebView(url: URL(string: "https://rafsanjanirupok.com/")!) 
    }
}

#Preview {
    ContentView()
}
