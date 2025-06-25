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
        TaskItem(title: "Task 1", question: "Repeat the numbers in forward order.", imageOne: nil, imageTwo: nil),
        TaskItem(title: "Task 2", question: "Repeat the numbers in backward order.", imageOne: nil, imageTwo: nil),
        TaskItem(title: "Task 3", question: "A sequence of numbers will be displayed. Tap the button 'Select Number' each time you see the number 1. Do not select the button when you see a different number.", imageOne: nil, imageTwo: nil),
        TaskItem(title: "Task 4", question: "Count backward by 7's from 100 for 5 times and write those numbers down below.", imageOne: nil, imageTwo: nil)
    ]
    
    let tappingOneNumList = [6, 2, 1, 3, 7, 8, 1, 1, 9, 7, 6, 2, 1, 6, 1, 7, 4, 5, 1, 1, 1, 9, 1, 7, 9, 6, 1, 1, 2]
    let subtractionNumList = [93, 86, 79, 72, 65]
    @State private var selectedIndices: Set<Int> = []
    @State private var taskThreeIndex = 0
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        ZStack {
            manager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                TaskHeaderView(title: "Attention", subtitle: nil)
                
                Spacer()
                
                if manager.currentIndex == 0 || manager.currentIndex == 2 || manager.currentIndex == 4 {
                    let task = tasks[manager.currentIndex / 2]
                    
                    Text(task.question)
                        .subtitleTextStyle()
                        .padding(.bottom, 50)
                    
                    if manager.currentIndex == 0 {
                        ZStack {
                            Text("2")
                                .position(x: 300, y: 100)
                                .subtitleTextStyle()
                            Text("1")
                                .position(x: 400, y: 100)
                                .subtitleTextStyle()
                            Text("8")
                                .position(x: 500, y: 100)
                                .subtitleTextStyle()
                            Text("5")
                                .position(x: 600, y: 100)
                                .subtitleTextStyle()
                            Text("4")
                                .position(x: 700, y: 100)
                                .subtitleTextStyle()
                        }
                        .frame(width: 1000, height: 200)
                        .background(Color(red: 30/255, green: 44/255, blue:  56/255,))
                        .cornerRadius(30)
                    } else if manager.currentIndex == 2 {
                        ZStack {
                            Text("7")
                                .position(x: 300, y: 100)
                                .subtitleTextStyle()
                            Text("4")
                                .position(x: 400, y: 100)
                                .subtitleTextStyle()
                            Text("2")
                                .position(x: 500, y: 100)
                                .subtitleTextStyle()
                        }
                        .frame(width: 800, height: 200)
                        .background(Color(red: 30/255, green: 44/255, blue:  56/255,))
                        .cornerRadius(30)
                    }
                    
                    Button(action: {
                        manager.currentIndex += 1
                    }) {
                        Text("Proceed")
                            .buttonTextStyle()
                    }
                    .padding(.top, 50)
                    
                } else if manager.currentIndex == 1 || manager.currentIndex == 3 || manager.currentIndex == 6 {
                    let questionIndex: Int = {
                            switch manager.currentIndex {
                            case 6:
                                return manager.currentIndex / 2
                            case 1, 3:
                                return (manager.currentIndex - 1) / 2
                            default:
                                fatalError("Unexpected index")
                            }
                        }()
                    
                    let task = tasks[questionIndex]
                    
                    VStack (spacing: 40) {
                        Text(task.question)
                            .subtitleTextStyle()
                        
                        AnswerInputView(title: "Type your answer…", userInput: $manager.userInput) {
                            manager.nextTask()
                        }
                    }
                } else  if manager.currentIndex == 5 {
                    VStack(spacing: 40) {
                        Text(tasks[2].question)
                            .subtitleTextStyle()

                        Text("\(taskThreeIndex + 1)ᵗʰ Number: \(tappingOneNumList[taskThreeIndex])")
                            .subtitleTextStyle()
                            .padding(50)

                        Button(action: {}) {
                            Text("Tap 1")
                                .buttonTextStyle()
                        }
                    }
                    .onReceive(timer) { _ in
                        if taskThreeIndex < tappingOneNumList.count - 1 {
                            taskThreeIndex += 1
                        } else {
                            timer.upstream.connect().cancel()
                            manager.currentIndex += 1
                        }
                    }
                    .onAppear {
                        taskThreeIndex = 0
                        timer = Timer.publish(every: 1, on: .main, in: .common)
                                   .autoconnect()
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
