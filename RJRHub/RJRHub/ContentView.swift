//
//  ContentView.swift
//  RJR Hub
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        WebView()
            .ignoresSafeArea()
            .persistentSystemOverlays(.hidden) // hides the home indicator affordance bar area where possible
    }
}

#Preview {
    ContentView()
}
