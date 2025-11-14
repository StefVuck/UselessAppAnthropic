import SwiftUI

@main
struct UselessAppApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if appState.isAuthenticated {
                ContentView()
                    .frame(minWidth: 800, minHeight: 700)
            } else {
                DictationLoginView(appState: appState)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

class AppState: ObservableObject {
    @Published var isAuthenticated = false
}
