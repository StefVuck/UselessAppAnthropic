import SwiftUI

struct WheelSegments: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.1))
                .frame(width: 300, height: 300)

            ForEach(WheelOutcome.allCases, id: \.self) { outcome in
                WheelSegment(outcome: outcome)
            }

            Circle()
                .stroke(Color.primary, lineWidth: 4)
                .frame(width: 300, height: 300)
        }
    }
}

struct WheelSegment: View {
    let outcome: WheelOutcome

    var body: some View {
        ZStack {
            SegmentShape(startAngle: outcome.angleRange.lowerBound,
                        endAngle: outcome.angleRange.upperBound)
                .fill(outcome.color.opacity(0.8))
                .frame(width: 300, height: 300)

            SegmentShape(startAngle: outcome.angleRange.lowerBound,
                        endAngle: outcome.angleRange.upperBound)
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 300, height: 300)

            Text(outcome.rawValue)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .rotationEffect(.degrees(outcome.midAngle + 90))
                .offset(y: -110)
                .rotationEffect(.degrees(-outcome.midAngle - 90))
        }
    }
}

struct SegmentShape: Shape {
    let startAngle: Double
    let endAngle: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(center: center,
                   radius: radius,
                   startAngle: .degrees(startAngle - 90),
                   endAngle: .degrees(endAngle - 90),
                   clockwise: false)
        path.closeSubpath()

        return path
    }
}

struct PointerArrow: View {
    var body: some View {
        Triangle()
            .fill(Color.primary)
            .frame(width: 30, height: 40)
            .offset(y: -170)
            .shadow(radius: 4)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
