//
//  CameraView.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 18/05/24.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var cameraSetupViewModel: CameraSetupViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = CameraViewController()
        viewController.cameraSetupViewModel = cameraSetupViewModel
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}



