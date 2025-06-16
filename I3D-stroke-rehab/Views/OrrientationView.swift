//
//  OrrientationView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 13/6/25.
//

import SwiftUI

struct OrrientationView: View {
    
    struct TaskItem {
        let title: String
        let question: String
    }
    
    @State private var currentIndex = 0
    @State private var userInput = ""
    @State private var backgroundColor: Color = .blue.opacity(0.2)
    
    private let taskItems: [TaskItem] = [
        TaskItem(
            title: "Task 1",
            question: "What date is it today? (e.g. 1, 2)",
        ),
        TaskItem(
            title: "Task 2",
            question: "What month is it today? (e.g. January, February)",
        ),
        TaskItem(
            title: "Task 3",
            question: "What year is it today (e.g. 2001, 2002) ",
        ),
        TaskItem(
            title: "Task 4",
            question: "What day is it today (e.g. Monday, Tuesday)",
        ),
        TaskItem(
            title: "Task 5",
            question: "Where are you right now? (e.g. office, home)",
        ),
        TaskItem(
            title: "Task 6",
            question: "What country are you in right now? (India, China)",
        )
    ]
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack {
                Text("Orientation")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                
                Spacer()
                
                if currentIndex >= taskItems.count {
                    NavigationStack {
                        Text("🎉 You’re done!")
                            .font(.system(size: 35, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                            .padding(.bottom, 30)
                        
                        NavigationLink(destination: ContentView()) {
                            Text("Restart Assessment")
                                .font(.system(size: 35, weight: .semibold, design: .rounded))
                                .cornerRadius(10)
                                .padding()
                        }
                    }
                } else {
                    let task = taskItems[currentIndex]
                    
                    Text("\(task.title): \(task.question)")
                        .font(.system(size: 35, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 60)
                    
                    HStack(spacing: 40) {
                        TextField("Type your answer…", text: $userInput)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 600)
                            .submitLabel(.done)
                            .controlSize(.large)
                        
                        Button(action: {
                            validateAnswer(for: task)
                        }) {
                            Text("Submit")
                                .font(.system(size: 30, weight: .semibold, design: .rounded))
                                .frame(width: 200, height: 60)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            userInput = ""
                        }) {
                            Text("Clear Text")
                                .font(.system(size: 30, weight: .semibold, design: .rounded))
                                .frame(width: 300, height: 60)
                                .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                }
            }
    
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
