import RealityKit
import UIKit
import simd
import ARKit
import SwiftUI

// SIMD Extensions for matrix operations (existing code)
extension SIMD4 where Scalar == Float {
    var xyz: SIMD3<Float> {
        return SIMD3<Float>(x, y, z)
    }
}

extension Entity {
    func addStaticNodes() {
        let modelCount: Int = 10
        
        // Original 2D node positions
        let nodes: [(String, CGPoint)] = [
            ("1", CGPoint(x: 650, y: 350)),
            ("A", CGPoint(x: 850, y: 150)),
            ("2", CGPoint(x: 1000, y: 200)),
            ("B", CGPoint(x: 850, y: 300)),
            ("3", CGPoint(x: 1000, y: 550)),
            ("C", CGPoint(x: 600, y: 600)),
            ("4", CGPoint(x: 800, y: 500)),
            ("D", CGPoint(x: 500, y: 500)),
            ("5", CGPoint(x: 450, y: 250)),
            ("E", CGPoint(x: 650, y: 100))
        ]
        
        // Find bounds for proper scaling
        let minX = nodes.map { $0.1.x }.min()! // 450
        let maxX = nodes.map { $0.1.x }.max()! // 1000
        let minY = nodes.map { $0.1.y }.min()! // 100
        let maxY = nodes.map { $0.1.y }.max()! // 600
        
        // Center point for relative positioning
        let centerX = (minX + maxX) / 2  // 725
        let centerY = (minY + maxY) / 2  // 350
        
        // Scale to fit nicely in VR space (reduced horizontal span, reduced vertical spread)
        let scaleX: Float = 2.5 / Float(maxX - minX)  // Reduced from 3.0 to 2.5 for less horizontal spread
        let scaleY: Float = 2.0 / Float(maxY - minY)  // Reduced from 3.0 to 2.0 for less vertical spread
        
        // Convert to 3D positions maintaining relative layout
        var positions: [SIMD3<Float>] = []
        var labels: [String] = []
        
        for (label, point) in nodes {
            // Map 2D to 3D coordinates around user
            let x = Float(point.x - centerX) * scaleX
            let y = Float(centerY - point.y) * scaleY  // Use separate Y scaling for reduced vertical spread
            
            // Add random depth variation for more interesting 3D positioning
            // Base depth of -2.0 with random variation between -0.8 and +0.8 (total range: -2.8 to -1.2)
            let randomDepthVariation = Float.random(in: -0.8...0.8)
            let z = Float(-2.0) + randomDepthVariation
            
            positions.append(SIMD3<Float>(x, y, z))
            labels.append(label)
        }
        
        let colors: [UIColor] = Array(repeating: .yellow, count: modelCount)

        for i in 0..<modelCount {
            let entity = Entity()
            let sphereMesh = MeshResource.generateSphere(radius: 0.1)
            var sphereMaterial = SimpleMaterial()
            sphereMaterial.color = .init(tint: colors[i])
            sphereMaterial.roughness = 0.3
            
            entity.components.set(ModelComponent(mesh: sphereMesh, materials: [sphereMaterial]))
            entity.position = positions[i]
            
            let sphereShape = ShapeResource.generateSphere(radius: 0.1)
            entity.components.set(CollisionComponent(shapes: [sphereShape]))
            entity.components.set(InputTargetComponent())
            entity.name = "node\(i)"

            // Add text label to the sphere
            let textEntity = Entity()
            let textMesh = MeshResource.generateText(
                labels[i],
                extrusionDepth: 0.002,
                font: .boldSystemFont(ofSize: 0.06),
                containerFrame: CGRect.zero,
                alignment: .center,
                lineBreakMode: .byWordWrapping
            )
            var textMaterial = SimpleMaterial()
            textMaterial.color = .init(tint: .black)
            textEntity.components.set(ModelComponent(mesh: textMesh, materials: [textMaterial]))
            
            // Position text at the center of the sphere, slightly forward on Z-axis
            // This ensures the text appears centered regardless of rotation angle
            let textBounds = textMesh.bounds
            
            // Calculate more precise centering for better visual alignment
            // Use the full bounds to ensure all characters are perfectly centered
            let boundingBoxSize = textBounds.extents
            let centerOffset = SIMD3<Float>(
                -textBounds.center.x,  // Use geometric center for X
                -textBounds.center.y,  // Use geometric center for Y  
                0.101                  // Slightly in front of sphere surface
            )
            
            // Apply a small adjustment for better visual centering
            // This helps with characters that might have asymmetric bounds
            let visualCenteringAdjustment = SIMD3<Float>(
                0.0,                      // No horizontal adjustment needed
                -boundingBoxSize.y * 0.05,  // Small vertical adjustment for better visual balance
                0.0
            )
            
            textEntity.position = centerOffset + visualCenteringAdjustment
            textEntity.name = "textLabel\(i)" // Name the text entity for easier access
            
            entity.addChild(textEntity)

            self.addChild(entity)
        }
    }
    
    func addArrow(from startPos: SIMD3<Float>, to endPos: SIMD3<Float>, name: String = "arrow") {
        let direction = endPos - startPos
        let normalizedDirection = normalize(direction)
        
        // Account for sphere radius (0.1) to prevent arrow from going into spheres
        let sphereRadius: Float = 0.1
        let adjustedStartPos = startPos + normalizedDirection * sphereRadius
        let adjustedEndPos = endPos - normalizedDirection * sphereRadius
        let adjustedDistance = length(adjustedEndPos - adjustedStartPos)
        
        // Make arrowhead slightly longer and more proportional
        let headLength = min(adjustedDistance * 0.2, 0.1) // Max 20% of distance or 0.1 units (increased)
        let shaftLength = adjustedDistance - headLength
        
        let shaftEntity = Entity()
        let shaftMesh = MeshResource.generateCylinder(height: shaftLength, radius: 0.015) // Slightly thinner shaft
        var shaftMaterial = SimpleMaterial()
        shaftMaterial.color = .init(tint: .systemBlue) // Changed to system blue for better contrast
        shaftMaterial.roughness = 0.2  // Slightly more polished
        shaftMaterial.metallic = 0.1   // Slight metallic sheen
        shaftEntity.components.set(ModelComponent(mesh: shaftMesh, materials: [shaftMaterial]))
        
        let headEntity = Entity()
        let headMesh = MeshResource.generateCone(height: headLength, radius: 0.04) // Proportional head size
        var headMaterial = SimpleMaterial()
        headMaterial.color = .init(tint: .systemOrange) // Changed to orange for better visibility and contrast
        headMaterial.roughness = 0.2   // Match shaft material properties
        headMaterial.metallic = 0.1    // Slight metallic sheen
        headEntity.components.set(ModelComponent(mesh: headMesh, materials: [headMaterial]))
        
        // Position shaft and head correctly with proper spacing
        let shaftCenter = adjustedStartPos + normalizedDirection * (shaftLength / 2)
        let headCenter = adjustedStartPos + normalizedDirection * (shaftLength + headLength / 2)
        
        shaftEntity.position = shaftCenter
        headEntity.position = headCenter
        
        let up = SIMD3<Float>(0, 1, 0)
        let rotationAxis = cross(up, normalizedDirection)
        let rotationAngle = acos(dot(up, normalizedDirection))
        
        if length(rotationAxis) > 0.001 {
            let rotation = simd_quatf(angle: rotationAngle, axis: normalize(rotationAxis))
            shaftEntity.orientation = rotation
            headEntity.orientation = rotation
        }
        
        let arrowEntity = Entity()
        arrowEntity.name = name
        arrowEntity.addChild(shaftEntity)
        arrowEntity.addChild(headEntity)
        
        self.addChild(arrowEntity)
    }

    func add3DButton(isShowingNodes: Bool, onTap: @escaping () -> Void) {
        // Button configuration: [name, color, position_x] - closer spacing for pill buttons
        let buttonConfigs: [(String, UIColor, Float)] = [
            ("Submit", .green, -0.25),    // Left button - closer spacing
            ("2D", .blue, 0.0),           // Center button
            ("Reset", .red, 0.25)         // Right button - closer spacing
        ]
        
        for (_, config) in buttonConfigs.enumerated() {
            let (buttonText, buttonColor, xPosition) = config
            
            let buttonEntity = Entity()
            // Create extremely round pill-shaped button with maximum corner radius for capsule appearance
            let buttonMesh = MeshResource.generateBox(size: [0.2, 0.12, 0.03], cornerRadius: 0.12)
            var buttonMaterial = SimpleMaterial()
            buttonMaterial.color = .init(tint: buttonColor)
            buttonMaterial.roughness = 0.05  // More polished marble-like surface
            buttonMaterial.metallic = 0.1    // Slightly less metallic for marble effect

            buttonEntity.components.set(ModelComponent(mesh: buttonMesh, materials: [buttonMaterial]))
            
            // Static position - no camera tracking needed
            buttonEntity.position = [xPosition, -0.6, -1.2]  // Lower positioning to match head tracking
            
            let buttonShape = ShapeResource.generateBox(size: [0.2, 0.12, 0.03])
            buttonEntity.components.set(CollisionComponent(shapes: [buttonShape]))
            buttonEntity.components.set(InputTargetComponent())
            
            // Set button names for identification
            switch buttonText {
            case "2D":
                buttonEntity.name = "toggleButton"  // Keep original name for 2D button
            case "Reset":
                buttonEntity.name = "resetButton"
            case "Submit":
                buttonEntity.name = "submitButton"
            default:
                buttonEntity.name = "unknownButton"
            }

            // Add text label to the button
            let textEntity = Entity()
            let textMesh = MeshResource.generateText(
                buttonText,
                extrusionDepth: 0.002,
                font: .boldSystemFont(ofSize: 0.035), // Slightly smaller text for narrower buttons
                containerFrame: CGRect.zero,
                alignment: .center,
                lineBreakMode: .byWordWrapping
            )
            var textMaterial = SimpleMaterial()
            textMaterial.color = .init(tint: .white)
            textMaterial.roughness = 0.05  // Match button material
            textEntity.components.set(ModelComponent(mesh: textMesh, materials: [textMaterial]))
            
            // Center the text on the front surface of the button
            let textBounds = textMesh.bounds
            let textOffset = SIMD3<Float>(-textBounds.center.x, -textBounds.center.y, 0)
            textEntity.position = SIMD3<Float>(textOffset.x, textOffset.y, 0.016)  // Adjusted for much thinner button
            
            buttonEntity.addChild(textEntity)
            self.addChild(buttonEntity)
        }
    }
    
    func updateSphereColor(sphereIndex: Int, color: UIColor) {
        if let sphereEntity = self.children.first(where: { $0.name == "node\(sphereIndex)" }) {
            let sphereMesh = MeshResource.generateSphere(radius: 0.1)
            var sphereMaterial = SimpleMaterial()
            sphereMaterial.color = .init(tint: color)
            sphereMaterial.roughness = 0.3
            sphereEntity.components.set(ModelComponent(mesh: sphereMesh, materials: [sphereMaterial]))
            // Note: Text entity is preserved as a child, no need to recreate it
        }
    }
    
    func updateSphereRotationToFaceUser(sphereIndex: Int, userPosition: SIMD3<Float>) {
        let sphereName = "node\(sphereIndex)"
        
        guard let sphereEntity = self.children.first(where: { $0.name == sphereName }) else {
            return
        }
        
        // Get the sphere's world position
        let sphereWorldPosition = sphereEntity.convert(position: SIMD3<Float>(0, 0, 0), to: nil)
        
        // Calculate direction from sphere to user
        let toUser = userPosition - sphereWorldPosition
        let distance = length(toUser)
        
        // Reduced distance threshold for more consistent rotation
        guard distance > 0.05 else {
            return
        }
        
        let direction = normalize(toUser)
        
        // Create a proper look-at rotation where the positive Z axis points toward the user
        let forward = direction  // Direction to user
        let worldUp = SIMD3<Float>(0, 1, 0)
        
        // More robust right vector calculation
        var right = cross(worldUp, forward)
        let rightLength = length(right)
        
        // Handle edge case where forward is parallel to world up
        if rightLength < 0.001 {
            // Use world right vector when looking straight up/down
            right = SIMD3<Float>(1, 0, 0)
        } else {
            right = right / rightLength  // Manual normalization for precision
        }
        
        // Calculate up vector (perpendicular to forward and right)
        let up = normalize(cross(forward, right))
        
        // Ensure all vectors are properly normalized
        let normalizedForward = normalize(forward)
        let normalizedRight = normalize(right)
        let normalizedUp = normalize(up)
        
        // Create rotation matrix - each column represents the destination for unit vectors
        let rotationMatrix = float3x3(
            normalizedRight,    // X axis destination
            normalizedUp,       // Y axis destination  
            normalizedForward   // Z axis destination (toward user)
        )
        
        let targetOrientation = simd_quatf(rotationMatrix)
        
        // Apply smooth rotation with optimized factor for all spheres
        let currentOrientation = sphereEntity.transform.rotation
        let smoothingFactor: Float = 0.15 // Slightly reduced for better stability
        sphereEntity.transform.rotation = simd_slerp(currentOrientation, targetOrientation, smoothingFactor)
    }
    
    func removeAllArrows() {
        // Remove all arrow entities
        self.children.removeAll { child in
            child.name.hasPrefix("arrow_")
        }
    }
    
    func updateButtonPositionsToFollowUser(headTransform: simd_float4x4, deltaTime: TimeInterval) {
        // Distance that the buttons extend out from the device
        let distance: Float = 1.2
        
        // Button layout configuration
        let buttonHeight: Float = -0.6   // Even further below center line
        let buttonSpacing: Float = 0.25   // Closer spacing between buttons
        
        // Get current head position and direction using existing extensions
        let currentPosition = headTransform.translation()
        let forwardDirection = headTransform.forward()
        
        // Calculate the target position for the center of the button row
        let targetCenterPosition = currentPosition - distance * forwardDirection
        
        // Calculate right vector for horizontal button spacing
        let worldUp = SIMD3<Float>(0, 1, 0)
        let rightDirection = normalize(cross(forwardDirection, worldUp))
        
        // Button configurations with their relative positions
        let buttonConfigs: [(String, Float)] = [
            ("submitButton", -buttonSpacing),  // Left - Submit is now on the left
            ("toggleButton", 0.0),             // Center
            ("resetButton", buttonSpacing)     // Right - Reset is now on the right
        ]
        
        // Interpolation ratio for smooth movement (following Apple's sample)
        let ratio = Float(pow(0.96, deltaTime / (16 * 1E-3)))
        
        for (buttonName, xOffset) in buttonConfigs {
            if let buttonEntity = self.children.first(where: { $0.name == buttonName }) {
                // Calculate target position for this specific button
                let targetPosition = targetCenterPosition + 
                                   rightDirection * xOffset + 
                                   worldUp * buttonHeight
                
                // Get current position and apply smooth interpolation
                let currentButtonPosition = SIMD3<Float>(buttonEntity.position(relativeTo: nil))
                let newPosition = ratio * currentButtonPosition + (1 - ratio) * targetPosition
                
                // Update button position with smooth movement
                buttonEntity.setPosition(newPosition, relativeTo: nil)
                
                // Make button face toward the user
                let toUser = normalize(currentPosition - newPosition)
                let up = worldUp
                let right = normalize(cross(up, toUser))
                let correctedUp = normalize(cross(toUser, right))
                
                // Create rotation matrix to face user
                let rotationMatrix = float3x3(
                    right,
                    correctedUp,
                    toUser
                )
                
                buttonEntity.transform.rotation = simd_quatf(rotationMatrix)
            }
        }
    }
}

// MARK: - Extensions
