//
//  ContentView.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 15/05/24.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var cameraSetupViewModel = CameraSetupViewModel()
    @StateObject private var textDetectionViewModel = TextToSpeechViewModel()

    var body: some View {
        ZStack {
            CameraView(cameraSetupViewModel: cameraSetupViewModel)
                .edgesIgnoringSafeArea(.all)
            VStack {
                
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Button {
                            textDetectionViewModel.startReading()
                        } label: {
                            Image(systemName: "text.viewfinder")
                            Text("Baca Teks")
                        }
                        .frame(width: 80)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button {
                            textDetectionViewModel.startDetectingObjects()
                        } label: {
                            Image(systemName: "dot.circle.viewfinder")
                            Text("Baca Objek")
                        }
                        .frame(width: 80)
                        .padding()
                        .background(Color.mint)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button {
                            textDetectionViewModel.stopAllActivities()
                        } label: {
                            Image(systemName: "stop")
                            Text("Stop Baca")
                        }
                        .frame(width: 80)
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
}


#Preview {
    ContentView()
}

//HStack {
//
//                    Button {
//
//                    } label: {
//                        Image(systemName: "questionmark.circle")
//                    }
//                    .padding(.leading)
//                    .font(.title)
//                    .foregroundColor(.blue)
////                    .sheet()
//                    Spacer()
//                }
