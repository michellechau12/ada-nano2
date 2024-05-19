//
//  ContentView.swift
//  Nano 2 iPad
//
//  Created by Michelle Chau on 15/05/24.
//


import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            TabView {
                ReadTextView()
                    .tabItem {
                        Image(systemName: "text.viewfinder")
                        Text("Read Text")
                    }
                
                ReadObjectView()
                    .tabItem {
                        Image(systemName: "cube.box")
                        Text("Read Object")
                    }
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    ContentView()
}
