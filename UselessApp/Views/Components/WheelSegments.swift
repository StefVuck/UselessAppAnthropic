import SwiftUI

struct WheelSegments: View {
    let segments = WheelSegmentData.generateSegments()

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.3), Color.black.opacity(0.2)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 125
                    )
                )
                .frame(width: 250, height: 250)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)

            ForEach(segments) { segmentData in
                WheelSegment(segmentData: segmentData)
            }

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.8), Color.gray.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 6
                )
                .frame(width: 250, height: 250)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white, Color.gray.opacity(0.3)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .shadow(color: .black.opacity(0.4), radius: 3)
                )
        }
    }
}

struct WheelSegment: View {
    let segmentData: WheelSegmentData

    var segmentGradient: LinearGradient {
        LinearGradient(
            colors: [segmentData.outcome.color, segmentData.outcome.color.opacity(0.7)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        ZStack {
            SegmentShape(startAngle: segmentData.startAngle,
                        endAngle: segmentData.endAngle)
                .fill(segmentGradient)
                .frame(width: 250, height: 250)

            SegmentShape(startAngle: segmentData.startAngle,
                        endAngle: segmentData.endAngle)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: 250, height: 250)

            if segmentData.showLabel {
                VStack(spacing: 4) {
                    Image(systemName: segmentData.outcome.icon)
                        .font(.system(size: segmentData.outcome == .delete ? 20 : 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)

                    if segmentData.outcome != .delete {
                        Text(segmentData.outcome.rawValue)
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 2)
                    }
                }
                .rotationEffect(.degrees(segmentData.midAngle + 90))
                .offset(y: -80)
                .rotationEffect(.degrees(-segmentData.midAngle - 90))
            } else if segmentData.outcome == .delete {
                Image(systemName: "skull.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 2)
                    .rotationEffect(.degrees(segmentData.midAngle + 90))
                    .offset(y: -90)
                    .rotationEffect(.degrees(-segmentData.midAngle - 90))
            }
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
        ZStack {
            Triangle()
                .fill(
                    LinearGradient(
                        colors: [Color.red, Color.orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 40, height: 50)
                .overlay(
                    Triangle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .shadow(color: .red.opacity(0.6), radius: 10, x: 0, y: 0)
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .offset(y: -145)
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
