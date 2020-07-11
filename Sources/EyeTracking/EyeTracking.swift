import ARKit
import os.log
import UIKit

///
/// EyeTracking is a class for easily recording a user's gaze location, using
/// `ARKit`'s eye tracking capabilities, and, optionally, any number of facial
/// tracking data points. See `Configuration` for more information.
///
public class EyeTracking: NSObject {

    // MARK: - Public Properties

    /// The currently running `Session`. If this is `nil`, then no `Session` is in progress.
    public var currentSession: Session?

    /// Set this value to true to enable logging through `os.log`. This is very lightweight,
    /// so it can be used in user builds, which can be inspected at any time with `Console.app`.
    /// Defaults to `false` to prevent too much noise in Xcode's console.
    public var loggingEnabled = false

    /// Array of `Session`s completed during the app's runtime.
    public var sessions = [Session]()

    // MARK: - Internal Properties

    /// Initialize `ARKit`'s `ARSession` when the class is created. This is the most lightweight method for accessing all facial tracking features.
    let arSession = ARSession()

    /// Internal storage for the `Configuration` object. This is created at initialization.
    var configuration: Configuration

    /// `ARFrame`'s timestamp value is relative to `systemUptime`. Use this offset to convert to Unix time.
    let timeOffset: TimeInterval = Date().timeIntervalSince1970 - ProcessInfo.processInfo.systemUptime

    // MARK: - UI Helpers
    var window: UIWindow {
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {
            assertionFailure("Window not found - Do not call UI functions in viewDidLoad(). Wait for viewDidAppear().")
            return UIWindow()
        }

        return window
    }


    // MARK: - Live Pointer

    /// These values are used by the live pointer for smooth display onscreen.
    var smoothX = LowPassFilter(value: 0, filterValue: 0.85)
    var smoothY = LowPassFilter(value: 0, filterValue: 0.85)

    ///
    /// A small, round dot for viewing live gaze point onscreen.
    ///
    /// To display, call `showPointer` any time after the session starts.
    /// Default size is 30x30 and color is blue, but this can be customized
    /// like any other `UIView`.
    ///
    public lazy var pointer: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        view.layer.cornerRadius = view.frame.size.width / 2
        view.layer.cornerCurve = .continuous
        view.backgroundColor = .blue
        view.layer.zPosition = .greatestFiniteMagnitude
        return view
    }()

    ///
    /// Create an instance of `EyeTracking` with a given `Configuration`.
    ///
    /// - Warning: You must store a strong reference to this class or else risk losing a session's data.
    ///
    /// - parameter configuration: The initial configuration object for EyeTracking. See its documentation for details.
    ///
    public required init(configuration: Configuration) {
        self.configuration = configuration

        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    ///
    /// Handle a memory warning to prevent data loss. This will end the current session
    /// immediately, saving all its data to disk.
    ///
    @objc func didReceiveMemoryWarning() {
        os_log(
            "%{public}@",
            log: Log.general,
            type: .fault,
            "⛔️ Memory Warning Received. Ending current EyeTracking Session and saving to disk."
        )

        guard currentSession != nil else { return }
        endSession()
    }
}

// MARK: - Session Management

extension EyeTracking {
    ///
    /// Start an eye tracking `Session`.
    ///
    /// - Warning: Check that `currentSession` is not `nil` before calling.
    /// This function will fail if there is a current `Session` in progress.
    ///
    public func startSession() {
        guard ARFaceTrackingConfiguration.isSupported else {
            assertionFailure("Face tracking not supported on this device.")
            return
        }
        guard currentSession == nil else {
            assertionFailure("Session already in progress. Must call endSession() first.")
            return
        }

        // Set up local properties.
        currentSession = Session(id: UUID(), appID: configuration.appID)

        // Configure and start the ARSession to begin face tracking.
        let configuration = ARFaceTrackingConfiguration()
        configuration.worldAlignment = .camera

        arSession.delegate = self
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    ///
    /// End an eye tracking `Session`.
    ///
    /// When this function is called, the `Session` is saved to disk and can be exported at any time.
    ///
    public func endSession() {
        arSession.pause()
        currentSession?.endTime = Date().timeIntervalSince1970

        guard let currentSession = currentSession else {
            os_log(
                "%{public}@",
                log: Log.general,
                type: .fault,
                "⛔️ WARNING: EyeTracking's endSession() called without a current session."
            )
            return
        }

        // Save session and reset local state.
        sessions.append(currentSession)
        self.currentSession = nil
    }
}

// MARK: - ARSessionDelegate

extension EyeTracking: ARSessionDelegate {
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let anchor = frame.anchors.first as? ARFaceAnchor else { return }
        guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else { return }

        // Convert lookAtPoint vector to world coordinate space, from face coordinate space.
        let point = anchor.transform * SIMD4<Float>(anchor.lookAtPoint, 1)

        // Project lookAtPoint into screen coordinates.
        let screenPoint = frame.camera.projectPoint(
            SIMD3<Float>(x: point.x, y: point.y, z: point.z),
            orientation: orientation,
            viewportSize: UIScreen.main.bounds.size
        )

        // Update Session Data
        let frameTimestampUnix = timeOffset + frame.timestamp
        let trackingState = trackingStateString(for: frame)

        currentSession?.scanPath.append(
            Gaze(
                timestamp: frameTimestampUnix,
                trackingState: trackingState,
                x: screenPoint.x,
                y: screenPoint.y
            )
        )

        // Save any configured blendShapeLocation values
        for blendShape in configuration.blendShapes {
            guard let value = anchor.blendShapes[blendShape]?.doubleValue else { continue }

            // FIXME: Clean up. Should be able to do this without if statement.
            if currentSession?.blendShapes[blendShape.rawValue] != nil {
                currentSession?.blendShapes[blendShape.rawValue]?.append(
                    BlendShape(
                        blendShapeLocation: blendShape,
                        timestamp: frameTimestampUnix,
                        trackingState: trackingState,
                        value: value
                    )
                )
            } else {
                currentSession?.blendShapes.updateValue(
                    [
                        BlendShape(
                            blendShapeLocation: blendShape,
                            timestamp: frameTimestampUnix,
                            trackingState: trackingState,
                            value: value
                        )
                    ],
                    forKey: blendShape.rawValue
                )
            }

            // Log a fault if tracking state is contains any information.
            // Not governed by `loggingEnabled`, because this is always
            // relevant and should be low frequency.
            if let trackingState = trackingState {
                os_log(
                    "%{public}@: %{public}f",
                    log: Log.trackingState,
                    type: .fault,
                    "Tracking State:",
                    trackingState
                )
            }

            if loggingEnabled {
                os_log(
                    "%{public}@: %{public}f",
                    log: Log.blendShape(blendShape),
                    type: .info,
                    blendShape.rawValue,
                    value
                )
            }
        }

        // Update UI

        updatePointer(with: screenPoint)
    }
}

// MARK: - ARCamera TrackingState

extension EyeTracking {
    ///
    /// Returns a string representation as reported by the given ARFrame's camera, if it reports anything other than `.normal`.
    /// Note: If the state is `.normal`, this will return `nil`.
    ///
    /// Mappings to `ARCamera.TrackingState`:
    ///
    /// `.notAvailable` -> `"notAvailable"`
    ///
    /// `.excessiveMotion` -> `"limited.excessiveMotion"`
    ///
    /// `.initializing` -> `"limited.initializing"`
    ///
    /// `.insufficientFeatures` -> `"limited.insufficientFeatures"`
    ///
    /// `.relocalizing` -> `"limited.relocalizing"`
    ///
    /// - parameter frame: The `ARFrame` you wish to inspect.
    ///
    func trackingStateString(for frame: ARFrame) -> String? {
        switch frame.camera.trackingState {
        case .notAvailable:
            return "notAvailable"
        case let .limited(reason):
            switch reason {
            case .excessiveMotion:
                return "limited.excessiveMotion"
            case .initializing:
                return "limited.initializing"
            case .insufficientFeatures:
                return "limited.insufficientFeatures"
            case .relocalizing:
                return "limited.relocalizing"
            @unknown default:
                assertionFailure("New ARCamera.TrackingState cases.")
                return nil
            }
        case .normal:
            return nil
        }
    }
}

// MARK: - Exporting Data

extension EyeTracking {
    ///
    /// Exports a `Session` for the given `sessionID` on this device to a `Data` object.
    /// This includes both what is stored in memory and what is stored on disk.
    ///
    /// - parameter encoding: Provide a key encoding strategy for the object's json keys.
    ///
    /// - Throws: Passes along any failure from `JSONEncoder`.
    ///
    public func export(sessionID: String, with encoding: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) throws -> Data? {
        guard let session = sessions.first(where: { $0.id.uuidString == sessionID }) else { return nil }
        // TODO: Check for sessions on disk.
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = encoding
        return try encoder.encode(session)
    }

    ///
    /// Exports a `Session` for the given `sessionID` on this device to a `String` in json format.
    /// This includes both what is stored in memory and what is stored on disk.
    ///
    /// - parameter encoding: Provide a key encoding strategy for the object's json keys.
    ///
    /// - Throws: Passes along any failure from `JSONEncoder`.
    ///
    public func exportString(sessionID: String, with encoding: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) throws -> String? {
        guard let data = try export(sessionID: sessionID, with: encoding) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    ///
    /// Exports all sessions on this device to a `Data` object.
    /// This includes both what is stored in memory and what is stored on disk.
    ///
    /// - parameter encoding: Provide a key encoding strategy for the object's json keys.
    ///
    /// - Throws: Passes along any failure from `JSONEncoder`.
    ///
    public func exportAll(with encoding: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = encoding
        // TODO: Get sessions from disk.
        return try encoder.encode(sessions)
    }

    ///
    /// Exports all sessions on this device to a `String` in json format.
    /// This includes both what is stored in memory and what is stored on disk.
    ///
    /// - parameter encoding: Provide a key encoding strategy for the object's json keys.
    ///
    /// - Throws: Passes along any failure from `JSONEncoder`.
    ///
    public func exportAllString(with encoding: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) throws -> String? {
        let data = try exportAll(with: encoding)
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Importing Data

extension EyeTracking {
    ///
    /// Import a `Session` from a `Data` object. This can be useful if using an API to pull a `Session` with `URLSession`.
    ///
    /// - parameter data: The object of type `Data` that contains a single `Session`.
    ///
    /// - Throws: Passes along any failure from `JSONDecoder`.
    ///
    public func importSession(from data: Data) throws {
        let session = try JSONDecoder().decode(Session.self, from: data)
        sessions.append(session)
    }

    ///
    /// Import an array of `Session`s from a `Data` object. This can be useful if using an API to pull `Session`s with `URLSession`.
    ///
    /// - parameter data: The object of type `Data` that contains an array of `Session`s.
    ///
    /// - Throws: Passes along any failure from `JSONDecoder`.
    ///
    public func importSessions(from data: Data) throws {
        let sessions = try JSONDecoder().decode([Session].self, from: data)
        self.sessions.append(contentsOf: sessions)
    }

    ///
    /// Import a `Session` from a `String`, which is expected to be in JSON format.
    /// Use this to re-import any single session exported with `exportSession`.
    ///
    /// - parameter jsonString: The object of type `String` that contains a single `Session`.
    ///
    /// - Throws: Passes along any failure from `JSONDecoder`.
    ///
    public func importSession(from jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8) else {
            assertionFailure("Error converting Session string to Data object. Check string encoding.")
            return
        }

        try importSession(from: data)
    }

    ///
    /// Import an array of `Session`s from a `String`, which is expected to be in JSON format.
    /// Use this to re-import any exported list of sessions exported with `exportSessions`.
    ///
    /// - parameter jsonString: The object of type `String` that contains an array of `Session` objects.
    ///
    /// - Throws: Passes along any failure from `JSONDecoder`.
    ///
    public func importSessions(from jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8) else {
            assertionFailure("Error converting Session string to Data object. Check string encoding.")
            return
        }
        try importSessions(from: data)
    }
}

// MARK: - Live Pointer Management

extension EyeTracking {
    /// Call this function to display a live view of the user's gaze point.
    public func showPointer() {
        window.addSubview(pointer)
    }

    /// Call this function to hide the live view of the user's gaze point.
    public func hidePointer() {
        pointer.removeFromSuperview()
    }

    /// Update the live pointer's position to a given point. This location will be smoothed using `LowPassFilter`.
    func updatePointer(with point: CGPoint) {
        let size = UIScreen.main.bounds.size
        // FIXME: The calculation changes based on screen orientation.
        smoothX.update(with: (size.width / 2) - point.x)
        smoothY.update(with: (size.height * 1.25) - point.y)

        if loggingEnabled {
            os_log(
                "Raw:       %{public}f, %{public}f",
                log: Log.gaze,
                type: .info,
                point.x,
                point.y
            )

            os_log(
                "Converted: %{public}f, %{public}f",
                log: Log.gaze,
                type: .info,
                smoothX.value,
                smoothY.value
            )
        }

        pointer.frame = CGRect(
            x: smoothX.value,
            y: smoothY.value,
            width: pointer.frame.width,
            height: pointer.frame.height
        )
    }
}
