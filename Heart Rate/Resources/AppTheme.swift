import SwiftUI

struct AppTheme {
    struct Colors {
        static let primary = Color(hex: "FF1C64")
        static let secondary = Color(hex: "FFA4B1")
        static let background = Color.white
        static let textPrimary = Color.black
        static let textSecondary = Color.gray
        
        static let highBPM = Color(hex: "F3547E")
        static let normalBPM = Color(hex: "00B031")
        static let lowBPM = Color(hex: "8E8E93")
        
        static let gradientStart = Color(hex: "F9B8C2")
        static let gradientEnd = Color(hex: "EF4874")
        
        static let moodYellow = Color(hex: "FFC700")
        static let activityBlue = Color(hex: "007AFF")
    }
    
    struct Gradients {
        static let primary = LinearGradient(
            colors: [Colors.gradientStart, Colors.gradientEnd],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let heart = LinearGradient(
            colors: [Colors.secondary, Colors.primary],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
