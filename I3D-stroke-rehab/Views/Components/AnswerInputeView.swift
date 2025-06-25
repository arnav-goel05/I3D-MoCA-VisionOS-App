//
//  AnswerInputeView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 18/6/25.
//

import SwiftUI

struct AnswerInputView: View {
    let title: String
    @Binding var userInput: String
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            TextField(title, text: $userInput)
                .textFieldStyle(.roundedBorder)
                .frame(width: 600)
                .submitLabel(.done)
                .controlSize(.large)
                .accessibilityLabel("Answer")

            Button(action: onSubmit) {
                Text("Submit")
                    .buttonTextStyle()
            }
        }
        .padding(50)
    }
}
