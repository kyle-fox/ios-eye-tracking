import ARKit
import Foundation

/// TODO: Documentation
public struct Configuration {
    public let blendShapes: [ARFaceAnchor.BlendShapeLocation]
    public let framesPerSecond: Int = 60 // MAX 60

    public init(blendShapes: [ARFaceAnchor.BlendShapeLocation]) {
        self.blendShapes = blendShapes
    }
}
