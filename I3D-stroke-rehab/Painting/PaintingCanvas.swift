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
        root.addChild(addBox(size: [big, big, small], position: [0, 0, -0.5 * big]))
        root.addChild(addBox(size: [big, big, small], position: [0, 0, +0.5 * big]))
        root.addChild(addBox(size: [small, big, big], position: [-0.5 * big, 0, 0]))
        root.addChild(addBox(size: [small, big, big], position: [+0.5 * big, 0, 0]))
        root.addChild(addBox(size: [big, small, big], position: [0, -0.5 * big, 0]))
        root.addChild(addBox(size: [big, small, big], position: [0, +0.5 * big, 0]))
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
