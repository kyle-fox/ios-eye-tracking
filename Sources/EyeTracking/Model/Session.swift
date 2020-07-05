import Foundation

public struct Session: Codable {
    public let id: UUID
    public let appID: String
    public var beginTime = Date().timeIntervalSince1970
    public var endTime: TimeInterval?

    public var scanPath = [Gaze]()
    public var blendShapes = [String: [BlendShape]]()
}
