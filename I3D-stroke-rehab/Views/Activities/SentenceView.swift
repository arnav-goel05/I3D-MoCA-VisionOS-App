//
//  SentenceView.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 25/6/25.
//

import SwiftUI
import AVFoundation
import Speech

struct SentenceView: View {
    @State private var sentences = [
        "I only know that John is the one to help today.",
        "The cat always hid under the couch when dogs were in the room."
    ]

    @State private var currentSentenceIndex = 0
    @State private var userInput = ""
    @State private var feedback = ""
    @State private var score = 0

    @State private var isRecording = false
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    let audioEngine = AVAudioEngine()

    var body: some View {
        VStack(spacing: 30) {
            Text("🗣️ MoCA Language Test")
                .font(.largeTitle)
                .bold()

            Text("Repeat this sentence:")
                .font(.title2)

            Text(sentences[currentSentenceIndex])
                .italic()
                .padding()

            TextField("Type what you repeated or use mic", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(width: 300)

            HStack(spacing: 20) {
                Button(action: {
                    isRecording ? stopRecording() : startRecordingSafely()
                }) {
                    Text(isRecording ? "Stop Recording" : "🎙️ Start Voice Input")
                }

                Button("Submit") {
                    checkAnswer()
                }
                .keyboardShortcut(.defaultAction)
            }

            if !feedback.isEmpty {
                Text(feedback)
                    .font(.title2)
                    .foregroundColor(.blue)

                Button("Next") {
                    goToNextSentence()
                }
            }
        }
        .onAppear {
            requestPermissions()
        }
        .padding()
        .glassBackgroundEffect()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("Speech recognition not authorized")
            }
        }
    }

    private func startRecordingSafely() {
        #if targetEnvironment(simulator)
        feedback = "⚠️ Voice input not supported in Vision Pro simulator."
        return
        #else
        startRecording()
        #endif
    }

    private func startRecording() {
        userInput = ""
        feedback = ""
        isRecording = true

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) {
            buffer, _ in recognitionRequest.append(buffer)
        }

        do {
            try audioEngine.start()
        } catch {
            feedback = "⚠️ Could not start audio engine: \(error.localizedDescription)"
            isRecording = false
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                userInput = result.bestTranscription.formattedString
            }
            if error != nil || (result?.isFinal ?? false) {
                stopRecording()
            }
        }
    }

    private func stopRecording() {
        isRecording = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }

    private func checkAnswer() {
        let target = sentences[currentSentenceIndex].lowercased()
        let user = userInput.lowercased()

        let similarity = stringSimilarity(a: target, b: user)

        if similarity > 0.8 {
            score += 1
            feedback = "✅ Great! You repeated the sentence correctly."
        } else {
            feedback = "❌ Try again. The sentence was: \"\(target)\""
        }
    }

    private func goToNextSentence() {
        currentSentenceIndex += 1
        userInput = ""
        feedback = ""

        if currentSentenceIndex >= sentences.count {
            feedback = "Language Test Completed. Score: \(score)/\(sentences.count)"
        }
    }

    private func stringSimilarity(a: String, b: String) -> Double {
        let aWords = a.split(separator: " ")
        let bWords = b.split(separator: " ")
        let matches = aWords.filter { bWords.contains($0) }.count
        return Double(matches) / Double(max(aWords.count, 1))
    }
}

#Preview {
    SentenceView()
}
