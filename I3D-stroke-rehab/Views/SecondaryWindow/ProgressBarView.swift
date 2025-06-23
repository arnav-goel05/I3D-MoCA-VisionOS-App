//
//  ProgressBarView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 17/6/25.
//

import SwiftUI

struct ProgressBarView: View {
    let currentStep: Int
    let totalSteps: Int

    private var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return min(max(Double(currentStep) / Double(totalSteps), 0), 1)
    }

    var body: some View {
        VStack {
            Text("\(Int(progress * 100))%")
                .titleTextStyle()
                .padding(.bottom, 8)
            
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    Capsule()
                        .fill(Color(.systemGray5))
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(
                            width: geo.size.width * 1,
                            height: geo.size.height * CGFloat(progress)
                        )
                    
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .aspectRatio(1/4, contentMode: .fit)
            
            Text("Step \(currentStep) of \(totalSteps)")
                .titleTextStyle()
                .padding(.top, 8)
        }
        .padding()
    }
}

