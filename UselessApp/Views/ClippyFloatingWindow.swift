import SwiftUI
import AppKit

class ClippyFloatingWindow: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 140),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces]
        self.isFloatingPanel = true
        self.title = "Clippy Says..."
        self.hidesOnDeactivate = false
        self.isMovableByWindowBackground = true
        self.backgroundColor = NSColor.windowBackgroundColor
        self.isOpaque = true

        positionWindowInCorner()
        print("🎭 ClippyFloatingWindow initialized at position: \(self.frame)")
    }

    func positionWindowInCorner() {
        guard let screen = NSScreen.main else {
            print("🎭 ERROR: No main screen found")
            return
        }
        let screenFrame = screen.visibleFrame
        let windowFrame = self.frame

        let xPosition = screenFrame.maxX - windowFrame.width - 20
        let yPosition = screenFrame.maxY - windowFrame.height - 20

        print("🎭 Screen frame: \(screenFrame)")
        print("🎭 Positioning window at: (\(xPosition), \(yPosition))")

        self.setFrameOrigin(NSPoint(x: xPosition, y: yPosition))
    }

    func show() {
        print("🎭 Show() called - isVisible: \(self.isVisible)")

        self.alphaValue = 1.0
        self.makeKeyAndOrderFront(nil)

        print("🎭 Window ordered front - frame: \(self.frame)")
        print("🎭 Window level: \(self.level.rawValue)")
        print("🎭 Window is visible: \(self.isVisible)")
    }

    func hide() {
        print("🎭 Hide() called")
        self.orderOut(nil)
    }
}

struct ClippyView: View {
    let expression: ClippyExpression
    let message: String
    let state: ClippyState

    @State private var bounce = false
    @State private var rotation = 0.0

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: expression.symbolName)
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(rotation))
                    .offset(y: bounce ? -5 : 0)
            }
            .shadow(color: .blue.opacity(0.3), radius: 10)

            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 12)
                .frame(maxWidth: 260)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            print("🎭 ClippyView appeared with message: \(message)")
            startAnimations()
        }
    }

    func startAnimations() {
        switch state {
        case .throwing:
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                bounce = true
            }
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        case .teleporting:
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                bounce = true
            }
        case .celebrating:
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).repeatForever(autoreverses: true)) {
                bounce = true
            }
        case .watching:
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                bounce = true
            }
        default:
            break
        }
    }
}

#Preview {
    ClippyView(
        expression: .mischievous,
        message: "Into the void it goes!",
        state: .throwing
    )
    .frame(width: 280, height: 120)
}
