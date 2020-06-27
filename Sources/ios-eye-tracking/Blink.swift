import Foundation

public struct Blink: Codable {
    public enum Eye: String, Codable {
        case left
        case right
    }

    public var timestamp = Date().timeIntervalSince1970
    public let eye: Eye
    public let value: Double
}
