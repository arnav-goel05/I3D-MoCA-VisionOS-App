//
//  MemoryView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 17/6/25.
//

import SwiftUI

struct MemoryView: View {
    
    let listOfWords = "Face Silk Church Rose Red"
    
    @State private var backgroundColor: Color = .blue.opacity(0.2)
    @State private var currentIndex = 0
    @State private var userInput = ""
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack (spacing: 50) {
                
                Text("Memory")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                
                Spacer()
                
                if currentIndex == 4 {
                    NavigationStack {
                        Text("🎉 You’re done! Remember these 5 words, we will be asking them later on in the test.")
                            .font(.system(size: 35, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                            .padding(.bottom, 50)
                            .padding([.leading, .trailing], 100)
                            .multilineTextAlignment(.center)
                        
                        NavigationLink(destination: AbstractionView()) {
                            Text("Next Activity")
                                .font(.system(size: 35, weight: .semibold, design: .rounded))
                                .frame(width: 300, height: 60)
                                .padding()
                                .cornerRadius(10)
                        }
                    }
                } else if currentIndex == 2 {
                    Text("Lets do it once again! Here are a list of words. Try your best to remember them all for now and later on in the test.")
                        .font(.system(size: 35, weight: .semibold, design: .rounded))
                        .padding([.leading, .trailing], 100)
                        .multilineTextAlignment(.center)
                    
                    List {
                        Text("Face")
                        Text("Silk")
                        Text("Church")
                        Text("Rose")
                        Text("Red")
                    }
                    .font(.system(size: 35, weight: .regular, design: .rounded))
                    .padding([.leading, .trailing], 150)
                
                    Button(action: {
                        currentIndex += 1
                    }) {
                        Text("Proceed")
                            .font(.system(size: 35, weight: .semibold, design: .rounded))
                            .frame(width: 300, height: 60)
                            .padding()
                            .cornerRadius(10)
                    }

                } else if (currentIndex == 1 || currentIndex == 3) {
                    VStack (spacing: 40) {
                        Text("Enter the words previously shown in any order.")
                            .font(.system(size: 35, weight: .semibold, design: .rounded))
                            .padding()
                        
                        HStack(spacing: 40) {
                            TextField("Type your answer…", text: $userInput)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 600)
                                .submitLabel(.done)
                                .controlSize(.large)
                                .accessibilityLabel("Answer")
                            
                            Button(action: {
                                currentIndex += 1
                                if currentIndex == 4 {
                                    backgroundColor = .green.opacity(0.2)
                                }
                            }) {
                                Text("Submit")
                                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                                    .frame(width: 200, height: 60)
                                    .cornerRadius(12)
                            }
                        }
                    }
                } else {
                    Text("Here are a list of words. Try your best to remember them all for now and later on in the test.")
                        .font(.system(size: 35, weight: .semibold, design: .rounded))
                        .padding([.leading, .trailing], 100)
                        .multilineTextAlignment(.center)
                    
                    List {
                        Text("Face")
                        Text("Silk")
                        Text("Church")
                        Text("Rose")
                        Text("Red")
                    }
                    .font(.system(size: 35, weight: .regular, design: .rounded))
                    .padding([.leading, .trailing], 150)
                
                    Button(action: {
                        currentIndex += 1
                    }) {
                        Text("Proceed")
                            .font(.system(size: 35, weight: .semibold, design: .rounded))
                            .frame(width: 300, height: 60)
                            .padding()
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
                
            }
            .padding()
        }
    }
    
    private func validateAnswer(for task: TaskItem) {
        let _ = userInput
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            currentIndex += 1
            userInput = ""
            //backgroundColor = currentIndex == taskItems.count ? .green.opacity(0.2) : .blue.opacity(0.2)
        }
    }
}

