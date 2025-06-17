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
        ZStack {
            NavigationStack {
                VStack(spacing: 50) {
                    Text("Montreal Cognitive Assessment (MoCA)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    NavigationLink(destination: HelpView())
                    {
                        Text("Start Test")
                            .font(.system(size: 35, weight: .semibold, design: .rounded))
                            .frame(width: 300, height: 60)
                            .padding()
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
}
