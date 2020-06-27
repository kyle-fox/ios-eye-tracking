import UIKit

public struct Gaze: Codable {
    public var timestamp = Date().timeIntervalSince1970
    public let x: CGFloat
    public let y: CGFloat
}
