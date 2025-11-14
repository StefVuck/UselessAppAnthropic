import SwiftUI
import AppKit

struct WheelOfDoomView: View {
    let file: FileItem
    @State private var rotationAngle: Double = 0
    @State private var isSpinning = false
    @State private var outcome: WheelOutcome?
    @State private var showResult = false
    @State private var spinCount = 0
    @State private var showMinigame = false
    @State private var teleportedPath = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("WHEEL OF DOOM")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(.primary)
                .padding(.top, 20)
                .onAppear {
                    print("🎡 WheelOfDoomView appeared")
                }

            Text(file.name)
                .font(.title3)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .padding(.horizontal)

            Spacer()

            ZStack {
                WheelSegments()
                    .rotationEffect(.degrees(rotationAngle))

                PointerArrow()
            }
            .frame(width: 500, height: 550)
            .border(Color.red, width: 2)

            Spacer()

            if let outcome = outcome, showResult {
                ResultView(outcome: outcome, file: file)
                    .transition(.scale.combined(with: .opacity))
            }

            if !isSpinning && !showResult {
                Button(action: spinWheel) {
                    Text("SPIN THE WHEEL")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(colors: [.red, .orange],
                                         startPoint: .leading,
                                         endPoint: .trailing)
                        )
                        .cornerRadius(15)
                        .shadow(radius: 10)
                }
                .buttonStyle(.plain)
            }

            if showResult {
                HStack(spacing: 20) {
                    Button("Spin Again") {
                        resetWheel()
                    }
                    .buttonStyle(.bordered)

                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            if isSpinning {
                Text("Spinning...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            Text("Spins: \(spinCount)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(width: 700, height: 850)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showMinigame) {
            PathWordleView(targetPath: teleportedPath, isPresented: $showMinigame)
        }
    }

    func spinWheel() {
        print("🎡 Spin wheel button pressed")
        isSpinning = true
        spinCount += 1

        print("🎡 Calling Clippy showForSpinning")
        ClippyService.shared.showForSpinning()
        print("🎡 Clippy call completed")

        let targetOutcome = WheelOutcome.random()

        let spins = Double.random(in: 5...8)
        let targetAngle = calculateTargetAngle(for: targetOutcome)
        let totalRotation = (360 * spins) + targetAngle

        withAnimation(.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 4.0)) {
            rotationAngle += totalRotation
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            isSpinning = false
            outcome = targetOutcome
            showResult = true
            handleOutcome(targetOutcome)
        }
    }

    func calculateTargetAngle(for outcome: WheelOutcome) -> Double {
        let segments = WheelSegmentData.generateSegments()
        let matchingSegments = segments.filter { $0.outcome == outcome }

        guard let targetSegment = matchingSegments.randomElement() else {
            return 0
        }

        let segmentMid = targetSegment.midAngle
        let segmentRange = (targetSegment.endAngle - targetSegment.startAngle) / 2
        let randomOffset = Double.random(in: -segmentRange...segmentRange)

        let targetAngle = segmentMid + randomOffset
        let relativeAngle = 360 - targetAngle
        return relativeAngle.truncatingRemainder(dividingBy: 360)
    }

    func handleOutcome(_ outcome: WheelOutcome) {
        switch outcome {
        case .open:
            openFile()
        case .teleport:
            teleportFile()
        case .delete:
            deleteFile()
        }
    }

    func openFile() {
        ClippyService.shared.showForOpen()
        NSWorkspace.shared.open(file.path)
    }

    func teleportFile() {
        ClippyService.shared.showForTeleport()

        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let playgroundDir = homeDir.appendingPathComponent("Documents/ChaoticPlayground/Teleported")

        try? FileManager.default.createDirectory(at: playgroundDir,
                                                 withIntermediateDirectories: true)

        let newPath = playgroundDir.appendingPathComponent(file.name)
        try? FileManager.default.moveItem(at: file.path, to: newPath)

        teleportedPath = newPath.path
        showMinigame = true
    }

    func deleteFile() {
        ClippyService.shared.showForDelete()

        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let trashDir = homeDir.appendingPathComponent(".ChaoticTrash")

        try? FileManager.default.createDirectory(at: trashDir,
                                                 withIntermediateDirectories: true)

        let newPath = trashDir.appendingPathComponent(file.name)
        try? FileManager.default.moveItem(at: file.path, to: newPath)
    }

    func resetWheel() {
        showResult = false
        outcome = nil
    }
}

struct ResultView: View {
    let outcome: WheelOutcome
    let file: FileItem

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: outcome.icon)
                .font(.system(size: 50))
                .foregroundColor(outcome.color)

            Text(outcome.rawValue)
                .font(.title.bold())
                .foregroundColor(outcome.color)

            Text(outcome.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if outcome == .teleport {
                Text("New location: ~/Documents/ChaoticPlayground/Teleported/")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }

            if outcome == .delete {
                Text("Recoverable from: ~/.ChaoticTrash/")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(outcome.color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(outcome.color, lineWidth: 3)
        )
    }
}

#Preview {
    let testFile = FileItem(url: URL(fileURLWithPath: "/tmp/test.txt"))
    return WheelOfDoomView(file: testFile)
}
