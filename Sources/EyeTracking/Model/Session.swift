import Foundation

/// Stores the value and all contextual data for a collected `Session`.
public struct Session: Codable {
    /// A unique identifier for this `Session`, created at initialization.
    public let id: UUID

    /// An identifier for the source application where the data was collected.
    /// This can be configured when `EyeTracking` is initialized, through a
    /// `Configuration` object.
    public let appID: String

    /// A UNIX timestamp for when this `Session` began.
    public var beginTime = Date().timeIntervalSince1970

    /// Contains all relevant device data.
    private(set) public var deviceInfo = DeviceInfo()

    /// A UNIX timestamp for when this `Session` ended.
    public var endTime: TimeInterval?

    /// An array of `Gaze` points. This is the main storage for a session.
    public var scanPath = [Gaze]()

    /// A dictionary of arrays of values for configured `BlendShape` data points.
    /// See `BlendShape` for more information and `Configuration` for specifying
    /// which `BlendShape`s a `Session` will collect.
    public var blendShapes = [String: [BlendShape]]()
}
