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
    
    override init() {
        super.init()
        setupCamera()
    }
    
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
        
        // Notify TextDetectionViewModel with the pixel buffer
        PixelBufferNotification.post(pixelBuffer: pixelBuffer)
    }
}

extension Notification.Name {
    static let newSampleBuffer = Notification.Name("newSampleBuffer")
}

struct PixelBufferNotification {
    let pixelBuffer: CVPixelBuffer
    
    static func post(pixelBuffer: CVPixelBuffer) {
        NotificationCenter.default.post(name: .newSampleBuffer, object: pixelBuffer)
    }
}
