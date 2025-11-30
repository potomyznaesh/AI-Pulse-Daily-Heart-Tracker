import SwiftUI
import Charts

struct HeaderChartView: View {
    @Binding var selectedPeriod: StatsPeriod
    @Binding var displayedDate: Date
    
    let chartData: [ChartDataPoint]
    let pickerGradient: LinearGradient
    let dateRangeText: String
    
    @State private var hasAppeared = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                PickerButton(title: "Day", isSelected: selectedPeriod == .day, gradient: pickerGradient) { selectedPeriod = .day }
                Spacer()
                PickerButton(title: "Week", isSelected: selectedPeriod == .week, gradient: pickerGradient) { selectedPeriod = .week }
                Spacer()
                PickerButton(title: "Month", isSelected: selectedPeriod == .month, gradient: pickerGradient) { selectedPeriod = .month }
                Spacer()
            }
            .padding(.horizontal)
            
            HStack {
                Button(action: { moveDate(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                }
                Spacer()
                Text(dateRangeText)
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Button(action: { moveDate(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 22, weight: .semibold))
                }
                .disabled(isViewingCurrentPeriod)
                .opacity(isViewingCurrentPeriod ? 0.3 : 1.0)
            }
            .foregroundColor(AppTheme.Colors.textPrimary)
            .padding(.horizontal)
            
            chartView
        }
        .padding(.top, 10)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                hasAppeared = true
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: chartData)
    }
    
    private var chartView: some View {
        Group {
            if selectedPeriod == .day {
                chartContent
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [0, 35, 70, 110, 140, 180]) {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1)).foregroundStyle(Color.gray.opacity(0.3))
                            AxisTick()
                            AxisValueLabel(centered: true)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .hour, count: 4)) {
                            AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)), centered: true)
                                .font(.system(size: 10))
                        }
                    }
                    .chartYScale(domain: 0...180)
                    .chartXScale(domain: chartXScaleDomain())
                    .frame(height: 250)
                    .padding(.horizontal)
            } else {
                chartContent
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [0, 35, 70, 110, 140, 180]) {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1)).foregroundStyle(Color.gray.opacity(0.3))
                            AxisTick()
                            AxisValueLabel(centered: true)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom) { value in
                            AxisValueLabel(value.as(String.self) ?? "")
                                .font(.system(size: 10))
                        }
                    }
                    .chartYScale(domain: 0...180)
                    .frame(height: 250)
                    .padding(.horizontal)
            }
        }
    }
    
    private var chartContent: some View {
        Chart {
            ForEach(chartData) { dataPoint in
                if selectedPeriod == .day {
                    dayChartMarks(for: dataPoint)
                } else {
                    periodChartMarks(for: dataPoint)
                }
            }
        }
    }
    
    @ChartContentBuilder
    private func dayChartMarks(for dataPoint: ChartDataPoint) -> some ChartContent {
        LineMark(
            x: .value("Time", dataPoint.date),
            y: .value("BPM", hasAppeared ? dataPoint.bpm : 0)
        )
        .lineStyle(StrokeStyle(lineWidth: 3, dash: [5, 5]))
        .foregroundStyle(Color.gray.opacity(0.7))
        
        PointMark(
            x: .value("Time", dataPoint.date),
            y: .value("BPM", hasAppeared ? dataPoint.bpm : 0)
        )
        .symbolSize(hasAppeared ? 150 : 0)
        .foregroundStyle(dataPoint.pointColor)
        
        AreaMark(
            x: .value("Time", dataPoint.date),
            y: .value("BPM", hasAppeared ? dataPoint.bpm : 0)
        )
        .foregroundStyle(.clear)
    }
    
    @ChartContentBuilder
    private func periodChartMarks(for dataPoint: ChartDataPoint) -> some ChartContent {
        LineMark(
            x: .value("Date", dataPoint.dateLabel),
            y: .value("BPM", hasAppeared ? dataPoint.bpm : 0)
        )
        .lineStyle(StrokeStyle(lineWidth: 3, dash: [5, 5]))
        .foregroundStyle(Color.gray.opacity(0.7))
        
        PointMark(
            x: .value("Date", dataPoint.dateLabel),
            y: .value("BPM", hasAppeared ? dataPoint.bpm : 0)
        )
        .symbolSize(hasAppeared ? 150 : 0)
        .foregroundStyle(dataPoint.pointColor)
        
        AreaMark(
            x: .value("Date", dataPoint.dateLabel),
            y: .value("BPM", hasAppeared ? dataPoint.bpm : 0)
        )
        .foregroundStyle(.clear)
    }
    
    private func moveDate(by amount: Int) {
        let calendar = Calendar.current
        var newDate: Date?
        
        switch selectedPeriod {
        case .day:
            newDate = calendar.date(byAdding: .day, value: amount, to: displayedDate)
        case .week:
            newDate = calendar.date(byAdding: .weekOfYear, value: amount, to: displayedDate)
        case .month:
            newDate = calendar.date(byAdding: .month, value: amount, to: displayedDate)
        }
        
        if let newDate = newDate {
            displayedDate = min(newDate, Date())
        }
    }
    
    private var isViewingCurrentPeriod: Bool {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .day:
            return calendar.isDate(displayedDate, inSameDayAs: Date())
        case .week:
            return calendar.isDate(displayedDate, equalTo: Date(), toGranularity: .weekOfYear)
        case .month:
            return calendar.isDate(displayedDate, equalTo: Date(), toGranularity: .month)
        }
    }
    
    private func chartXScaleDomain() -> ClosedRange<Date> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: displayedDate)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return startOfDay...tomorrow
    }
}
