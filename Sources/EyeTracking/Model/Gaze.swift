import ARKit
import UIKit

public struct Gaze: Codable {
    public let timestamp: TimeInterval
    public let trackingState: String?
    public let x: CGFloat
    public let y: CGFloat
}
