import ARKit
import Foundation

public struct BlendShape: Codable {
    public let timestamp: TimeInterval
    public let blendShapeLocation: String
    public let value: Double

    init(timestamp: TimeInterval, blendShapeLocation: ARFaceAnchor.BlendShapeLocation, value: Double) {
        self.timestamp = timestamp
        self.blendShapeLocation = blendShapeLocation.rawValue
        self.value = value
    }
}
