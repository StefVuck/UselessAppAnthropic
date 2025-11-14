import SwiftUI

enum WheelOutcome: String, CaseIterable {
    case open = "OPEN"
    case teleport = "TELEPORT"
    case delete = "DELETE"

    var color: Color {
        switch self {
        case .open: return .green
        case .teleport: return .yellow
        case .delete: return .red
        }
    }

    var probability: Double {
        switch self {
        case .open: return 0.50
        case .teleport: return 0.45
        case .delete: return 0.05
        }
    }

    var message: String {
        switch self {
        case .open:
            return "You got lucky this time!"
        case .teleport:
            return "Your file has been teleported to a random location..."
        case .delete:
            return "Your file has been sent to the shadow realm!"
        }
    }

    var icon: String {
        switch self {
        case .open: return "checkmark.circle.fill"
        case .teleport: return "arrow.triangle.2.circlepath"
        case .delete: return "trash.fill"
        }
    }

    static func random() -> WheelOutcome {
        let roll = Double.random(in: 0...1)
        if roll < 0.05 {
            return .delete
        } else if roll < 0.50 {
            return .teleport
        } else {
            return .open
        }
    }
}

struct WheelSegmentData: Identifiable {
    let id = UUID()
    let outcome: WheelOutcome
    let startAngle: Double
    let endAngle: Double
    let showLabel: Bool

    var midAngle: Double {
        (startAngle + endAngle) / 2
    }

    static func generateSegments() -> [WheelSegmentData] {
        var segments: [WheelSegmentData] = []

        let deleteSectionWidth = 6.0
        let numDeleteSections = 6
        let deletePositions: [Double] = [30, 90, 150, 210, 270, 330]

        var currentAngle = 0.0

        for i in 0..<360 {
            let angle = Double(i)

            if deletePositions.contains(where: { abs(angle - $0) < deleteSectionWidth / 2 }) {
                if segments.last?.outcome != .delete {
                    let startDeleteAngle = angle
                    let endDeleteAngle = angle + deleteSectionWidth
                    segments.append(WheelSegmentData(
                        outcome: .delete,
                        startAngle: startDeleteAngle,
                        endAngle: min(endDeleteAngle, 360),
                        showLabel: true
                    ))
                    currentAngle = min(endDeleteAngle, 360)
                }
            }
        }

        segments.sort { $0.startAngle < $1.startAngle }

        var fillerSegments: [WheelSegmentData] = []
        for i in 0..<segments.count {
            let currentEnd = segments[i].endAngle
            let nextStart = i + 1 < segments.count ? segments[i + 1].startAngle : 360 + segments[0].startAngle

            if nextStart > currentEnd {
                let gapSize = nextStart - currentEnd
                let openSize = gapSize * 0.53
                let teleportSize = gapSize * 0.47

                fillerSegments.append(WheelSegmentData(
                    outcome: .open,
                    startAngle: currentEnd,
                    endAngle: currentEnd + openSize,
                    showLabel: openSize > 20
                ))

                fillerSegments.append(WheelSegmentData(
                    outcome: .teleport,
                    startAngle: currentEnd + openSize,
                    endAngle: currentEnd + openSize + teleportSize,
                    showLabel: teleportSize > 20
                ))
            }
        }

        segments.append(contentsOf: fillerSegments)
        segments.sort { $0.startAngle < $1.startAngle }

        return segments
    }
}
