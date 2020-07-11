import ARKit
import os.log

/// A simple wrapper for creating `OSLog` objects with a given `appID` string for the subsystem.
struct Log {
    /// Identifier for use in os.log subsystem
    static let identifier = "co.kylefox.eyetracking"

    /// `OSLog` instance for gaze logging.
    static let gaze = OSLog(subsystem: identifier, category: "eyeTracking.gaze")

    /// `OSLog` instance for general logging in the app. Primarily used to show faults.
    static let general = OSLog(subsystem: identifier, category: "eyeTracking.general")

    /// `OSLog` instance for `ARCamera`'s tracking state logging.
    static let trackingState = OSLog(subsystem: identifier, category: "eyeTracking.trackingState")

    ///
    /// Returns an `OSLog` instance with a category based on the given `BlendShapeLocation`.
    ///
    /// - parameter blendShapeLocation: See Apple's documentation for possible values.
    ///
    static func blendShape(_ blendShapeLocation: ARFaceAnchor.BlendShapeLocation) -> OSLog {
        OSLog(subsystem: identifier, category: "eyeTracking.\(blendShapeLocation.rawValue)")
    }
}
