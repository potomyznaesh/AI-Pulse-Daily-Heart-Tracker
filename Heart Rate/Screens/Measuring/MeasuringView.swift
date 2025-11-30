import SwiftUI
import Charts

struct MeasuringView: View {
    @Binding var selectedItem: MeasurementHistoryItem?
    
    @EnvironmentObject var historyStore: HistoryStore
    @State private var selectedPeriod: StatsPeriod = .day
    @State private var displayedDate = Date()
    
    private let pickerGradient = AppTheme.Gradients.primary
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HeaderChartView(
                    selectedPeriod: $selectedPeriod,
                    displayedDate: $displayedDate,
                    chartData: prepareChartData(),
                    pickerGradient: pickerGradient,
                    dateRangeText: dateRangeText
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("History")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.horizontal)
                    
                    let items = filteredItems()
                    
                    if items.isEmpty {
                        Text("No measurements for this period")
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(items) { item in
                            HistoryRow(item: item)
                                .onTapGesture {
                                    selectedItem = item
                                }
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .background(Color(hex: "F2F2F7"))
    }
    
    private func prepareChartData() -> [ChartDataPoint] {
        let items = filteredItems()
        let sorted = items.sorted { $0.date < $1.date }
        
        return sorted.map { item in
            ChartDataPoint(
                date: item.date,
                dateLabel: item.dateLabel(for: selectedPeriod),
                bpm: item.bpm,
                status: item.status
            )
        }
    }
    
    private func filteredItems() -> [MeasurementHistoryItem] {
        let calendar = Calendar.current
        return historyStore.history.filter { item in
            switch selectedPeriod {
            case .day:
                return calendar.isDate(item.date, inSameDayAs: displayedDate)
            case .week:
                return calendar.isDate(item.date, equalTo: displayedDate, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(item.date, equalTo: displayedDate, toGranularity: .month)
            }
        }.sorted { $0.date > $1.date }
    }
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        switch selectedPeriod {
        case .day:
            formatter.dateFormat = "d MMMM"
            if Calendar.current.isDateInToday(displayedDate) {
                return "Today, " + formatter.string(from: displayedDate)
            }
            return formatter.string(from: displayedDate)
        case .week:
            formatter.dateFormat = "d MMM"
            let startOfWeek = displayedDate
            return formatter.string(from: startOfWeek)
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: displayedDate)
        }
    }
}

struct HistoryRow: View {
    let item: MeasurementHistoryItem
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                
                Image(systemName: "heart.fill")
                    .foregroundColor(statusColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.bpm) BPM")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(item.formattedDate)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            StatusTagView(status: item.status)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 6, y: 3)
        .padding(.horizontal)
    }
    
    private var statusColor: Color {
        switch item.status {
        case .high: return AppTheme.Colors.highBPM
        case .normal: return AppTheme.Colors.normalBPM
        case .low: return AppTheme.Colors.lowBPM
        }
    }
}

enum StatsPeriod {
    case day, week, month
}

extension MeasurementHistoryItem {
    func dateLabel(for period: StatsPeriod) -> String {
        let formatter = DateFormatter()
        switch period {
        case .day:
            formatter.dateFormat = "HH:mm"
        case .week:
            formatter.dateFormat = "E"
        case .month:
            formatter.dateFormat = "d"
        }
        return formatter.string(from: date)
    }
}
