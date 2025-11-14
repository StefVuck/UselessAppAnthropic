import SwiftUI
import AppKit

class ClippyService: ObservableObject {
    static let shared = ClippyService()

    @Published var currentExpression: ClippyExpression = .idle
    @Published var currentMessage: String = ""
    @Published var currentState: ClippyState = .hidden
    @Published var isVisible: Bool = false

    private var floatingWindow: ClippyFloatingWindow?
    private var hideTimer: Timer?

    private init() {}

    func show(message: ClippyMessage, state: ClippyState) {
        DispatchQueue.main.async {
            print("🎭 Clippy showing: \(message.text)")

            self.currentExpression = message.expression
            self.currentMessage = message.text
            self.currentState = state
            self.isVisible = true

            self.hideTimer?.invalidate()

            if self.floatingWindow == nil {
                print("🎭 Creating new Clippy window")
                self.floatingWindow = ClippyFloatingWindow()
                self.updateWindowContent()
            } else {
                print("🎭 Reusing existing Clippy window")
                self.updateWindowContent()
            }

            self.floatingWindow?.show()

            print("🎭 Clippy window shown, visible for \(message.duration)s")

            self.hideTimer = Timer.scheduledTimer(withTimeInterval: message.duration, repeats: false) { _ in
                self.hide()
            }
        }
    }

    func hide() {
        DispatchQueue.main.async {
            self.hideTimer?.invalidate()
            self.isVisible = false
            self.floatingWindow?.hide()
            self.currentState = .hidden
        }
    }

    func showForSpinning() {
        let message = ClippyMessage.spinningMessages.randomElement() ?? ClippyMessage.spinningMessages[0]
        show(message: message, state: .watching)
    }

    func showForDelete() {
        let message = ClippyMessage.deleteMessages.randomElement() ?? ClippyMessage.deleteMessages[0]
        show(message: message, state: .throwing)
    }

    func showForTeleport() {
        let message = ClippyMessage.teleportMessages.randomElement() ?? ClippyMessage.teleportMessages[0]
        show(message: message, state: .teleporting)
    }

    func showForOpen() {
        let message = ClippyMessage.openMessages.randomElement() ?? ClippyMessage.openMessages[0]
        show(message: message, state: .celebrating)
    }

    private func updateWindowContent() {
        let clippyView = ClippyView(
            expression: currentExpression,
            message: currentMessage,
            state: currentState
        )

        let hostingView = NSHostingView(rootView: clippyView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 280, height: 120)
        floatingWindow?.contentView = hostingView
    }
}
