import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // 1. Fills the Dynamic Island/notch area with a dark color to match your site
            Color(red: 20/255, green: 20/255, blue: 20/255)
                .ignoresSafeArea()
            
            // 2. Forces the WebView to stay strictly below the Dynamic Island
            VStack(spacing: 0) {
                WebView()
            }
        }
    }
}

#Preview {
    ContentView()
}
