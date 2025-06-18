//
//  OrrientationView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 13/6/25.
//

import SwiftUI

struct OrrientationView: View {
    
    @StateObject private var manager = TaskManager()
    
    private let tasks: [TaskItem] = [
        TaskItem(title: "Task 1", question: "What date is it today? (e.g. 1, 2)", imageOne: nil, imageTwo: nil),
        TaskItem(title: "Task 2", question: "What month is it today? (e.g. January, February)", imageOne: nil, imageTwo: nil),
        TaskItem(title: "Task 3", question: "What year is it today (e.g. 2001, 2002)", imageOne: nil, imageTwo: nil),
        TaskItem(title: "Task 4", question: "What day is it today (e.g. Monday, Tuesday)", imageOne: nil, imageTwo: nil),
        TaskItem(title: "Task 5", question: "Where are you right now? (e.g. office, home)", imageOne: nil, imageTwo: nil),
        TaskItem(title: "Task 6", question: "What country are you in right now? (India, China)", imageOne: nil, imageTwo: nil)
    ]
    
    var body: some View {
        ZStack {
            manager.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                TaskHeaderView(title: "Orientation", subtitle: nil)
                
                Spacer()
                
                if manager.currentIndex >= tasks.count {
                    CompletionView(completionText: "🎉 You’re done!", buttonText: "Restart Assessment", destination: ContentView())
                } else {
                    let task = tasks[manager.currentIndex]
                    
                    Text("\(task.title): \(task.question)")
                        .subtitleTextStyle()
                        .padding(.bottom, 100)
                    
                    AnswerInputView(title: "Type your answer…", userInput: $manager.userInput) {
                        manager.nextTask(total: tasks.count)
                    }
            
                }
                
                Spacer()
            }
        }
    }
}
