//
//  CameraSetUp.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 18/05/24.
//

import AVFoundation
import Foundation

class CameraSetupViewModel: NSObject, ObservableObject {
    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureVideoDataOutput?
    private var objectDetectionViewModel = ObjectDetectionViewModel()
    
    override init() {
        super.init()
        setupCamera()
    }
    
    // Setup camera to capture video
    func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        captureSession.addInput(videoInput)
        captureSession.addOutput(videoOutput!)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }
}

extension CameraSetupViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Perform object detection
        objectDetectionViewModel.detectObjects(in: pixelBuffer) { [weak self] observations in
            // Filter out observations that are not relevant
            guard let self = self else { return }
            guard let dominantObject = observations.max(by: { $0.confidence < $1.confidence }) else { return } // Get the most confident object
            
            // Process text detection on the region of interest (ROI)
            let roi = dominantObject.boundingBox
            self.processTextDetection(in: pixelBuffer, roi: roi)
        }
    }
    
    private func processTextDetection(in pixelBuffer: CVPixelBuffer, roi: CGRect) {
        NotificationCenter.default.post(name: .newSampleBuffer, object: pixelBuffer, userInfo: ["roi": roi])
    }
}

extension Notification.Name {
    static let newSampleBuffer = Notification.Name("newSampleBuffer")
}
