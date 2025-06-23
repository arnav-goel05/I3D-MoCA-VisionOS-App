import SwiftUI
import RealityKit


class PaintingCanvas {
    /// The main root entity for the painting canvas.
    let root = Entity()


    /// The stroke the person creates.
    var currentStroke: Stroke?


    /// The distance for the box that extends in the positive direction.
    let big: Float = 1E2


    /// The distance for the box that extends in the negative direction.
    let small: Float = 1E-2


    init() {
        // Create a vertical 3D ring as the canvas boundary
        let outerRadius: Float = 0.5
        let innerRadius: Float = 0.4
        let depth: Float = 0.02
        let path = SwiftUI.Path { path in
            path.addArc(center: .zero, radius: CGFloat(outerRadius),
                        startAngle: .degrees(0), endAngle: .degrees(360),
                        clockwise: true)
            path.addArc(center: .zero, radius: CGFloat(innerRadius),
                        startAngle: .degrees(0), endAngle: .degrees(360),
                        clockwise: true)
        }.normalized(eoFill: true)
        var options = MeshResource.ShapeExtrusionOptions()
        options.boundaryResolution = .uniformSegmentsPerSpan(segmentCount: 64)
        options.extrusionMethod = .linear(depth: depth)
        guard let mesh = try? MeshResource(extruding: path, extrusionOptions: options) else { return }
        let ringEntity = ModelEntity(mesh: mesh,
                                     materials: [SimpleMaterial(color: .white,
                                                              roughness: 1.0,
                                                              isMetallic: false)])
        // Position 1m in front and rotate to vertical orientation
        ringEntity.position = [0, 0, -1]
        ringEntity.orientation = simd_quatf(angle: .pi/2, axis: [1, 0, 0])
        ringEntity.components.set(InputTargetComponent())
        ringEntity.components.set(CollisionComponent(shapes: [.generateConvex(from: mesh)],
                                                     isStatic: true))
        root.addChild(ringEntity)
        
        // Single invisible 3D collision box for drawing space
        let drawSpaceSize: SIMD3<Float> = [2.0, 2.0, 2.0] // 2m cube around user
        let drawSpace = Entity()
        drawSpace.components.set(InputTargetComponent())
        drawSpace.components.set(CollisionComponent(shapes: [.generateBox(size: drawSpaceSize)], isStatic: true))
        root.addChild(drawSpace)
    }


    /// Create a collision box that takes in user input with the drag gesture.
    private func addBox(size: SIMD3<Float>, position: SIMD3<Float>) -> Entity {
        let box = Entity()
        box.components.set(InputTargetComponent())
        box.components.set(CollisionComponent(shapes: [.generateBox(size: size)], isStatic: true))
        box.position = position
        return box
    }


    func addPoint(_ position: SIMD3<Float>) {
        /// The maximum distance between two points before requiring a new point.
        let threshold: Float = 1E-9


        // Start a new stroke if no stroke exists.
        if currentStroke == nil {
            currentStroke = Stroke()


            // Add the stroke to the root.
            root.addChild(currentStroke!.entity)
        }


        // Check if the length between the current hand position and the previous point meets the threshold.
        if let previousPoint = currentStroke?.points.last, length(position - previousPoint) < threshold {
            return
        }


        // Add the current position to the stroke.
        currentStroke?.points.append(position)


        // Update the current stroke mesh.
        currentStroke?.updateMesh()
    }


    func finishStroke() {
        if let stroke = currentStroke {
            // Trigger the update mesh operation.
            stroke.updateMesh()


            // Clear the current stroke.
            currentStroke = nil
        }
    }
    
    func reset() {
        for child in root.children {
            if child.components.has(ModelComponent.self) {
                child.removeFromParent()
            }
        }
        currentStroke = nil
    }
}
