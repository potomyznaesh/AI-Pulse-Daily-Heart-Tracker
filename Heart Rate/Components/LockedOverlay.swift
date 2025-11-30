import SwiftUI

struct LockedOverlay: ViewModifier {
    @Binding var isLocked: Bool
    @State private var showPaywall = false
    
    private let pinkGradient = LinearGradient(
        colors: [Color(hex: "FFA4B1"), Color(hex: "FF1C64")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isLocked ? 15 : 0)
                .allowsHitTesting(!isLocked)
                .animation(.easeInOut, value: isLocked)
            
            if isLocked {
                Button(action: {
                    showPaywall = true
                }) {
                    HStack(spacing: 8) {
                        Text("See result")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(pinkGradient)
                        
                        ZStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(pinkGradient)
                            
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .offset(y: 1)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.95))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .overlay(
                        Capsule()
                            .stroke(pinkGradient, lineWidth: 2)
                    )
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

extension View {
    func locked(isLocked: Binding<Bool>) -> some View {
        self.modifier(LockedOverlay(isLocked: isLocked))
    }
}
