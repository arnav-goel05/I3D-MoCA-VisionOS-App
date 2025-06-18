//
//  ContentView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 12/6/25.
//

import SwiftUI

// Title page.
// Navigates to help page and opens up a secondary window for progress bar.

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow
    @State private var navigate = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                Text("Montreal Cognitive Assessment (MoCA)")
                    .titleTextStyle()

                Button(action: {
                    openWindow(id: "intro-video")
                    navigate = true
                }) {
                    Text("Start Test")
                        .buttonTextStyle()
                }
            }
            .navigationDestination(isPresented: $navigate) {
                HelpView()
            }
            .padding()
        }
    }
}
