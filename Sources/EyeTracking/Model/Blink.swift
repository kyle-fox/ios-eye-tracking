import Foundation

public struct Blink: Codable {
    public enum Eye: String, Codable {
        case left
        case right
    }

    public let timestamp: TimeInterval
    public let eye: Eye
    public let value: Double
}
