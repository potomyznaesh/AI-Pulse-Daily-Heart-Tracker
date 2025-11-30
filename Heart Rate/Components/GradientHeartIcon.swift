import SwiftUI

struct GradientHeartIcon: View {
    var width: CGFloat = 26
    var height: CGFloat = 26
    
    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color(hex: "FFA4B1"), Color(hex: "FF1C64")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}
