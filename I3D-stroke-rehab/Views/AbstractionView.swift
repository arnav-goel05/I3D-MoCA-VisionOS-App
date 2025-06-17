//
//  AbstractionView.swift
//  I3D-stroke-rehab

import SwiftUI

struct TaskItem {
    let title: String
    let question: String
    let correctAnswer: String
    var isCorrect: Bool
}
struct AbstractionView: View {
    
    struct TaskItem {
        let title: String
        let question: String
        let imageOne: String
        let imageTwo: String
    }
    
    private let taskItems: [TaskItem] = [
        TaskItem(
            title: "Task 1",
            question: "train - bicycle",
            imageOne: "train",
            imageTwo: "bicycle",
        ),
        TaskItem(
            title: "Task 2",
            question: "watch - ruler",
            imageOne: "watch",
            imageTwo: "ruler",
        )
    ]
    
    @State private var currentIndex = 0
    @State private var userInput = ""
    @State private var backgroundColor: Color = .blue.opacity(0.2)
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("Abstraction")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                
                Text("Similarity between e.g. banana – orange = fruit")
                    .font(.system(size: 35, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                if currentIndex >= taskItems.count {
                    NavigationStack {
                        Text("🎉 You’re done!")
                            .font(.system(size: 35, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                            .padding(.bottom, 50)
                            .padding([.leading, .trailing], 100)
                            .multilineTextAlignment(.center)
                        
                        NavigationLink(destination: OrrientationView()) {
                            Text("Next Activity")
                                .font(.system(size: 35, weight: .semibold, design: .rounded))
                                .frame(width: 300, height: 60)
                                .padding()
                                .cornerRadius(10)
                        }
                    }
                } else {
                    let task = taskItems[currentIndex]
                    
                    HStack(spacing: 35) {
                        VStack (spacing: 20) {
                            Image(task.imageOne)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(20)
                            Text("Train")
                                .font(.system(size: 30, weight: .medium, design: .rounded))
                        }
                        VStack (spacing: 20) {
                            Image(task.imageTwo)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(20)
                            Text("Bicycle")
                                .font(.system(size: 30, weight: .medium, design: .rounded))
                        }
                        .padding(20)
                    }
                    
                    HStack(spacing: 40) {
                        TextField("Type your answer…", text: $userInput)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 600)
                            .submitLabel(.done)
                            .controlSize(.large)
                            .accessibilityLabel("Answer")
                        
                        Button(action: {
                            validateAnswer(for: task)
                        }) {
                            Text("Submit")
                                .font(.system(size: 30, weight: .semibold, design: .rounded))
                                .frame(width: 200, height: 60)
                                .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .cornerRadius(20)
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
            backgroundColor = currentIndex == taskItems.count ? .green.opacity(0.2) : .blue.opacity(0.2)
        }
    }
}
