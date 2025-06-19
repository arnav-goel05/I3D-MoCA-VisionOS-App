//
//  AbstractionView.swift
//  I3D-stroke-rehab

import SwiftUI

struct AbstractionView: View {
    
    @StateObject private var manager = TaskManager()
    
    private let tasks: [TaskItem] = [
        TaskItem(title: "Task 1", question: "train - bicycle", imageOne: "train", imageTwo: "bicycle"),
        TaskItem(title: "Task 2", question: "watch - ruler", imageOne: "watch", imageTwo: "ruler")
    ]
    
    var body: some View {
        ZStack {
            manager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                TaskHeaderView(title: "Abstraction", subtitle: "Similarity between e.g. banana – orange = fruit")
                
                Spacer()
                
                if manager.currentIndex >= tasks.count {
                    CompletionView(completionText: "🎉 You’re done!", buttonText: "Next Task", destination: ExecutiveView())
                } else {
                    let task = tasks[manager.currentIndex]
                    
                    HStack(spacing: 35) {
                        VStack (spacing: 20) {
                            Image(task.imageOne!)
                                .imageStyle()
                            
                            Text(task.imageOne!)
                                .regularTextStyle()
                        }
                        VStack (spacing: 20) {
                            Image(task.imageTwo!)
                                .imageStyle()
                            
                            Text(task.imageTwo!)
                                .regularTextStyle()
                        }
                        .padding(20)
                    }
                    
                    AnswerInputView(title: "Type your answer…", userInput: $manager.userInput) {
                        manager.nextTask(total: tasks.count)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
