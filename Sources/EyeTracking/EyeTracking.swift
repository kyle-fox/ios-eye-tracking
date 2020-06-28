import ARKit
import UIKit

/// EyeTracking is a class for easily recording a user's gaze location and blink data.
public class EyeTracking: NSObject {

    // MARK: - Public Properties

    /// Array of sessions completed during the app's runtime.
    public var sessions = [Session]()

    /// The currently running session. If this is `nil`, then no session is in progress.
    public var currentSession: Session?

    // MARK: - Internal Properties

    let arSession = ARSession()
    weak var viewController: UIViewController?

    /// ARFrame's timestamp value is relative to `systemUptime`. Use this offset to convert to Unix time.
    let timeOffset: TimeInterval = Date().timeIntervalSince1970 - ProcessInfo.processInfo.systemUptime

    // MARK: - Live Pointer

    /// These values are used by the live pointer for smooth display onscreen.
    var smoothX = LowPassFilter(value: 0, filterValue: 0.85)
    var smoothY = LowPassFilter(value: 0, filterValue: 0.85)

    /// A small, round dot for viewing live gaze point onscreen.
    ///
    /// To display, provide a **fullscreen** `viewController` in `startSession` and
    /// call `showPointer` any time after the session starts.
    /// Default size is 30x30, and color is blue. This `UIView` can be customized at any time.
    ///
    public lazy var pointer: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        view.layer.cornerRadius = view.frame.size.width / 2
        view.layer.cornerCurve = .continuous
        view.backgroundColor = .blue
        return view
    }()
}

// MARK: - Session Management

extension EyeTracking {
    /// Start an eye tracking Session.
    ///
    /// - parameter viewController: Optionally provide a view controller over which you
    /// wish to display onscreen diagnostics, like when using `showPointer`.
    ///
    public func startSession(with viewController: UIViewController? = nil) {
        guard ARFaceTrackingConfiguration.isSupported else {
            assertionFailure("Face tracking not supported on this device.")
            return
        }
        guard currentSession == nil else {
            assertionFailure("Session already in progress. Must call endSession() first.")
            return
        }

        // Set up local properties.
        currentSession = Session(id: UUID())
        self.viewController = viewController

        // Configure and start the ARSession to begin face tracking.
        let configuration = ARFaceTrackingConfiguration()
        configuration.worldAlignment = .camera

        arSession.delegate = self
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    /// End an eye tracking Session.
    ///
    /// When this function is called, the Session is saved, ready for exporting in JSON.
    ///
    public func endSession() {
        arSession.pause()
        currentSession?.endTime = Date().timeIntervalSince1970

        guard let currentSession = currentSession else {
            assertionFailure("endSession() called when no session is in progress.")
            return
        }

        // Save session and reset local state.
        sessions.append(currentSession)
        self.currentSession = nil
        viewController = nil
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

        currentSession?.scanPath.append(
            Gaze(timestamp: frameTimestampUnix, x: screenPoint.x, y: screenPoint.y)
        )

        if let eyeBlinkLeft = anchor.blendShapes[.eyeBlinkLeft]?.doubleValue {
            currentSession?.blinks.append(
                Blink(timestamp: frameTimestampUnix, eye: .left, value: eyeBlinkLeft)
            )
        }

        if let eyeBlinkRight = anchor.blendShapes[.eyeBlinkRight]?.doubleValue {
            currentSession?.blinks.append(
                Blink(timestamp: frameTimestampUnix, eye: .right, value: eyeBlinkRight)
            )
        }

//        print("👀 Left: \(anchor.blendShapes[.eyeBlinkLeft] ?? -1), Right: \(anchor.blendShapes[.eyeBlinkRight] ?? -1)")

        // Update UI

        updatePointer(with: screenPoint)
    }
}

// MARK: - Live Pointer Management

extension EyeTracking {
    /// Call this function to display a live view of the user's gaze point.
    public func showPointer() {
        guard let viewController = viewController else {
            assertionFailure("Must start a session and provide a viewController.")
            return
        }
        viewController.view.addSubview(pointer)
        viewController.view.bringSubviewToFront(pointer)
    }

    /// Call this function to hide the live view of the user's gaze point.
    public func hidePointer() {
        pointer.removeFromSuperview()
    }

    func updatePointer(with point: CGPoint) {
        guard let size = viewController?.view.bounds.size else { return }
        // TODO: The calculation changes based on screen orientation.
        smoothX.update(with: (size.width / 2) - point.x)
        smoothY.update(with: (size.height * 1.25) - point.y)

        print("⛔️ \(point.x), \(point.y)")
        print("🔵 \(smoothX.value), \(smoothY.value)")

        pointer.frame = CGRect(
            x: smoothX.value,
            y: smoothY.value,
            width: pointer.frame.width,
            height: pointer.frame.height
        )
    }
}
