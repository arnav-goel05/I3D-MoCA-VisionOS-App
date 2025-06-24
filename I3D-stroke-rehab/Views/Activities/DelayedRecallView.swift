import SwiftUI

struct DelayedRecallView: View {
    
    @StateObject private var manager = TaskManager(total: 3)
    @EnvironmentObject var activityManager: ActivityManager
    
    private let correctWords = ["Face", "Silk", "Church", "Rose", "Red"]
    private let categoryCues: [String: String] = [
        "Face": "Part of the body",
        "Silk": "Type of fabric",
        "Church": "Type of building",
        "Rose": "Type of flower",
        "Red": "Type of colour"
    ]
    
    private let multipleChoices: [String: [String]] = [
        "Face": ["Nose", "Face", "Hand"],
        "Silk": ["Denim", "Cotton", "Silk"],
        "Church": ["Church", "School", "Hospital"],
        "Rose": ["Daisy", "Rose", "Tulip"],
        "Red": ["Red", "Blue", "Green"]
    ]
    
    @State private var currentWordIndex = 0
    @State private var recallStage: Int = 0  // 0: uncued, 1: category, 2: MCQ
    @State private var input: String = ""
    @State private var recalledWithoutCue: [String] = []
    @State private var recalledWithCue: [String] = []
    @State private var finalRecallComplete = false
    
    var body: some View {
        ZStack {
            manager.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                TaskHeaderView(title: "Delayed Recall", subtitle: stageTitle())
                
                Spacer()
                
                if finalRecallComplete {
                    
                    CompletionView(completionText: "🎉 You’re done for this part of the test", buttonText: "Next Task", onButtonTapped: {
                        activityManager.nextActivity(index: 7)
                    }, destination: OrientationView())
                    
                } else {
                    Text(currentPrompt())
                        .subtitleTextStyle()
                    
                    if recallStage < 2 {
                        TextField("Your answer...", text: $input)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        
                        Button("Submit") {
                            handleSubmit()
                        }
                        .buttonTextStyle()
                        
                    } else {
                        // Multiple choice stage
                        let word = correctWords[currentWordIndex]
                        Picker("Select the correct word", selection: $input) {
                            ForEach(multipleChoices[word] ?? [], id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        Button("Submit") {
                            handleSubmit()
                        }
                        .buttonTextStyle()
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Delayed Recall")
    }
    
    // MARK: - Helpers
    
    private func handleSubmit() {
        let expected = correctWords[currentWordIndex]
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
        
        // Correct at this stage
        if trimmedInput == expected {
            if recallStage == 0 {
                recalledWithoutCue.append(expected)
            } else {
                recalledWithCue.append(expected)
            }
            moveToNextWord()
        } else {
            // Incorrect, move to next stage for the same word
            if recallStage < 2 {
                recallStage += 1
                input = ""
            } else {
                // After 3rd try, move on without recalling
                moveToNextWord()
            }
        }
    }
    
    private func moveToNextWord() {
        input = ""
        recallStage = 0
        currentWordIndex += 1
        if currentWordIndex >= correctWords.count {
            finalRecallComplete = true
        }
    }
    
    private func currentPrompt() -> String {
        let word = correctWords[currentWordIndex]
        
        switch recallStage {
        case 0: return "Try to recall word \(currentWordIndex + 1) without any hints."
        case 1: return "Hint: \(categoryCues[word] ?? "")"
        case 2: return "Choose the correct word for: \(categoryCues[word] ?? "")"
        default: return ""
        }
    }
    
    private func stageTitle() -> String {
        switch recallStage {
        case 0: return "Uncued Recall"
        case 1: return "Category Cue"
        case 2: return "Multiple Choice"
        default: return ""
        }
    }
}
