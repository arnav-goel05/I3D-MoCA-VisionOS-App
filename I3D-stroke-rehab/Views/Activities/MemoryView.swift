//
//  MemoryView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 17/6/25.
//

import SwiftUI

struct MemoryView: View {
    
    @EnvironmentObject var activityManager: ActivityManager
    @StateObject private var manager = TaskManager(total: 4)
    
    let listOfWords = "Face Silk Church Rose Red"
    
    var body: some View {
        ZStack {
            manager.backgroundColor
                .ignoresSafeArea()
            
            VStack (spacing: 50) {
                
                TaskHeaderView(title: "Memory", subtitle: nil)
                
                Spacer()
                
                if manager.currentIndex == 4 {
                    CompletionView(completionText: "🎉 You’re done! Remember these 5 words, we will be asking them later on in the test.", buttonText: "Next Task", onButtonTapped: {
                        activityManager.nextActivity(index: 3)
                    }, destination: AttentionView())
                } else if manager.currentIndex == 2 {
                    Text("Lets do it once again! Here are a list of words. Try your best to remember them all for now and later on in the test.")
                        .subtitleTextStyle()
                    
                    ZStack {
                        Text("Face")
                            .position(x: 300, y: 100)
                            .subtitleTextStyle()
                        Text("Church")
                            .position(x: 500, y: 100)
                            .subtitleTextStyle()
                        Text("Red")
                            .position(x: 700, y: 100)
                            .subtitleTextStyle()
                        Text("Silk")
                            .position(x: 400, y: 200)
                            .subtitleTextStyle()
                        Text("Rose")
                            .position(x: 600, y: 200)
                            .subtitleTextStyle()
                    }
                    .frame(width: 1000, height: 300)
                    .background(Color(red: 30/255, green: 44/255, blue:  56/255,))
                    .cornerRadius(20)
                    
                    Button(action: {
                        manager.currentIndex += 1
                    }) {
                        Text("Proceed")
                            .buttonTextStyle()
                    }
                } else if (manager.currentIndex == 1 || manager.currentIndex == 3) {
                    VStack (spacing: 40) {
                        Text("Enter the words previously shown in any order.")
                            .subtitleTextStyle()
                        
                        AnswerInputView(title: "Type your answer…", userInput: $manager.userInput) {
                            manager.nextTask()
                        }
                    }
                } else {
                    Text("Here are a list of words. Try your best to remember them all for now and later on in the test.")
                        .subtitleTextStyle()
                    
                    ZStack {
                        Text("Face")
                            .position(x: 300, y: 100)
                            .subtitleTextStyle()
                        Text("Church")
                            .position(x: 500, y: 100)
                            .subtitleTextStyle()
                        Text("Red")
                            .position(x: 700, y: 100)
                            .subtitleTextStyle()
                        Text("Silk")
                            .position(x: 400, y: 200)
                            .subtitleTextStyle()
                        Text("Rose")
                            .position(x: 600, y: 200)
                            .subtitleTextStyle()
                    }
                    .frame(width: 1000, height: 300)
                    .background(Color(red: 30/255, green: 44/255, blue:  56/255,))
                    .cornerRadius(30)
                    
                    Button(action: {
                        manager.currentIndex += 1
                    }) {
                        Text("Proceed")
                            .buttonTextStyle()
                    }
                }
                
                Spacer()
                
            }
            .padding()
        }
    }
}
