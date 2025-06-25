//
//  HeadPositionTracker.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 12/6/25.
//

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
