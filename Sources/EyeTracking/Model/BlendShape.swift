import ARKit
import Foundation

public struct BlendShape: Codable {
    public let timestamp: TimeInterval
    public let trackingState: String?
    public let blendShapeLocation: String
    public let value: Double

    init(timestamp: TimeInterval, trackingState: String?, blendShapeLocation: ARFaceAnchor.BlendShapeLocation, value: Double) {
        self.timestamp = timestamp
        self.trackingState = trackingState
        self.blendShapeLocation = blendShapeLocation.rawValue
        self.value = value
    }
}
