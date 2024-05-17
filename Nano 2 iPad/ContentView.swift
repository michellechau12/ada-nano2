//
//  ContentView.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 15/05/24.
//


import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @StateObject private var cameraModel = CameraViewModel()

    var body: some View {
        VStack {
            //cam
            CameraView(cameraModel: cameraModel)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                Button("Start Reading") {
                    cameraModel.startReading()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Stop Reading") {
                    cameraModel.stopReading()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
}

class CameraViewModel: NSObject, ObservableObject {
    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureVideoDataOutput?
    private var textDetectionRequest: VNRecognizeTextRequest!
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var isReading = false

    override init() {
        super.init()
        setupCamera()
        setupTextDetection()
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

        captureSession.startRunning()
    }

    func setupTextDetection() {
        textDetectionRequest = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            let recognizedTexts = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            let fullText = recognizedTexts.joined(separator: " ")
            self.speak(text: fullText)
        }

        textDetectionRequest.recognitionLevel = .accurate
        textDetectionRequest.usesLanguageCorrection = true
    }

    func startReading() {
        guard let videoOutput = videoOutput else { return }
        isReading = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
    }

    func stopReading() {
        isReading = false
        videoOutput?.setSampleBufferDelegate(nil, queue: nil)
        speechSynthesizer.stopSpeaking(at: .immediate)
    }

    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID")
        speechSynthesizer.speak(utterance)
    }
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isReading else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? requestHandler.perform([textDetectionRequest])
    }
}

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var cameraModel: CameraViewModel

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = CameraViewController()
        viewController.cameraModel = cameraModel
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    var cameraModel: CameraViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let cameraModel = cameraModel, let captureSession = cameraModel.captureSession else { return }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
}
