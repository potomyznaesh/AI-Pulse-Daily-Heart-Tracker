import Foundation

struct MeasurementResult {
    let bpm: Int
    let date: String
    let status: MeasurementHistoryItem.Status
    
    init(bpm: Int) {
        self.bpm = bpm
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, h:mm a"
        self.date = formatter.string(from: Date())
        
        if bpm <= 60 {
            self.status = .low
        } else if bpm <= 100 {
            self.status = .normal
        } else {
            self.status = .high
        }
    }
}
