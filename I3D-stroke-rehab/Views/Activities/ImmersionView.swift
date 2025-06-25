import SwiftUI
import RealityKit
import ARKit

// MARK: - Head Position Tracker
class HeadPositionTracker: ObservableObject {
    /// The instance of the `ARKitSession` for world tracking.
    let arSession = ARKitSession()

    /// The instance of a new `WorldTrackingProvider` for world tracking.
    let worldTracking = WorldTrackingProvider()

    init() {
        Task {
            // Check whether the device supports world tracking.
            guard WorldTrackingProvider.isSupported else {
                return
            }
            do {
                // Attempt to start an ARKit session with the world-tracking provider.
                try await arSession.run([worldTracking])
            } catch _ as ARKitSession.Error {
                // Handle any potential ARKit session errors.
            } catch _ {
                // Handle any unexpected errors.    
            }
        }
    }
    
    func originFromDeviceTransform() -> simd_float4x4? {
        /// The anchor of the device at the current time.
        guard let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else {
            return nil
        }

        // Return the device's transform.
        return deviceAnchor.originFromAnchorTransform
    }
}

// MARK: - Closure Component and System for per-frame updates
struct ClosureComponent: Component {
    /// The closure that takes the time interval since the last update.
    let closure: (TimeInterval) -> Void

    init (closure: @escaping (TimeInterval) -> Void) {
        self.closure = closure
        ClosureSystem.registerSystem()
    }
}

struct ClosureSystem: System {
    /// The query to check if the entity has the `ClosureComponent`.
    static let query = EntityQuery(where: .has(ClosureComponent.self))
    
    init(scene: RealityKit.Scene) {}
    
    /// Update entities with `ClosureComponent` at each render frame.
    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let comp = entity.components[ClosureComponent.self] else { continue }
            comp.closure(context.deltaTime)
        }
    }
}

// MARK: - Float Extensions for Vector Math
/// The type alias to create a new name for `SIMD3<Float>`.
typealias Float3 = SIMD3<Float>

/// The type alias to create a new name for `SIMD4<Float>`.
typealias Float4 = SIMD4<Float>

/// The type alias to create a new name for `simd_float4x4`.
typealias Float4x4 = simd_float4x4

extension Float3 {
    /// The initializer of a `Float3` from a `Float4`.
    init(_ float4: Float4) {
        self.init()
        
        x = float4.x
        y = float4.y
        z = float4.z
    }
    
    // Calculate the total length by taking the square root of the product of the provided float.
    func length() -> Float {
        sqrt(x * x + y * y + z * z)
    }
    
    // Calculate the normalized vector of the float.
    func normalized() -> Float3 {
        self * 1 / length()
    }
}

extension Float4 {
    // Ignore the W value to convert a `Float4` into a `Float3`.
    func toFloat3() -> Float3 {
        Float3(self)
    }
}

extension Float4x4 {
    // Identify the translation value from the `float4x4` and convert to a `Float3`.
    func translation() -> Float3 {
        columns.3.toFloat3()
    }
    
    // Identify the forward-facing vector and return a `Float3`.
    func forward() -> Float3 {
        columns.2.toFloat3().normalized()
    }
}

struct ImmersiveView: View {
    let avgHeight: Float = 1.60
    
    @AppStorage("showImmersiveSpace") private var showImmersiveSpace: Bool = true
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @State private var selectedNodeIndex: Int? = nil
    @State private var rootEntityRef: Entity? = nil
    @State private var savedArrows: [(from: Int, to: Int)] = []
    @State private var hasLoadedArrows: Bool = false
    @StateObject private var headTracker = HeadPositionTracker()

    var body: some View {
        RealityView { content in
            let rootEntity = Entity()
            rootEntityRef = rootEntity

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
        } update: { content in
            // Update the 2D button state when showImmersiveSpace changes
            if let rootEntity = rootEntityRef {
                // Remove old button
                rootEntity.children.removeAll { child in
                    child.name == "toggleButton"
                }
                
                // Add updated button
                rootEntity.add3DButton(isShowingNodes: true) {
                }
                
                // Ensure head tracking component is still active
                if !rootEntity.components.has(ClosureComponent.self) {
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
                }
            }
        }
        .onAppear {
            // Load arrows only once when the view appears
            if !hasLoadedArrows {
                loadSavedArrows()
                hasLoadedArrows = true
                
                // Small delay to ensure RealityView is fully loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Recreate arrows from saved data
                    for arrow in savedArrows {
                        createArrowBetweenNodes(from: arrow.from, to: arrow.to)
                    }
                    
                    // Update sphere colors based on loaded arrows
                    updateSphereColors()
                }
            }
        }
        .onDisappear {
            // Reset the loading flag when the immersive space closes
            hasLoadedArrows = false
        }
        .gesture(
            TapGesture()
                .targetedToEntity(where: .has(InputTargetComponent.self))
                .onEnded { value in
                    DispatchQueue.main.async {
                        if value.entity.name == "toggleButton" {
                            showImmersiveSpace = false
                            Task {
                                await dismissImmersiveSpace()
                                // Show the 2D window when immersive space closes
                                openWindow(id: "MainWindow")
                            }
                        } else if value.entity.name == "resetButton" {
                            // Remove all arrows from the scene
                            if let rootEntity = rootEntityRef {
                                let arrowsToRemove = rootEntity.children.filter { $0.name.starts(with: "arrow_") }
                                for arrow in arrowsToRemove {
                                    arrow.removeFromParent()
                                }
                            }
                            // Clear stored arrows
                            savedArrows.removeAll()
                            saveSavedArrows()
                            // Reset sphere colors
                            updateSphereColors()
                        } else if value.entity.name == "submitButton" {
                            // Submit functionality here
                        } else if value.entity.name.starts(with: "node") {
                            if let nodeIndexString = value.entity.name.last,
                               let nodeIndex = Int(String(nodeIndexString)) {
                                
                                if let firstSelectedNode = selectedNodeIndex {
                                    if firstSelectedNode != nodeIndex {
                                        // Different node clicked - try to create arrow
                                        self.createArrowWithConstraints(from: firstSelectedNode, to: nodeIndex)
                                        selectedNodeIndex = nil
                                    }
                                    // Same node clicked twice - keep it selected, don't reset
                                } else {
                                    // No node selected - select this one
                                    selectedNodeIndex = nodeIndex
                                }
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
                                self.removeOutgoingArrow(from: nodeIndex)
                            }
                        }
                    }
                }
        )
    }
    
    private func createArrowWithConstraints(from firstNode: Int, to secondNode: Int) {
        // Check if firstNode already has an outgoing arrow
        if savedArrows.contains(where: { $0.from == firstNode }) {
            return
        }
        
        // Check if secondNode already has an incoming arrow
        if savedArrows.contains(where: { $0.to == secondNode }) {
            return
        }
        
        // Create the new arrow only if constraints are satisfied
        createArrowBetweenNodes(from: firstNode, to: secondNode)
        
        savedArrows.append((from: firstNode, to: secondNode))
        
        // Save arrows to persistent storage
        saveSavedArrows()
        
        // Update sphere colors after arrow creation
        updateSphereColors()
    }
    
    private func removeOutgoingArrow(from sphereIndex: Int) {
        guard rootEntityRef != nil else { return }
        
        if let arrowIndex = savedArrows.firstIndex(where: { $0.from == sphereIndex }) {
            let removedArrow = savedArrows.remove(at: arrowIndex)
            
            // Remove just the specific arrow, not all arrows
            removeSpecificArrow(from: removedArrow.from, to: removedArrow.to)
            
            // Save arrows to persistent storage
            saveSavedArrows()
            
            // Update sphere colors after arrow removal
            updateSphereColors()
        }
    }
    
    private func removeIncomingArrow(to sphereIndex: Int) {
        guard rootEntityRef != nil else { return }
        
        if let arrowIndex = savedArrows.firstIndex(where: { $0.to == sphereIndex }) {
            let removedArrow = savedArrows.remove(at: arrowIndex)
            
            // Remove just the specific arrow, not all arrows
            removeSpecificArrow(from: removedArrow.from, to: removedArrow.to)
            
            // Update sphere colors after arrow removal
            updateSphereColors()
        }
    }
    
    private func removeSpecificArrow(from: Int, to: Int) {
        guard let rootEntity = rootEntityRef else { return }
        
        // Find and remove arrow by its unique name
        let arrowName = "arrow_\(from)_to_\(to)"
        if let arrowToRemove = rootEntity.children.first(where: { $0.name == arrowName }) {
            rootEntity.removeChild(arrowToRemove)
        }
    }
    
    private func refreshArrows() {
        guard let rootEntity = rootEntityRef else { return }
        
        rootEntity.children.removeAll { child in
            child.name.starts(with: "arrow_")
        }
        
        for arrow in savedArrows {
            createArrowBetweenNodes(from: arrow.from, to: arrow.to)
        }
        
        // Update sphere colors after refreshing arrows
        updateSphereColors()
    }
    
    private func createArrowBetweenNodes(from firstNode: Int, to secondNode: Int) {
        guard let rootEntity = rootEntityRef else { return }
        
        // Get the actual positions of the spheres from the scene
        guard let firstSphere = rootEntity.children.first(where: { $0.name == "node\(firstNode)" }),
              let secondSphere = rootEntity.children.first(where: { $0.name == "node\(secondNode)" }) else {
            return
        }
        
        let startPos = firstSphere.position
        let endPos = secondSphere.position
        
        // Create arrow with unique name
        let arrowName = "arrow_\(firstNode)_to_\(secondNode)"
        rootEntity.addArrow(from: startPos, to: endPos, name: arrowName)
    }
    
    private func updateSphereColors() {
        guard let rootEntity = rootEntityRef else { return }
        
        // Reset all spheres to yellow
        for i in 0..<10 {
            rootEntity.updateSphereColor(sphereIndex: i, color: .yellow)
        }
        
        // Turn spheres green if they have any arrows connected
        var connectedSpheres = Set<Int>()
        for arrow in savedArrows {
            connectedSpheres.insert(arrow.from)
            connectedSpheres.insert(arrow.to)
        }
        
        for sphereIndex in connectedSpheres {
            rootEntity.updateSphereColor(sphereIndex: sphereIndex, color: .green)
        }
    }
    
    private func loadSavedArrows() {
        guard let cacheURL = getCacheFileURL() else {
            return
        }
        
        guard FileManager.default.fileExists(atPath: cacheURL.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: cacheURL)
            let decoder = JSONDecoder()
            let arrowPairs = try decoder.decode([[Int]].self, from: data)
            savedArrows = arrowPairs.compactMap { pair in
                guard pair.count == 2 else { return nil }
                return (from: pair[0], to: pair[1])
            }
        } catch {
            savedArrows = []
        }
    }
    
    private func saveSavedArrows() {
        guard let cacheURL = getCacheFileURL() else {
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let arrowPairs = savedArrows.map { [$0.from, $0.to] }
            let data = try encoder.encode(arrowPairs)
            try data.write(to: cacheURL)
        } catch {
            // Save failed
        }
    }
    
    private func getCacheFileURL() -> URL? {
        guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        return cacheDir.appendingPathComponent("savedArrows.json")
    }
}
