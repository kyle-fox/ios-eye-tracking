import ARKit
import os.log

/// A simple wrapper for creating `OSLog` objects with a given `appID` string for the subsystem.
struct Log {
    /// Configure this using the memberwise initializer.
    let appID: String

    /// `OSLog` instance for gaze logging.
    var gaze: OSLog {
        OSLog(subsystem: appID, category: "gaze")
    }

    /// `OSLog` instance for general logging in the app. Primarily used to show faults.
    var general: OSLog {
        OSLog(subsystem: appID, category: "general")
    }

    /// `OSLog` instance for `ARCamera`'s tracking state logging.
    var trackingState: OSLog {
        OSLog(subsystem: appID, category: "trackingState")
    }

    ///
    /// Returns an `OSLog` instance with a category based on the given `BlendShapeLocation`.
    ///
    /// - parameter blendShapeLocation: See Apple's documentation for possible values.
    ///
    func blendShape(_ blendShapeLocation: ARFaceAnchor.BlendShapeLocation) -> OSLog {
        OSLog(subsystem: appID, category: blendShapeLocation.rawValue)
    }
}
