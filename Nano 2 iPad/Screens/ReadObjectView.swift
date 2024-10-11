//
//  ReadObjectView.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 19/05/24.
//

import SwiftUI

struct ReadObjectView: View {
    @StateObject private var cameraSetupViewModel = CameraSetupViewModel()
    @StateObject private var textDetectionViewModel = TextToSpeechViewModel()
    
    var body: some View {
        CameraView(cameraSetupViewModel: cameraSetupViewModel)
            .edgesIgnoringSafeArea(.all)
        
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button("Start Reading") {
                    textDetectionViewModel.startReading()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Stop Reading") {
                    textDetectionViewModel.stopAllActivities()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }.padding()
        }
    }
    
}
