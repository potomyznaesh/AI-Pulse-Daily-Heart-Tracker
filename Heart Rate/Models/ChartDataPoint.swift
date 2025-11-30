import SwiftUI

struct ChartDataPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let dateLabel: String
    let bpm: Int
    let status: MeasurementHistoryItem.Status
    
    var pointColor: Color {
        switch status {
        case .high: return AppTheme.Colors.highBPM
        case .normal: return AppTheme.Colors.normalBPM
        case .low: return AppTheme.Colors.lowBPM
        }
    }
}
