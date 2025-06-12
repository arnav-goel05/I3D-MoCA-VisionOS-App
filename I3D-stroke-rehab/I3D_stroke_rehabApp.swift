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
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
    }

}
