import ARKit
import Foundation

/// An object for configuring an `EyeTracking` session.
public struct Configuration {
    /// This `appID` will be tied to all `Session`s. Default value is the app's bundleID (recommended).
    public let appID: String

    /// Stores any number of `BlendShapeLocation`s for tracking and storing during sessions. See README or Apple's documentation for possible values.
    public let blendShapes: [ARFaceAnchor.BlendShapeLocation]

    /// Stores the desired fidelity for a `Session`'s storage in FPS. Max is 60 fps from `ARKit` as of iOS 14.
    public let framesPerSecond: Int = 60 // TODO: Implement FPS filter.

    ///
    /// Initialize a `Configuration`.
    ///
    /// - parameter appID: Optionally provide a `String` for an app id for `Session`s. Default value is the app's `bundleID`.
    /// - parameter blendShapes: Optionally provide an array of `BlendShapeLocation`s to track any number of `ARKit`'s provided facial recognition values.
    ///
    public init(appID: String? = nil, blendShapes: [ARFaceAnchor.BlendShapeLocation]? = nil) {
        // Fall way back to using a UUID, if bundleIdentifier happens to be nil. Need to investigate when this may happen.
        self.appID = appID ?? Bundle.main.bundleIdentifier ?? UUID().uuidString
        self.blendShapes = blendShapes ?? []
    }
}
