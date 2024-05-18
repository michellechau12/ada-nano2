//
//  CameraView.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 18/05/24.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var cameraViewModel: CameraSetupViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = CameraViewController()
        viewController.cameraViewModel = cameraViewModel
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}



