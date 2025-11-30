import SwiftUI

struct StatusTagView: View {
    let status: MeasurementHistoryItem.Status
    
    private var textColor: Color {
        switch status {
        case .high: return AppTheme.Colors.highBPM
        case .normal: return AppTheme.Colors.normalBPM
        case .low: return AppTheme.Colors.lowBPM
        }
    }
    
    private var backgroundColor: Color {
        textColor.opacity(0.30)
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(textColor)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(textColor, lineWidth: 1)
            )
    }
}
