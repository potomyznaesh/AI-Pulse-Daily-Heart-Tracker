import Foundation
import CoreImage

final class PulseDetector {
    
    private let maxSamples = 240
    private let minSamples = 60
    private let confidenceThreshold = 4
    
    private var redValues: [Double] = []
    private var timestamps: [TimeInterval] = []
    
    private var detectionConfidence = 0
    private var removalConfidence = 0
    
    private var lastBPMUpdate = Date.distantPast
    
    func reset() {
        redValues.removeAll()
        timestamps.removeAll()
        detectionConfidence = 0
        removalConfidence = 0
    }
    
    func process(buffer: CVPixelBuffer) -> (isFingerDetected: Bool, bpm: Int?) {
        let ciImage = CIImage(cvPixelBuffer: buffer)
        
        guard let averageColor = getAverageColor(from: ciImage) else {
            return (false, nil)
        }
        
        let r = averageColor.r
        let g = averageColor.g
        let b = averageColor.b
        
        let fingerIsOn = r > 50 && r > g + 10 && r > b + 10
        
        var isFingerDetected = false
        
        if fingerIsOn {
            detectionConfidence += 1
            removalConfidence = 0
            
            if detectionConfidence > confidenceThreshold {
                isFingerDetected = true
            }
        } else {
            detectionConfidence = 0
            removalConfidence += 1
            
            if removalConfidence > confidenceThreshold {
                isFingerDetected = false
                if removalConfidence == confidenceThreshold + 1 {
                    reset()
                }
            }
        }
        
        var calculatedBPM: Int? = nil
        if isFingerDetected {
            calculatedBPM = processSignal(value: r)
        }
        
        return (isFingerDetected, calculatedBPM)
    }
    
    private func getAverageColor(from image: CIImage) -> (r: Double, g: Double, b: Double)? {
        guard let filter = CIFilter(name: "CIAreaAverage") else { return nil }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgRect: image.extent), forKey: kCIInputExtentKey)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        return (Double(bitmap[0]), Double(bitmap[1]), Double(bitmap[2]))
    }
    
    private func processSignal(value: Double) -> Int? {
        let now = Date().timeIntervalSince1970
        
        let smoothed = (value + (redValues.last ?? value)) / 2.0
        
        redValues.append(smoothed)
        timestamps.append(now)
        
        if redValues.count > maxSamples {
            redValues.removeFirst()
            timestamps.removeFirst()
        }
        
        guard redValues.count >= minSamples else { return nil }
        
        if Date().timeIntervalSince(lastBPMUpdate) < 1.0 { return nil }
        
        if let bpm = calculateBPM() {
            lastBPMUpdate = Date()
            return bpm
        }
        
        return nil
    }
    
    private func calculateBPM() -> Int? {
        guard redValues.count == timestamps.count else { return nil }
        
        let mean = redValues.reduce(0, +) / Double(redValues.count)
        let centered = redValues.map { $0 - mean }
        
        guard let maxVal = centered.max(), maxVal > 0.1 else { return nil }
        
        let threshold = maxVal * 0.3
        var peakTimes: [TimeInterval] = []
        
        for i in 1..<(centered.count - 1) {
            if centered[i] > threshold &&
                centered[i] > centered[i - 1] &&
                centered[i] > centered[i + 1] {
                peakTimes.append(timestamps[i])
            }
        }
        
        guard peakTimes.count >= 2 else { return nil }
        
        let duration = peakTimes.last! - peakTimes.first!
        guard duration > 0 else { return nil }
        
        let beats = Double(peakTimes.count - 1)
        let bpm = beats / duration * 60.0
        let val = Int(bpm.rounded())
        
        if val < 40 || val > 180 { return nil }
        
        return val
    }
}
