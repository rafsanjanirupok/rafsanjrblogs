//
//  RJRHubApp.swift
//  RJR Hub
//
//  Full-screen wrapper app for https://rafsanjanirupok.com/
//

import SwiftUI

@main
struct RJRHubApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .statusBar(hidden: true)
                .ignoresSafeArea()
        }
    }
}
