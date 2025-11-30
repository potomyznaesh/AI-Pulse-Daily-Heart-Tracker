import SwiftUI

struct DetailTagView: View {
    let text: String
    let icon: String
    let style: TagStyle
    
    enum TagStyle {
        case mood
        case activity
    }
    
    private var strokeColor: Color {
        style == .mood ? Color(hex: "FFC700") : Color(hex: "007AFF")
    }
    
    private var backgroundColor: Color {
        strokeColor.opacity(0.1)
    }
    
    private var iconColor: Color? {
        style == .mood ? nil : strokeColor
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(strokeColor)
            
            Image(icon)
                .resizable()
                .renderingMode(iconColor == nil ? .original : .template)
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(iconColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(backgroundColor)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(strokeColor, lineWidth: 1)
        )
    }
}
