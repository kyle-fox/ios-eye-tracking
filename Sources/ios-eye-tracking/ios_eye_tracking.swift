import ARKit
import UIKit

/// EyeTracking is a class for easily recording a user's gaze location and blink data.
public class EyeTracking: NSObject {

    // MARK: - Public Properties

    public var sessions = [Session]()
    public var currentSession: Session?

    // MARK: - Internal Properties

    let arSession = ARSession()
    weak var viewController: UIViewController?

    // MARK: - Live Pointer

    /// These values are used by the pointer for smooth display onscreen.
    var smoothGravityX = LowPassFilterSignal(value: 0, filterFactor: 0.85)
    var smoothGravityY = LowPassFilterSignal(value: 0, filterFactor: 0.85)

    /// A small, round dot for viewing live gaze point onscreen.
    ///
    /// To display, provide a **fullscreen** `viewController` in `startSession` and call `showPointer` any time after the session starts.
    /// Default size is 30x30, and color is blue. This `UIView` can be customized at any time.
    public lazy var pointer: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        view.layer.cornerRadius = view.frame.size.width / 2
        view.layer.cornerCurve = .continuous
        view.backgroundColor = .blue
        return view
    }()

    // MARK: - Session Management

    /// Start an eye tracking Session.
    ///
    /// - parameter viewController: Optionally provide a view controller over which you wish to display onscreen diagnostics, like when using `showPointer`.
    ///
    public func startSession(with viewController: UIViewController? = nil) {
        guard ARFaceTrackingConfiguration.isSupported else {
            assertionFailure("Face tracking not supported on this device.")
            return
        }
        guard currentSession == nil else {
            assertionFailure("⛔️ Session already in progress. Call endSession() before calling this function again. ⛔️")
            return
        }

        currentSession = Session()

        let configuration = ARFaceTrackingConfiguration()
        configuration.worldAlignment = .gravity

        arSession.delegate = self
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        self.viewController = viewController
    }

    /// End an eye tracking Session.
    ///
    /// When this function is called, the Session is saved, ready for exporting in JSON.
    public func endSession() {
        arSession.pause()
        currentSession?.endTime = Date().timeIntervalSince1970

        guard let currentSession = currentSession else { return }
        sessions.append(currentSession)
        self.currentSession = nil
    }

    // MARK: - Live Pointer Management

    /// Call this function to display a live view of the user's gaze point.
    public func showPointer() {
        viewController?.view.addSubview(pointer)
        viewController?.view.bringSubviewToFront(pointer)
    }

    /// Call this function to hide the live view of the user's gaze point.
    public func hidePointer() {
        pointer.removeFromSuperview()
    }
}

// MARK: - ARSessionDelegate

extension EyeTracking: ARSessionDelegate {
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let anchor = frame.anchors.first as? ARFaceAnchor else { return }

        // Convert to world space.
        let point = anchor.transform * SIMD4<Float>(anchor.lookAtPoint, 1)

        // Project into screen coordinates.
        let screenPoint = frame.camera.projectPoint(
            SIMD3<Float>(x: point.x, y: point.y, z: point.z),
            orientation: UIApplication.shared.windows.first!.windowScene!.interfaceOrientation,
            viewportSize: UIScreen.main.bounds.size
        )

        // TODO: The calculation changes based on screen orientation.
        smoothGravityX.update(newValue: (UIScreen.main.bounds.size.width / 2) - screenPoint.x)
        smoothGravityY.update(newValue: (UIScreen.main.bounds.size.height * 1.25) - screenPoint.y)
        currentSession?.scanPath.append(Gaze(x: screenPoint.x, y: screenPoint.y))

        print("⛔️ \(smoothGravityX), \(smoothGravityY)")

        pointer.frame = CGRect(
            x: smoothGravityX.value,
            y: smoothGravityY.value,
            width: pointer.frame.width,
            height: pointer.frame.height
        )
    }
}

public struct Session: Codable {
    public var beginTime = Date().timeIntervalSince1970
    public var endTime: TimeInterval?
    public var scanPath = [Gaze]()
}

public struct Gaze: Codable {
    public var timestamp = Date().timeIntervalSince1970
    public let x: CGFloat
    public let y: CGFloat
}

struct LowPassFilterSignal {
    /// Current signal value
    var value: CGFloat

    /// A scaling factor in the range 0.0..<1.0 that determines how resistant the value is to change
    let filterFactor: CGFloat

    /// Update the value, using filterFactor to attenuate changes
    mutating func update(newValue: CGFloat) {
        value = filterFactor * value + (1.0 - filterFactor) * newValue
    }
}
