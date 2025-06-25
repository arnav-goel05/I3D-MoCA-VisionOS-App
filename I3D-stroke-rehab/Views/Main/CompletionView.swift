//
//  CompletionView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 18/6/25.
//

import SwiftUI

struct CompletionView<Destination: View>: View {
    let completionText: String
    let buttonText: String
    let onButtonTapped: () -> Void
    let destination: Destination

    @State private var isPresented = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                Text(completionText)
                    .titleTextStyle()

                Button(
                    action: {
                        onButtonTapped()
                        isPresented = true
                    },
                    label: {
                        Text(buttonText)
                            .buttonTextStyle()
                    }
                )
            }
            .padding()
            .navigationDestination(isPresented: $isPresented) {
                destination
            }
        }
    }
}
