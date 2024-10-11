//
//  TextToSpeechViewModel.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 18/05/24.
//

import Foundation
import AVFoundation
import Vision
import CoreML

class TextToSpeechViewModel: NSObject, ObservableObject {
    private var textDetectionRequest: VNRecognizeTextRequest!
    private var objectDetectionRequest: VNCoreMLRequest!
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var isReadingText = false
    private var isDetectingObjects = false
    
    override init() {
        super.init()
        setupTextDetection()
        setupObjectDetection()
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
    
    private func setupObjectDetection() {
//        guard let model = try? VNCoreMLModel(for: YOLOv3Int8LUT().model) else {
//            fatalError("Could not load YOLOv3 model")
//        }
//        
//        
//        objectDetectionRequest = VNCoreMLRequest(model: model) { [weak self] request, error in
//            guard let self = self else { return }
//            guard let observations = request.results as? [VNRecognizedObjectObservation] else { return }
//            
//            let recognizedObjects = observations.compactMap { observation in
//                observation.labels.first?.identifier
//            }
//            
//            let objectsText = recognizedObjects.joined(separator: ", ")
//            
//            if !objectsText.isEmpty {
//                self.speak(text: " \(objectsText)")
//            }
//        }
    }
    
    @objc private func handleNewSampleBuffer(notification: Notification) {
        guard let pixelBuffer = notification.object as! CVPixelBuffer? else { return }

        if isReadingText {
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try? requestHandler.perform([textDetectionRequest])
        }

        if isDetectingObjects {
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try? requestHandler.perform([objectDetectionRequest])
        }
    }

    func startReading() {
        isReadingText = true
        isDetectingObjects = false
    }
    
    func startDetectingObjects() {
        isReadingText = false
        isDetectingObjects = true
    }
    
    func stopAllActivities() {
        isReadingText = false
        isDetectingObjects = false
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
