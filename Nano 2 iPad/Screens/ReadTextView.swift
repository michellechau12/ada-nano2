//
//  ReadTextView.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 19/05/24.
//

import SwiftUI

struct ReadTextView: View {
    @StateObject private var cameraSetupViewModel = CameraSetupViewModel()
    @StateObject private var textDetectionViewModel = TextToSpeechViewModel()
    
    var body: some View {
        ZStack {
            CameraView(cameraSetupViewModel: cameraSetupViewModel)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Button("Start Reading") {
                        textDetectionViewModel.startReading()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Stop Reading") {
                        textDetectionViewModel.stopReading()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Spacer()
                }.padding()
            }
        }
    }
}


