import UIKit

/// A struct for storing device information.
public struct DeviceInfo: Codable {
    private(set) public var model = UIDevice.current.modelName
    private(set) public var screenSize = UIScreen.main.fixedCoordinateSpace.bounds.size
    private(set) public var systemName = UIDevice.current.systemName
    private(set) public var systemVersion = UIDevice.current.systemVersion
}

extension UIDevice {
    ///
    /// UIDevice extension for getting specific device model number from this StackOverflow answer:
    /// https://stackoverflow.com/a/11197770
    ///
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
