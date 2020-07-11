import ARKit
import Foundation

///
/// Stores the value and all contextual data for a collected `BlendShape`
/// value from `ARKit`'s `BlendShapeLocation`.
///
public struct BlendShape: Codable {
    /// A UNIX timestamp for when this data point was collected.
    public let timestamp: TimeInterval

    /// The reported tracking state for this data point, as reported
    /// by its `ARFrame`'s `ARCamera` instance. If `nil`, then data
    /// quality is normal.
    public let trackingState: String?

    /// A string representation of `ARFaceAnchor.BlendShapeLocation` from
    /// its `rawValue`. See Apple's documentation for more information.
    public let blendShapeLocation: String

    /// The data point's value - a numerical value from 0.0 to 1.0.
    /// See Apple's documentation for each `BlendShapeLocation` for specific
    /// interpretation information for this value.
    public let value: Double

    ///
    /// Simple memberwise initializer for converting
    /// `ARFaceAnchor.BlendShapeLocation` to its `rawValue` string.
    ///
    init(
        timestamp: TimeInterval,
        trackingState: String?,
        blendShapeLocation: ARFaceAnchor.BlendShapeLocation,
        value: Double
    ) {
        self.timestamp = timestamp
        self.trackingState = trackingState
        self.blendShapeLocation = blendShapeLocation.rawValue
        self.value = value
    }
}
