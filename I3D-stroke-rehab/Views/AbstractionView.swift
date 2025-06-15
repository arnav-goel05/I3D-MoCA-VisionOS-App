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

//test

struct AbstractionView: View {
    @State private var taskItems: [TaskItem] = [
        TaskItem(title: "Task 1", question: "Question: [ ] train - bicycle", correctAnswer: "vehicle", isCorrect: false),
        TaskItem(title: "Task 2", question: "Question: [ ] watch - ruler", correctAnswer: "measure", isCorrect: false)
    ]

    @State private var selectedTaskIndex = 0
    @State private var userInput = ""
    @State private var feedbackMessage = ""
    @State private var isCorrect = false
       
    var body: some View {
        VStack(spacing: 32) {
            
            VStack(spacing: 8) {
                Text("Abstraction")
                    .font(.largeTitle.bold())
                
                Text("Similarity between eg.banana - orange = fruit")
                    .font(.title3)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 32) {
                ForEach(0..<taskItems.count) { index in
                    Button(action: {
                        selectedTaskIndex = index
                        userInput = ""
                        feedbackMessage = ""
                    }) {
                        Text(taskItems[index].title)
                            .padding(10)
                            .foregroundStyle(taskItems[index].isCorrect ? .green : (selectedTaskIndex == index ? .blue : .white))
                            .frame(width: 200)
                    }
                }
            }
        }
        
        Spacer()
        
        VStack {
            Group {
                Text(taskItems[selectedTaskIndex].question)
                        .font(.title)
            }
        }
        
        Spacer()
            
        VStack(spacing: 20) {
            HStack(spacing: 25){
                TextField("Type your answer here…", text: $userInput)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .frame(maxWidth: 500)
                
                Button(action: validateAnswer) {
                    Text("Submit")
                        .font(.title3)
                }
            }
            
            if !feedbackMessage.isEmpty {
                Text(feedbackMessage)
                    .font(.headline)
                    .foregroundColor(isCorrect ? .green : .red)
            }
        }
        
        Spacer()
    }
    
    func validateAnswer() {
        let userInputLowercased = userInput.lowercased()
        
        if userInputLowercased == taskItems[selectedTaskIndex].correctAnswer {
            feedbackMessage = "Correct! Procced to next task."
            taskItems[selectedTaskIndex].isCorrect = true
            isCorrect = true
        } else {
            feedbackMessage = "Wrong. Please try again."
            isCorrect = false

        }
    }
    
}
