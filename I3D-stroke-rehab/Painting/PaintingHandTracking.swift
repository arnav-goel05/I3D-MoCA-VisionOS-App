import RealityKit
import ARKit


@MainActor class PaintingHandTracking: ObservableObject {
    /// The ARKit session for hand tracking.
    let arSession = ARKitSession()


    /// The `HandTrackingProvider` for hand tracking.
    let handTracking = HandTrackingProvider()


    /// The current left hand anchor that the app detects.
    @Published var latestLeftHand: HandAnchor?


    /// The current right hand anchor that the app detects.
    @Published var latestRightHand: HandAnchor?


    /// Check whether the device supports hand tracking, and start the ARKit session.
    func startTracking() async {
        guard HandTrackingProvider.isSupported else {
            print("HandTrackingProvider is not supported on this device.")
            return
        }


        do {
            try await arSession.run([handTracking])
        } catch let error as ARKitSession.Error {
            print("Encountered an error while running providers: \(error.localizedDescription)")
        } catch let error {
            print("Encountered an unexpected error: \(error.localizedDescription)")
        }


        // Assign the left and right hand based on the anchor updates.
        for await anchorUpdate in handTracking.anchorUpdates {
            switch anchorUpdate.anchor.chirality {
            case .left:
                self.latestLeftHand = anchorUpdate.anchor
            case .right:
                self.latestRightHand = anchorUpdate.anchor
            }
        }
    }
}
