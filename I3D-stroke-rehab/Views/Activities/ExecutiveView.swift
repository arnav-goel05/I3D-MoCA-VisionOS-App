//
//  ExecutiveView.swift
//  I3D-stroke-rehab
//
//  Created by interactive 3d design on 19/6/25.
//

import SwiftUI

struct ExecutiveView: View {
    enum EraserType {
        case pixel
        case line
    }

    @StateObject private var manager = TaskManager()
    @State private var isErasing = false
    @State private var eraserType: EraserType = .pixel
    @State private var lineWidth: Double = 10.0

    var body: some View {
        ZStack {
            manager.backgroundColor
                .ignoresSafeArea()

            VStack {
                TaskHeaderView(title: "Executive Function", subtitle: "Draw a clock showing ten past eleven")

                Spacer()

                if manager.currentIndex >= 1 {
                    CompletionView(completionText: "🎉 You’re done!", buttonText: "Next Task", destination: OrrientationView())
                } else {
                    DrawingCanvas(isErasing: $isErasing, eraserType: $eraserType, lineWidth: $lineWidth)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding()

                    HStack(spacing: 20) {
                        Button(action: { isErasing = false }) {
                            Image(systemName: "pencil")
                                .font(.title)
                        }
                        .foregroundColor(!isErasing ? .blue : .gray)

                        Button(action: {
                            isErasing = true
                            eraserType = .pixel
                        }) {
                            Image(systemName: "eraser")
                                .font(.title)
                        }
                        .foregroundColor(isErasing && eraserType == .pixel ? .blue : .gray)

                        Button(action: {
                            isErasing = true
                            eraserType = .line
                        }) {
                            Image(systemName: "trash")
                                .font(.title)
                        }
                        .foregroundColor(isErasing && eraserType == .line ? .blue : .gray)

                        Slider(value: $lineWidth, in: 1...20) {
                            Text("Width")
                        }
                        .frame(width: 200)
                        
                        Text(String(format: "%.0f", lineWidth))
                            .frame(width: 35, alignment: .leading)
                    }
                    .padding()

                    Button(action: {
                        manager.nextTask(total: 1)
                    }) {
                        Text("Submit")
                            .buttonTextStyle()
                    }
                    .padding()
                }

                Spacer()
            }
        }
    }
}

struct Line {
    var points: [CGPoint]
    var color: Color
    var lineWidth: Double
}

struct DrawingCanvas: View {
    @Binding var isErasing: Bool
    @Binding var eraserType: ExecutiveView.EraserType
    @Binding var lineWidth: Double
    @State private var lines = [Line]()
    @State private var currentPoints = [CGPoint]()

    var body: some View {
        Canvas { context, size in
            for line in lines {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
            }

            var currentPath = Path()
            currentPath.addLines(currentPoints)
            let currentColor = isErasing && eraserType == .pixel ? Color.white : Color.black
            context.stroke(currentPath, with: .color(currentColor), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged {
                    if !(isErasing && eraserType == .line) {
                        currentPoints.append($0.location)
                    }
                }
                .onEnded { value in
                    if isErasing && eraserType == .line {
                        deleteLine(at: value.location)
                    } else {
                        let color = isErasing ? Color.white : Color.black
                        let newLine = Line(points: currentPoints, color: color, lineWidth: lineWidth)
                        lines.append(newLine)
                        currentPoints = []
                    }
                }
        )
    }

    private func deleteLine(at point: CGPoint) {
        var lineIndexToDelete: Int? = nil
        var minDistance: CGFloat = .infinity

        for (index, line) in lines.enumerated() {
            for p in line.points {
                let distance = point.distance(to: p)
                if distance < minDistance {
                    minDistance = distance
                    lineIndexToDelete = index
                }
            }
        }

        if let index = lineIndexToDelete, minDistance < 20 {
            lines.remove(at: index)
        }
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
