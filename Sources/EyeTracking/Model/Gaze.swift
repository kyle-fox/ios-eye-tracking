import ARKit
import UIKit

///
/// Stores the value and all contextual data for a collected `Gaze` point,
/// or the point in the screen coordinate space at which the user is looking.
///
public struct Gaze: Codable {
    /// An `Int` representing the rawValue of `UIInterfaceOrientation`.
    private(set) public var orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.rawValue ?? 0

    /// A UNIX timestamp for when this data point was collected.
    public let timestamp: TimeInterval

    /// The reported tracking state for this data point, as reported
    /// by its `ARFrame`'s `ARCamera` instance. If `nil`, then data
    /// quality is normal.
    public let trackingState: String?

    /// x position of the `Gaze`, in screen coordinate space.
    public let x: CGFloat

    /// y position of the `Gaze`, in screen coordinate space.
    public let y: CGFloat
}
