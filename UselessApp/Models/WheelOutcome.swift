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

    var angleRange: ClosedRange<Double> {
        switch self {
        case .open: return 0...180
        case .teleport: return 180...342
        case .delete: return 342...360
        }
    }

    var midAngle: Double {
        let range = angleRange
        return (range.lowerBound + range.upperBound) / 2
    }
}
