//
//  ArrowManager.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 12/6/25.
//

import SwiftUI
import RealityKit
import Foundation

// MARK: - Arrow Manager
class ArrowManager: ObservableObject {
    @Published var savedArrows: [(from: Int, to: Int)] = []
    @Published var selectedNodeIndex: Int? = nil
    
    private weak var rootEntity: Entity?
    
    init(rootEntity: Entity? = nil) {
        self.rootEntity = rootEntity
    }
    
    func setRootEntity(_ entity: Entity) {
        self.rootEntity = entity
    }
    
    // MARK: - Arrow Creation and Validation
    func createArrowWithConstraints(from firstNode: Int, to secondNode: Int) {
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
    
    private func createArrowBetweenNodes(from firstNode: Int, to secondNode: Int) {
        guard let rootEntity = rootEntity else { return }
        
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
    
    // MARK: - Arrow Removal
    func removeOutgoingArrow(from sphereIndex: Int) {
        guard rootEntity != nil else { return }
        
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
    
    func removeIncomingArrow(to sphereIndex: Int) {
        guard rootEntity != nil else { return }
        
        if let arrowIndex = savedArrows.firstIndex(where: { $0.to == sphereIndex }) {
            let removedArrow = savedArrows.remove(at: arrowIndex)
            
            // Remove just the specific arrow, not all arrows
            removeSpecificArrow(from: removedArrow.from, to: removedArrow.to)
            
            // Update sphere colors after arrow removal
            updateSphereColors()
        }
    }
    
    private func removeSpecificArrow(from: Int, to: Int) {
        guard let rootEntity = rootEntity else { return }
        
        // Find and remove arrow by its unique name
        let arrowName = "arrow_\(from)_to_\(to)"
        if let arrowToRemove = rootEntity.children.first(where: { $0.name == arrowName }) {
            // Clean up any components before removal
            arrowToRemove.components.removeAll()
            rootEntity.removeChild(arrowToRemove)
        }
    }
    
    func removeAllArrows() {
        guard let rootEntity = rootEntity else { return }
        
        // Remove all arrows from the scene with proper cleanup
        let arrowsToRemove = rootEntity.children.filter { $0.name.starts(with: "arrow_") }
        for arrow in arrowsToRemove {
            // Clean up any components before removal
            arrow.components.removeAll()
            rootEntity.removeChild(arrow)
        }
        
        // Clear stored arrows
        savedArrows.removeAll()
        saveSavedArrows()
        
        // Reset sphere colors
        updateSphereColors()
    }
    
    // MARK: - Arrow Refresh
    func refreshArrows() {
        guard let rootEntity = rootEntity else { return }
        
        // Clean up existing arrows with proper component cleanup
        let existingArrows = rootEntity.children.filter { $0.name.starts(with: "arrow_") }
        for arrow in existingArrows {
            arrow.components.removeAll()
            rootEntity.removeChild(arrow)
        }
        
        for arrow in savedArrows {
            createArrowBetweenNodes(from: arrow.from, to: arrow.to)
        }
        
        // Update sphere colors after refreshing arrows
        updateSphereColors()
    }
    
    // MARK: - Visual Updates
    func updateSphereColors() {
        guard let rootEntity = rootEntity else { return }
        
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
    
    // MARK: - Node Selection
    func handleNodeSelection(nodeIndex: Int) {
        if let firstSelectedNode = selectedNodeIndex {
            if firstSelectedNode != nodeIndex {
                // Different node clicked - try to create arrow
                createArrowWithConstraints(from: firstSelectedNode, to: nodeIndex)
                selectedNodeIndex = nil
            }
            // Same node clicked twice - keep it selected, don't reset
        } else {
            // No node selected - select this one
            selectedNodeIndex = nodeIndex
        }
    }
    
    // MARK: - Persistence
    func loadSavedArrows() {
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
