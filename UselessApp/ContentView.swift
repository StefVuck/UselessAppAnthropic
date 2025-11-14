import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Useless App")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("This app does absolutely nothing useful")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Do Nothing") {
                // Intentionally does nothing
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    ContentView()
}
