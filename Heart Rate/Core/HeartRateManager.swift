import Foundation
import AVFoundation
import SwiftUI
import Combine

final class HeartRateManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var isFingerDetected: Bool = false
    @Published var bpm: Int = 0
    
    private var captureSession: AVCaptureSession?
    private let sessionQueue = DispatchQueue(label: "com.heartrate.sessionQueue")
    private let pulseDetector = PulseDetector()
    
    func start() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            print("Camera not authorized")
            return
        }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession != nil { return }
            
            self.setupSession()
            self.pulseDetector.reset()
        }
    }
    
    func stop() {
        sessionQueue.async { [weak self] in
            guard let self = self, let session = self.captureSession else { return }
            
            self.stopSession(session)
            self.pulseDetector.reset()
            
            DispatchQueue.main.async {
                self.isFingerDetected = false
                self.bpm = 0
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let result = pulseDetector.process(buffer: pixelBuffer)
        
        DispatchQueue.main.async {
            if result.isFingerDetected != self.isFingerDetected {
                self.isFingerDetected = result.isFingerDetected
                if !result.isFingerDetected {
                    self.bpm = 0
                }
            }
            
            if let newBPM = result.bpm {
                self.bpm = newBPM
            }
        }
    }
    
    private func setupSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .low
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("Camera unavailable")
            return
        }
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.heartrate.videoQueue"))
        output.alwaysDiscardsLateVideoFrames = true
        
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        
        self.captureSession = session
        session.startRunning()
        
        toggleTorch(on: true, for: device)
    }
    
    private func stopSession(_ session: AVCaptureSession) {
        if let deviceInput = session.inputs.first as? AVCaptureDeviceInput {
            toggleTorch(on: false, for: deviceInput.device)
        }
        session.stopRunning()
        self.captureSession = nil
    }
    
    private func toggleTorch(on: Bool, for device: AVCaptureDevice) {
        if device.hasTorch {
            try? device.lockForConfiguration()
            if on {
                try? device.setTorchModeOn(level: 1.0)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        }
    }
}
