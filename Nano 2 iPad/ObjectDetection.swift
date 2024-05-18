//
//  ObjectDetection.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 18/05/24.
//

import CoreML
import Vision

class ObjectDetectionViewModel: ObservableObject {
    private var model: VNCoreMLModel?
    
    init() {
        setupModel()
    }
    
    private func setupModel() {
        guard let modelURL = Bundle.main.url(forResource: "YOLOv3Int8LUT", withExtension: "mlmodelc") else {
            fatalError("Could not find YOLO model")
        }
        
        do {
            let model = try MLModel(contentsOf: modelURL)
            self.model = try VNCoreMLModel(for: model)
        } catch {
            fatalError("Could not load YOLO model: \(error)")
        }
    }
    
    func detectObjects(in pixelBuffer: CVPixelBuffer, completion: @escaping ([VNRecognizedObjectObservation]) -> Void) {
        guard let model = self.model else { return }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("Error in YOLO model: \(error)")
                completion([])
                return
            }
            
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                print("No results from YOLO model")
                completion([])
                return
            }
            
            print("YOLO model detected \(results.count) objects")
            completion(results)
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform YOLO request: \(error)")
            completion([])
        }
    }
}
