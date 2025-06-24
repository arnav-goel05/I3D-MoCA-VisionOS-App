//
//  ExecutiveView.swift
//  I3D-stroke-rehab
//
//  Created by interactive 3d design on 19/6/25.
//

import SwiftUI

struct ExecutiveView: View {
    @StateObject private var manager = TaskManager(total: 1)
    @EnvironmentObject var activityManager: ActivityManager
    
    @State private var isErasing = false
    @State private var lineWidth: Double = 10.0
    @State private var lines = [Line]()

    var body: some View {
        ZStack {
            manager.backgroundColor
                .ignoresSafeArea()

            VStack {
                
                TaskHeaderView(title: "Executive", subtitle: "Draw a clock showing ten past eleven.")
                
                Spacer()

                if manager.currentIndex >= 1 {
                    CompletionView(completionText: "🎉 You're done!", buttonText: "Next Task", onButtonTapped: {
                        activityManager.nextActivity(index: 1)
                    }, destination: MemoryView())
                } else {
                        DrawingCanvas(isErasing: $isErasing, lineWidth: $lineWidth, lines: $lines)
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
                                    }) {
                                        Image(systemName: "eraser")
                                            .font(.title)
                                    }
                                    .foregroundColor(isErasing ? .blue : .gray)

                        Button(action: {
                            lines.removeAll()
                        }) {
                            Image(systemName: "trash")
                                        .font(.title)
                            }
                            .foregroundColor(.red)

                        Slider(value: $lineWidth, in: 1...20) {
                            Text("Width")
                            }
                            .frame(width: 200)

                        Text(String(format: "%.0f", lineWidth))
                        .frame(width: 35, alignment: .leading)
                                }
                    .padding()

                                HStack {
                                    Button(action: {
                                        // Navigate to 3D Painting view
                                        manager.show3DPainting = true
                                    }) {
                                        Text("3D Painting")
                                            .buttonTextStyle()
                                    }
                                    .padding(.trailing, 10)

                                    Button(action: {
                                        manager.nextTask()
                                    }) {
                                        Text("Submit")
                                            .buttonTextStyle()
                                    }
                                }
                                .padding()
                                .navigationDestination(isPresented: $manager.show3DPainting) {
                                    _3DPaintView()
                                }
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
    @Binding var lineWidth: Double
    @Binding var lines: [Line]
    @State private var currentPoints = [CGPoint]()

    private var effectiveLineWidth: Double {
        isErasing ? lineWidth * 4 : lineWidth
    }

    var body: some View {
        Canvas { context, size in
            for line in lines {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
            }

            var currentPath = Path()
            currentPath.addLines(currentPoints)
            let currentColor = isErasing ? Color.white : Color.black
            context.stroke(currentPath, with: .color(currentColor), style: StrokeStyle(lineWidth: effectiveLineWidth, lineCap: .round, lineJoin: .round))
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged {
                    currentPoints.append($0.location)
                }
                .onEnded { value in
                    let color = isErasing ? Color.white : Color.black
                    let newLine = Line(points: currentPoints, color: color, lineWidth: effectiveLineWidth)
                    lines.append(newLine)
                    currentPoints = []
                }
        )
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
