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
    @StateObject private var cameraViewModel = CameraSetupViewModel()

    var body: some View {
        ZStack {
            CameraView(cameraViewModel: cameraViewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    Button("Start Reading") {
                        cameraViewModel.startReading()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Stop Reading") {
                        cameraViewModel.stopReading()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }.padding()
            }
        }
    }
}








