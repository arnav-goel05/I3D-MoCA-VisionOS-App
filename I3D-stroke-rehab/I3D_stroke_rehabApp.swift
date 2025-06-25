//
//  I3D_stroke_rehabApp.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 12/6/25.
//

import SwiftUI

@main
struct I3D_stroke_rehabApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup(id: "MainWindow") {
            ContentView()
                .environment(appModel)
        }
        .defaultSize(CGSize(width: 1520, height: 1000))
        
        WindowGroup(id: "progress-bar") {
            ProgressBarView(currentStep: 2, totalSteps: 8)
        }
        .defaultSize(CGSize(width:500, height: 1000))
        .defaultWindowPlacement { content, context in
            if context.windows.last?.id == "main" {
                return WindowPlacement(.trailing(context.windows.last!))
            } else {
                return WindowPlacement(.utilityPanel)
            }
        }
        
        WindowGroup(id: "intro-video") {
            IntroVideoView()
        }
        .defaultSize(CGSize(width:500, height: 950))
        .defaultWindowPlacement { content, context in
            if context.windows.last?.id == "main" {
                return WindowPlacement(.trailing(context.windows.last!))
            } else {
                return WindowPlacement(.utilityPanel)
            }
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }

}
