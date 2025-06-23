//
//  HelpView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 17/6/25.
//

import SwiftUI

// Provides basic introduction of the assessment to users.

struct HelpView: View {
    @State private var backgroundColor: Color = .blue.opacity(0.2)
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    @State private var navigate = false
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            NavigationStack {
                VStack (spacing: 50) {
                    Text("The assessment consists of eight parts. Some questions are easy, while others are more challenging and require a bit more concentration. If you need anything clarified, please approach a nearby caregiver.")
                        .titleTextStyle()
                    Text("All The Best!")
                        .titleTextStyle()
                    Button(action: {
                        dismissWindow(id: "intro-video")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            openWindow(id: "progress-bar")
                            navigate = true
                        }
                        navigate = true
                    }) {
                        Text("Proceed")
                            .buttonTextStyle()
                    }
                }
                .navigationDestination(isPresented: $navigate) {
                    VisuospatialView()
                }
                .padding(150)
            }
        }
    }
}
