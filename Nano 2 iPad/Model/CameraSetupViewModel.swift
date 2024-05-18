//
//  CameraSetUp.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 18/05/24.
//

import AVFoundation
import Vision

class CameraSetupViewModel: NSObject, ObservableObject {
    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureVideoDataOutput?
    private var textDetectionRequest: VNRecognizeTextRequest!
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var isReadingText = false
    
    override init() {
        super.init()
        setupCamera()
        setupTextDetection()
    }
    
    
    //configure camera to capture video
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
    
    //text detection
    func setupTextDetection() {
        textDetectionRequest = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            //            guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else { return }
            
            
            let recognizedTexts = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let fullText = recognizedTexts.joined(separator: " ") //combine texts
            
            if !fullText.isEmpty {
                self.speak(text: fullText) //call speak func
            }
            
        }
        
        //language accuracy and correction
        textDetectionRequest.recognitionLevel = .accurate
        textDetectionRequest.usesLanguageCorrection = true
    }
    
    func startReading() {
        guard let videoOutput = videoOutput else { return }
        isReadingText = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
    }
    
    func stopReading() {
        isReadingText = false
        videoOutput?.setSampleBufferDelegate(nil, queue: nil)
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    //convert text to speech
    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID")
        speechSynthesizer.speak(utterance) //speak the text
    }
}


extension CameraSetupViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isReadingText else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? requestHandler.perform([textDetectionRequest])
    }
}

