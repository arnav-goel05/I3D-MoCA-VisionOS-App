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
                    
                    List {
                        Text("Face")
                        Text("Silk")
                        Text("Church")
                        Text("Rose")
                        Text("Red")
                    }
                    .subtitleTextStyle()
                    
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
                    
                    List {
                        Text("Face")
                        Text("Silk")
                        Text("Church")
                        Text("Rose")
                        Text("Red")
                    }
                    .subtitleTextStyle()
                
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
