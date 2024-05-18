//
//  TextToSpeechViewModel.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 18/05/24.
//

import Foundation
import AVFoundation
import Vision

class TextDetectionViewModel: NSObject, ObservableObject {
    private var textDetectionRequest: VNRecognizeTextRequest!
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var isReadingText = false
    
    override init() {
        super.init()
        setupTextDetection()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewSampleBuffer(notification:)), name: .newSampleBuffer, object: nil)
    }
    
    private func setupTextDetection() {
        textDetectionRequest = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let recognizedTexts = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let fullText = recognizedTexts.joined(separator: " ")
            
            if !fullText.isEmpty {
                self.speak(text: fullText)
            }
        }
        
        textDetectionRequest.recognitionLevel = .accurate
        textDetectionRequest.usesLanguageCorrection = true
    }
    
    @objc private func handleNewSampleBuffer(notification: Notification) {
        guard isReadingText else { return }
        
        // Memeriksa apakah notification.object adalah CVPixelBuffer
        guard CFGetTypeID(notification.object as CFTypeRef) == CVPixelBufferGetTypeID() else {
            // Display error message if notification.object is not of type CVPixelBuffer
            print("Error: Notification object is not of type CVPixelBuffer")
            return
        }

        // Saat ini downcast akan selalu berhasil
        let pixelBuffer = notification.object as! CVPixelBuffer

        guard let roi = notification.userInfo?["roi"] as? CGRect else { return }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        textDetectionRequest.regionOfInterest = roi
        
        try? requestHandler.perform([textDetectionRequest])
    }

    
    func startReading() {
        isReadingText = true
    }
    
    func stopReading() {
        isReadingText = false
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID")
        speechSynthesizer.speak(utterance)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
