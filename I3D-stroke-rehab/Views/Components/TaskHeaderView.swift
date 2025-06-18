//
//  TaskHeaderView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 18/6/25.
//

import SwiftUI

struct TaskHeaderView: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .titleTextStyle()
            if let subtitle = subtitle {
                Text(subtitle)
                    .subtitleTextStyle()
            }
        }
    }
}

