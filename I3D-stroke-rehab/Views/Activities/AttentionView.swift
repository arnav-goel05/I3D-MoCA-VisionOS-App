//
//  AttentionView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 24/6/25.
//

import SwiftUI

struct AttentionView: View {
    
    @StateObject private var manager = TaskManager(total: 7)
    @EnvironmentObject var activityManager: ActivityManager
    
    private let tasks: [TaskItem] = [
        TaskItem(title: "Task 1", question: "Repeat them in forward order", imageOne: nil, imageTwo: nil),
        TaskItem(title: "Task 2", question: "Repeat them in backward order", imageOne: nil, imageTwo: nil),
        TaskItem(title: "Task 3", question: "Tap button at each number 1", imageOne: nil, imageTwo: nil),
        TaskItem(title: "Task 4", question: "Serial 7 subtraction starting at 100", imageOne: nil, imageTwo: nil)
    ]
    
    let forwardOrderNumList = "2 1 8 5 4"
    let backwardOrderNumList = "7 4 2"
    let tappingOneNumList = [6, 2, 1, 3, 7, 8, 1, 1, 9, 7, 6, 2, 1, 6, 1, 7, 4, 5, 1, 1, 1, 9, 1, 7, 9, 6, 1, 1, 2]
    let subtractionNumList = [93, 86, 79, 72, 65]
    @State private var selectedIndices: Set<Int> = []
    @State private var taskThreeIndex = 0
    
    var body: some View {
        ZStack {
            manager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                TaskHeaderView(title: "Attention", subtitle: nil)
                
                Spacer()
                
                if manager.currentIndex == 0 || manager.currentIndex == 2 || manager.currentIndex == 4 || manager.currentIndex == 6 {
                    let task = tasks[manager.currentIndex / 2]
                    
                    Text(task.question)
                        .subtitleTextStyle()
                    
                    if manager.currentIndex == 0 || manager.currentIndex == 2 {
                        Text(manager.currentIndex == 0 ? forwardOrderNumList : backwardOrderNumList)
                            .titleTextStyle()
                            .padding(50)
                    }
                    
                    if manager.currentIndex == 6 {
                        HStack(spacing: 12) {
                            ForEach(subtractionNumList.indices, id: \.self) { idx in
                                Button(action: {
                                    if selectedIndices.contains(idx) {
                                        selectedIndices.remove(idx)
                                    } else {
                                        selectedIndices.insert(idx)
                                    }
                                }) {
                                    Text("\(subtractionNumList[idx])")
                                        .buttonTextStyle()
                                        .foregroundColor(
                                            selectedIndices.contains(idx)
                                            ? .green
                                            : .primary
                                        )
                                }
                            }
                        }.padding(50)
                    }
                
                    Button(action: {
                        manager.currentIndex += 1
                    }) {
                        Text("Proceed")
                            .buttonTextStyle()
                    }
                } else if manager.currentIndex == 1 || manager.currentIndex == 3 {
                    let task = tasks[(manager.currentIndex - 1) / 2]
                    
                    VStack (spacing: 40) {
                        Text(task.question)
                            .subtitleTextStyle()
                        
                        AnswerInputView(title: "Type your answer…", userInput: $manager.userInput) {
                            manager.nextTask()
                        }
                    }
                } else if manager.currentIndex == 5 {
                    
                    Text(tasks[2].question)
                        .subtitleTextStyle()
                    
                    Text("\(taskThreeIndex + 1)th Number: \(tappingOneNumList[taskThreeIndex])")
                        .titleTextStyle()
                        .padding(50)
                
                    if taskThreeIndex < tappingOneNumList.count - 1 {
                        HStack(spacing: 20) {
                            Button(action: {
                                taskThreeIndex += 1
                            }) {
                                Text("Select Number")
                                    .buttonTextStyle()
                            }
                            Button(action: {
                                taskThreeIndex += 1
                            }) {
                                Text("Next")
                                    .buttonTextStyle()
                            }
                        }
                    } else {
                        Button(action: {
                            manager.currentIndex += 1
                        }) {
                            Text("Proceed")
                                .buttonTextStyle()
                        }
                    }

                } else {
                    CompletionView(completionText: "🎉 You’re done!", buttonText: "Next Task", onButtonTapped: {
                        activityManager.nextActivity(index: 4)
                    }, destination: AbstractionView())
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
