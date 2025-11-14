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
        case .open: return 0.30
        case .teleport: return 0.50
        case .delete: return 0.30
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
        if roll < 0.30 {
            return .delete
        } else if roll < 0.80 {
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

        // 30% delete, 50% teleport, 30% open -> but need to fit in 360 degrees
        // Let's create alternating segments with proper proportions
        let deleteAngle = 108.0  // 30% of 360
        let teleportAngle = 180.0  // 50% of 360
        let openAngle = 72.0  // 20% of 360

        var currentAngle = 0.0

        // Create 3 delete sections evenly spaced
        let deletePositions = [0.0, 120.0, 240.0]

        for deletePos in deletePositions {
            // Delete segment
            segments.append(WheelSegmentData(
                outcome: .delete,
                startAngle: deletePos,
                endAngle: deletePos + 36.0,
                showLabel: true
            ))

            // Teleport segment after delete
            segments.append(WheelSegmentData(
                outcome: .teleport,
                startAngle: deletePos + 36.0,
                endAngle: deletePos + 96.0,
                showLabel: true
            ))

            // Open segment
            segments.append(WheelSegmentData(
                outcome: .open,
                startAngle: deletePos + 96.0,
                endAngle: deletePos + 120.0,
                showLabel: true
            ))
        }

        return segments
    }
}
