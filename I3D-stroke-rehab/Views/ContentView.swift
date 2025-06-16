//
//  ContentView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 12/6/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Welcome to the future of Stroke Rehab!")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                NavigationLink(destination: AbstractionView())
                {
                    Text("Start Session")
                        .font(.system(size: 35, weight: .semibold, design: .rounded))
                        .padding()
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
