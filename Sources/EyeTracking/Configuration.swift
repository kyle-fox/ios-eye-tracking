import ARKit
import Foundation

/// TODO: Documentation
public struct Configuration {
    public let appID: String
    public let blendShapes: [ARFaceAnchor.BlendShapeLocation]
    public let framesPerSecond: Int = 60 // MAX 60

    public init(appID: String, blendShapes: [ARFaceAnchor.BlendShapeLocation]? = nil) {
        self.appID = appID
        self.blendShapes = blendShapes ?? []
    }
}
