//
//  CameraViewController.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 18/05/24.
//

import AVFoundation
import UIKit

class CameraViewController: UIViewController {
    var cameraViewModel: CameraSetupViewModel?
    var previewLayer: AVCaptureVideoPreviewLayer? //to show live camera feed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let cameraViewModel = cameraViewModel, let captureSession = cameraViewModel.captureSession else { return }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //        previewLayer.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    //        view.layer.addSublayer(previewLayer)
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreviewLayerFrame()
    }
    
    @objc func handleOrientationChange() {
        updatePreviewLayerFrame()
    }
    
    private func updatePreviewLayerFrame() {
        previewLayer?.frame = view.bounds
        if let connection = previewLayer?.connection, connection.isVideoOrientationSupported {
            connection.videoOrientation = getCurrentVideoOrientation()
        }
    }
    
    private func getCurrentVideoOrientation() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


