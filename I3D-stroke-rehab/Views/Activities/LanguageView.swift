//
//  LanguageView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 22/6/25.
//
// Spatial Demo App for Apple Vision Pro using WindowGroup (fixes ImmersiveSpace issue)

import SwiftUI
import RealityKit
import AVFoundation

struct Animal: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct AnimalTypingGameImmersive: View {
    @State private var animals: [Animal] = [
        Animal(name: "elephant", imageName: "elephant"),
        Animal(name: "penguin", imageName: "penguin"),
        Animal(name: "giraffe", imageName: "giraffe"),
        Animal(name: "tiger", imageName: "tiger"),
        Animal(name: "koala", imageName: "koala")
    ]

    @State private var currentAnimalIndex = 0
    @State private var userInput = ""
    @State private var feedback = ""
    @State private var score = 0
    @State private var showFeedback = false

    @State private var correctSound: AVAudioPlayer? = nil
    @State private var incorrectSound: AVAudioPlayer? = nil

    var body: some View {
        VStack(spacing: 30) {
            Text("🐾 Name That Animal!")
                .font(.largeTitle)
                .bold()

            if currentAnimalIndex < animals.count {
                Image(animals[currentAnimalIndex].imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)

                TextField("Type the animal name", text: $userInput)
                    .frame(width: 300)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Submit") {
                    checkAnswer()
                }
                .keyboardShortcut(.defaultAction)

                if showFeedback {
                    Text(feedback)
                        .font(.title)
                        .foregroundColor(feedback == "Correct!" ? .green : .red)

                    Button("Next") {
                        nextAnimal()
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Text("🎉 Game Over!")
                        .font(.largeTitle)
                        .bold()
                    Text("Your Score: \(score)/\(animals.count)")
                        .font(.title2)
                    Button("Play Again") {
                        resetGame()
                    }
                }
            }
        }
        .onAppear {
            loadSounds()
        }
        .padding()
        .glassBackgroundEffect()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func loadSounds() {
        if let correctURL = Bundle.main.url(forResource: "correct", withExtension: "mp3") {
            correctSound = try? AVAudioPlayer(contentsOf: correctURL)
        }
        if let incorrectURL = Bundle.main.url(forResource: "wrong", withExtension: "mp3") {
            incorrectSound = try? AVAudioPlayer(contentsOf: incorrectURL)
        }
    }

    func checkAnswer() {
        let correct = animals[currentAnimalIndex].name.lowercased()
        let guess = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if guess == correct {
            feedback = "Correct!"
            score += 1
            correctSound?.play()
        } else {
            feedback = "Oops! It was \"\(correct)\""
            incorrectSound?.play()
        }
        showFeedback = true
    }

    func nextAnimal() {
        currentAnimalIndex += 1
        userInput = ""
        feedback = ""
        showFeedback = false
    }

    func resetGame() {
        currentAnimalIndex = 0
        userInput = ""
        feedback = ""
        score = 0
        showFeedback = false
    }
}

#Preview {
    AnimalTypingGameImmersive()
}
