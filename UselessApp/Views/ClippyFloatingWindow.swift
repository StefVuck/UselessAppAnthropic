import SwiftUI
import AppKit

class ClippyFloatingWindow: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 120),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isFloatingPanel = true
        self.becomesKeyOnlyIfNeeded = true
        self.hidesOnDeactivate = false
        self.isMovableByWindowBackground = true
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = true
        self.ignoresMouseEvents = false

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
        print("🎭 Show() called - isVisible: \(self.isVisible), alphaValue: \(self.alphaValue)")

        self.alphaValue = 0
        self.orderFrontRegardless()

        print("🎭 Window ordered front - frame: \(self.frame)")
        print("🎭 Window level: \(self.level.rawValue)")

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            self.animator().alphaValue = 1.0
        } completionHandler: {
            print("🎭 Fade in animation completed - alphaValue: \(self.alphaValue)")
        }
    }

    func hide() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            self.animator().alphaValue = 0.0
        } completionHandler: {
            self.orderOut(nil)
        }
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
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
        )
        .onAppear {
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
