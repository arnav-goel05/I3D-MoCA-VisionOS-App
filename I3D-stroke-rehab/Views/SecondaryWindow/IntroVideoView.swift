//
//  IntroVideoView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 18/6/25.
//

// Plays an introduction video for patients.

import SwiftUI
import AVKit

struct IntroVideoView: View {
    var body: some View {
        if let url = Bundle.main.url(forResource: "introVideo", withExtension: "mp4") {
            let player = AVPlayer(url: url)

            VideoPlayer(player: player)
                .aspectRatio(contentMode: .fill)
                .onAppear {
                    player.play()
                }
        } else {
            Text("Video not found")
        }
    }
}
