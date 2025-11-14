import SwiftUI

@main
struct UselessAppApp: App {
    var body: some Scene {
        WindowGroup {
            DictationLoginView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
