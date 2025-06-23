import SwiftUI
import RealityKit
import ARKit

struct _3DPaintView: View {
    @StateObject var paintingHandTracking = PaintingHandTracking()
    @State var canvas = PaintingCanvas()
    @State var lastIndexPose: SIMD3<Float>?
    @State private var navigateToExecutive = false

    var body: some View {
        VStack {
            Text("Copy this cube in 3D")
                .font(.largeTitle)
                .padding(.top, 30)

            ZStack {
                GeometryReader { geometry in
                    let sideLength = min(geometry.size.width, geometry.size.height) * 1
                    let offset = sideLength * 0.4
                    
                    let cubeWidth = sideLength + offset
                    let cubeHeight = sideLength + offset
                    
                    let startX = (geometry.size.width - cubeWidth) / 2
                    let startY = (geometry.size.height - cubeHeight) / 2 + 130
                    
                    // Front square points
                    let frontTopLeft = CGPoint(x: startX, y: startY + offset)
                    let frontTopRight = CGPoint(x: startX + sideLength, y: startY + offset)
                    let frontBottomLeft = CGPoint(x: startX, y: startY + sideLength + offset)
                    let frontBottomRight = CGPoint(x: startX + sideLength, y: startY + sideLength + offset)
                    
                    // Back square points
                    let backTopLeft = CGPoint(x: startX + offset, y: startY)
                    let backTopRight = CGPoint(x: startX + sideLength + offset, y: startY)
                    let backBottomLeft = CGPoint(x: startX + offset, y: startY + sideLength)
                    let backBottomRight = CGPoint(x: startX + sideLength + offset, y: startY + sideLength)
                    
                    Path { path in
                        // Front face
                        path.move(to: frontTopLeft)
                        path.addLine(to: frontTopRight)
                        path.addLine(to: frontBottomRight)
                        path.addLine(to: frontBottomLeft)
                        path.closeSubpath()
                        
                        // Back face
                        path.move(to: backTopLeft)
                        path.addLine(to: backTopRight)
                        path.addLine(to: backBottomRight)
                        path.addLine(to: backBottomLeft)
                        path.closeSubpath()
                        
                        // Connecting lines
                        path.move(to: frontTopLeft); path.addLine(to: backTopLeft)
                        path.move(to: frontTopRight); path.addLine(to: backTopRight)
                        path.move(to: frontBottomLeft); path.addLine(to: backBottomLeft)
                        path.move(to: frontBottomRight); path.addLine(to: backBottomRight)
                    }
                    .stroke(Color.blue, lineWidth: 4)
                }
            }
            .frame(height: 300)
            .padding()

            RealityView { content in
                let root = canvas.root
                content.add(root)

                root.components.set(ClosureComponent(closure: { deltaTime in
                    var anchors = [HandAnchor]()

                    if let latestLeftHand = paintingHandTracking.latestLeftHand {
                        anchors.append(latestLeftHand)
                    }
                    if let latestRightHand = paintingHandTracking.latestRightHand {
                        anchors.append(latestRightHand)
                    }

                    var newPose: SIMD3<Float>?
                    for anchor in anchors {
                        guard let handSkeleton = anchor.handSkeleton else {
                            continue
                        }

                        let thumbPos = Transform(matrix: anchor.originFromAnchorTransform * handSkeleton.joint(.thumbTip).anchorFromJointTransform).translation
                        let indexPos = Transform(matrix: anchor.originFromAnchorTransform * handSkeleton.joint(.indexFingerTip).anchorFromJointTransform).translation

                        let pinchThreshold: Float = 0.05
                        if length(thumbPos - indexPos) < pinchThreshold {
                            newPose = indexPos
                            break
                        }
                    }
                    
                    DispatchQueue.main.async {
                        let wasPinched = lastIndexPose != nil
                        let isPinched = newPose != nil
                        
                        lastIndexPose = newPose
                        
                        if wasPinched && !isPinched {
                            canvas.finishStroke()
                        }
                    }
                }))
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                .targetedToAnyEntity()
                .onChanged({ _ in
                    if let pos = lastIndexPose {
                        canvas.addPoint(pos)
                    }
                })
                .onEnded({ _ in
                    // Stroke is now finished when the pinch is released.
                })
            )
            
            HStack {
                Button(action: {
                    canvas.reset()
                }) {
                    Text("Reset")
                        .buttonTextStyle()
                }
                .padding(.trailing, 10)

                Button(action: {
                    self.navigateToExecutive = true
                }) {
                    Text("Submit")
                        .buttonTextStyle()
                }
            }
            .padding(.bottom, 40)
        }
        .task {
            await paintingHandTracking.startTracking()
        }
        .navigationDestination(isPresented: $navigateToExecutive) {
            ExecutiveView()
        }
    }
}
