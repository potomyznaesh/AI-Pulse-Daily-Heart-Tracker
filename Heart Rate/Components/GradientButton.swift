import SwiftUI

struct GradientButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "F9B8C2"),
                            Color(hex: "EF4874")
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 40)
    }
}
