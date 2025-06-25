import SwiftUI
import RealityKit
import ARKit

struct ImmersiveView: View {
    let avgHeight: Float = 1.60
    
    @AppStorage("showImmersiveSpace") private var showImmersiveSpace: Bool = true
    @AppStorage("navigateToVisuospatial") private var navigateToVisuospatial = false
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @State private var rootEntityRef: Entity? = nil
    @State private var hasLoadedArrows: Bool = false
    @StateObject private var headTracker = HeadPositionTracker()
    @StateObject private var arrowManager = ArrowManager()

    var body: some View {
        RealityView { content in
            let rootEntity = Entity()
            rootEntityRef = rootEntity
            arrowManager.setRootEntity(rootEntity)

            rootEntity.position.y += avgHeight

            // Always add nodes since we're toggling the entire space
            rootEntity.addStaticNodes()
            
            rootEntity.add3DButton(isShowingNodes: true) {
                // Button tap handler
            }

            // Add head tracking component for sphere rotation and button positioning
            rootEntity.components.set(ClosureComponent(closure: { deltaTime in
                // Try to get head tracking data first
                if let currentTransform = headTracker.originFromDeviceTransform() {
                    // Get user position for sphere rotation
                    let userPosition = currentTransform.translation()
                    
                    // Update each sphere to face the user
                    for i in 0..<10 {
                        rootEntity.updateSphereRotationToFaceUser(sphereIndex: i, userPosition: userPosition)
                    }
                    
                    // Update buttons to follow user's head with smooth movement
                    rootEntity.updateButtonPositionsToFollowUser(headTransform: currentTransform, deltaTime: deltaTime)
                } else {
                    // Fallback: Simple rotation test if head tracking is not available
                    let time = Float(CACurrentMediaTime())
                    let testPosition = SIMD3<Float>(sin(time * 0.2) * 1.5, 0, cos(time * 0.2) * 1.5)
                    
                    // Update spheres with test position
                    for i in 0..<10 {
                        rootEntity.updateSphereRotationToFaceUser(sphereIndex: i, userPosition: testPosition)
                    }
                    
                    // Create a fallback transform for button positioning
                    var fallbackTransform = matrix_identity_float4x4
                    fallbackTransform.columns.3 = SIMD4<Float>(testPosition.x, testPosition.y, testPosition.z, 1.0)
                    // Simple forward direction (negative Z)
                    fallbackTransform.columns.2 = SIMD4<Float>(0, 0, -1, 0)
                    rootEntity.updateButtonPositionsToFollowUser(headTransform: fallbackTransform, deltaTime: deltaTime)
                }
            }))

            content.add(rootEntity)
        }
        .onAppear {
            // Load arrows only once when the view appears
            if !hasLoadedArrows {
                arrowManager.loadSavedArrows()
                hasLoadedArrows = true
                
                // Small delay to ensure RealityView is fully loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Recreate arrows from saved data
                    arrowManager.refreshArrows()
                }
            }
        }
        .onDisappear {
            // Reset the loading flag when the immersive space closes
            hasLoadedArrows = false
            
            // Clean up entities to prevent NetworkComponent warnings
            if let rootEntity = rootEntityRef {
                // Remove all components from child entities
                for child in rootEntity.children {
                    child.components.removeAll()
                }
                // Clear the root entity reference
                rootEntityRef = nil
            }
        }
        .gesture(
            TapGesture()
                .targetedToEntity(where: .has(InputTargetComponent.self))
                .onEnded { value in
                    DispatchQueue.main.async {
                        if value.entity.name == "toggleButton" {
                            showImmersiveSpace = false
                            navigateToVisuospatial = true
                            Task {
                                await dismissImmersiveSpace()
                                // Simply reopen the windows
                                openWindow(id: "MainWindow")
                                openWindow(id: "progress-bar")
                            }
                        } else if value.entity.name == "resetButton" {
                            // Reset all arrows using ArrowManager
                            arrowManager.removeAllArrows()
                        } else if value.entity.name == "submitButton" {
                            // Submit functionality - exit immersive space
                            showImmersiveSpace = false
                            navigateToVisuospatial = true
                            Task {
                                await dismissImmersiveSpace()
                                // Simply reopen the windows
                                openWindow(id: "MainWindow")
                                openWindow(id: "progress-bar")
                            }
                            print("Submitted! Returning to VisuospatialView.")
                        } else if value.entity.name.starts(with: "node") {
                            if let nodeIndexString = value.entity.name.last,
                               let nodeIndex = Int(String(nodeIndexString)) {
                                arrowManager.handleNodeSelection(nodeIndex: nodeIndex)
                            }
                        }
                    }
                }
        )
        .gesture(
            LongPressGesture(minimumDuration: 1.0)
                .targetedToEntity(where: .has(InputTargetComponent.self))
                .onEnded { value in
                    DispatchQueue.main.async {
                        if value.entity.name.starts(with: "node") {
                            if let nodeIndexString = value.entity.name.last,
                               let nodeIndex = Int(String(nodeIndexString)) {
                                arrowManager.removeOutgoingArrow(from: nodeIndex)
                            }
                        }
                    }
                }
        )
    }
}
