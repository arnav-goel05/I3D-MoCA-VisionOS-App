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
    let destination: Destination
    
    var body: some View {
        NavigationStack {
            Text(completionText)
                .titleTextStyle()
                .padding(.bottom, 20)
            
            NavigationLink(destination: destination) {
                Text(buttonText)
                    .buttonTextStyle()
            }
        }
    }
}
