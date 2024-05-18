//
//  OverlayView.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 18/05/24.
//

import SwiftUI

struct OverlayView: UIViewRepresentable {
    @Binding var roi: CGRect
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.subviews.forEach { $0.removeFromSuperview() } // Remove old bounding boxes
        
        let boundingBoxView = UIView(frame: roi)
        boundingBoxView.layer.borderColor = UIColor.red.cgColor
        boundingBoxView.layer.borderWidth = 2.0
        uiView.addSubview(boundingBoxView)
    }
}

