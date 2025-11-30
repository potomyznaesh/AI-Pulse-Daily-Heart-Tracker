import SwiftUI

struct HeartbeatAnimationView: View {
    @State private var scanOffset: CGFloat = -0.5
    
    private let pulseGradient = LinearGradient(
        colors: [Color(hex: "F3547E"), Color(hex: "FFA0B5")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        ZStack {
            PulseLifeShape()
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
            
            PulseLifeShape()
                .stroke(pulseGradient, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                .mask(
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: geo.size.width * 0.4)
                            .offset(x: scanOffset * geo.size.width)
                    }
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                scanOffset = 1.1
            }
        }
    }
}

struct PulseLifeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = height * 0.5
        
        path.move(to: CGPoint(x: 0, y: midY))
        path.addLine(to: CGPoint(x: width * 0.1, y: midY))
        path.addCurve(to: CGPoint(x: width * 0.15, y: midY * 0.9),
                      control1: CGPoint(x: width * 0.12, y: midY),
                      control2: CGPoint(x: width * 0.13, y: midY * 0.9))
        path.addCurve(to: CGPoint(x: width * 0.2, y: midY),
                      control1: CGPoint(x: width * 0.17, y: midY * 0.9),
                      control2: CGPoint(x: width * 0.18, y: midY))
        path.addLine(to: CGPoint(x: width * 0.25, y: midY))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.35, y: height * 0.1))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.9))
        path.addLine(to: CGPoint(x: width * 0.45, y: midY))
        path.addLine(to: CGPoint(x: width * 0.55, y: midY))
        path.addCurve(to: CGPoint(x: width * 0.65, y: midY * 0.8),
                      control1: CGPoint(x: width * 0.6, y: midY),
                      control2: CGPoint(x: width * 0.63, y: midY * 0.8))
        path.addCurve(to: CGPoint(x: width * 0.75, y: midY),
                      control1: CGPoint(x: width * 0.67, y: midY * 0.8),
                      control2: CGPoint(x: width * 0.72, y: midY))
        path.addLine(to: CGPoint(x: width * 1.0, y: midY))
        
        return path
    }
}
