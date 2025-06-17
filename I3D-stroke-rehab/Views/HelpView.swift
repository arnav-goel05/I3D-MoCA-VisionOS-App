//
//  HelpView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 17/6/25.
//

import SwiftUI

struct HelpView: View {
    @State private var backgroundColor: Color = .blue.opacity(0.2)
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            NavigationStack {
                VStack (spacing: 50) {
                    Text("The assessment consists of eight parts. Some questions are easy, while others are more challenging and require a bit more concentration. If you need anything clarified, please approach a nearby caregiver.")
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .padding()
                        .multilineTextAlignment(.center)
                    Text("All The Best!")
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .padding()
                    NavigationLink(destination: MemoryView())
                    {
                        Text("Proceed")
                            .font(.system(size: 35, weight: .semibold, design: .rounded))
                            .frame(width: 300, height: 60)
                            .padding()
                            .cornerRadius(10)
                    }
                }
                .padding(150)
            }
        }
    }
}

