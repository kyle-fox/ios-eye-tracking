# EyeTracking for iOS

EyeTracking is a Swift Package that makes it easy to use `ARKit`'s eye and facial tracking data, designed for use in Educational Technology research.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Documentation](Documentation/Home.md)
    - [Configuration](Documentation/Configuration.md)
    - [EyeTracking](Documentation/EyeTracking.md)
    - [BlendShape](Documentation/BlendShape.md)
    - [DeviceInfo](Documentation/DeviceInfo.md)
    - [Gaze](Documentation/Gaze.md)
    - [Session](Documentation/Session.md)
- [Usage](#usage)
    - [Privacy Disclosure](#privacy-disclosure)
    - [Initialization](#initialization)
    - [Starting a Session](#starting-a-session)
    - [Ending a Session](#ending-a-session)
    - [Exporting data](#exporting-data)
    - [Importing data](#importing-data)
    - [Logging](#logging)
    - [Visualizations](#visualizations)

## Features

- Create and end `Session`s at any time
- 60 fps stream of gaze location, or where the user is looking at the screen
- Configure any number of [`ARFaceAnchor.BlendShapeLocation`s](https://developer.apple.com/documentation/arkit/arfaceanchor/blendshapelocation) to record
- Data persisted in SQLite with [GRDB.swift](https://github.com/groue/GRDB.swift)
- Data import/export in JSON `Data` or `String` objects
- Live view of gaze location with a customizable `UIView`
- Fixation point and scan path visualizations

## Requirements

- iOS 13.2+
- Xcode 11.0+
- Swift 5.0+
- iPhone X or older / iPad Pro 2018 or older
Note: On release of iOS 14 and ARKit 4, all devices with an A12 Bionic or later will be supported.

## Installation

Install EyeTracking using [Swift Package Manager](https://swift.org/package-manager/) either through Xcode 11+ directly or as a dependency of your own Swift Package. To do the latter, add EyeTracking to the `dependencies` value in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/kyle-fox/ios-eye-tracking", .upToNextMajor(from: "1.0.0"))
]
```

This is the only officially supported installation method - if you wish to use the code directly, you are free to manually integrate EyeTracking into your project.

## Usage

### Privacy Disclosure

`ARKit`'s facial tracking system relies on the front facing TrueDepth camera to capture its data, so you must provide a permission request in your app's `Info.plist`'s `NSCameraUsageDescription`. This will be presented to the user the first time you begin an `EyeTracking` session, and they will be able to deny this permission. See the example application for an example of such request, and when using for research, be sure to inform participants that it is necessary to accept this permission request, when presented.

### Initialization

EyeTracking can be used anywhere within your app, and it is recommended that you configure and store a reference to the `EyeTracking` class where you wish to use it. To do this, you may simply initialize the class by providing a `Configuration`:

```swift
let eyeTracking = EyeTracking(configuration: Configuration(appID: "ios-eye-tracking-example"))
```

You must provide an `appID` upon creation of the class - this is stored in each `Session` as a means of identifying the app from which the data was collected. Optionally, you may configure any number of [`ARFaceAnchor.BlendShapeLocation`s](https://developer.apple.com/documentation/arkit/arfaceanchor/blendshapelocation) and `EyeTracking` will record that data in a Session alongside the gaze location data. This example will track the blink data for both eyes (see [Apple's documentation for more options and information on the data](https://developer.apple.com/documentation/arkit/arfaceanchor/blendshapelocation)):

```swift
let eyeTracking = EyeTracking(configuration: Configuration(appID: "ios-eye-tracking-example", blendShapes: [.eyeBlinkLeft, .eyeBlinkRight]))
```

### Starting a Session

Now that you have the class configured, you are free to start recording data at any time by calling:

```swift
eyeTracking.startSession()
```

This will begin a session and start streaming all data from `ARKit` into a `Session` object. Each `Session` will have a UUID, the `appID` provided at initialization, a UNIX timestamp for the beginning of the session, and device information, including model, screen size, OS name, and OS version. By default, the data streams at 60 fps, so be sure to test your app for memory use, as the size of this data can grow quickly, depending on how many `ARFaceAnchor.BlendShapeLocation`s are configured.

_Note: This package only supports running 1 `Session` at a time._

### Ending a Session

When you would like to end the `Session` that is currently running, you may do so at any time by calling:

```swift
eyeTracking.endSession()
```

This will stop the current `Session` and write all its data to the database, which you may then export at any time.

### Exporting data

`EyeTracking` supports exporting its data in JSON format, in either `Data` or `String` types. You may export either a single session, using it's UUID, or all sessions in the database. For all export functions, you may optionally provide a [`JSONEncoder.KeyEncodingStrategy`](https://developer.apple.com/documentation/foundation/jsonencoder/keyencodingstrategy) to format the data's keys. The default functionality is to use the original, camelCase keys. All of these functions are marked `throws`, passing on their values from their underlying `Codable` functions. Examples:

```swift
// Exports this session as `Data`, using the default Keys
let dataSession = try? eyeTracking.export(sessionID: "8136AD7E-7262-4F07-A554-2605506B985D")

// Exports this session as a `String`, converting the keys to snake case
let stringSession = try? eyeTracking.exportString(sessionID: "8136AD7E-7262-4F07-A554-2605506B985D", with: .convertToSnakeCase)

// Exports all `Session`s as `Data`, using the default keys
let dataSessions = try? eyeTracking.exportAll()

// Exports all `Session`s as a `String`, converting the keys to snake case
let stringSessions = try? eyeTracking.exportAllString(with: .convertToSnakeCase)
```

### Importing data

Importing data may be useful for viewing `Session` data that was collected on another device. These functions are similar to exporting, and the data you provide will be written to the SQLite database for use in the package's visualizations. `Session`s may be in either `Data` or `String` types, but they must be in JSON format - it is safest to import data that has been exported with this package. Similar to exporting, you may provide an optional [`JSONDecoder.KeyDecodingStrategy`](https://developer.apple.com/documentation/foundation/jsondecoder/keydecodingstrategy) if you have keys in snake case or others. All of these functions are marked `throws`, passing on their values from their underlying `Codable` functions. Examples:

```swift
// Imports a `Session` from a JSON `Data` object
try? eyeTracking.importSession(from: data)

// Imports a `Session` from a JSON `String`, converting the data's keys from snake case.
try? eyeTracking.importSession(from: jsonString, with: .convertFromSnakeCase)

// Imports an array of `Session`s from a JSON `Data` object, converting the data's keys from snake case.
try? eyeTracking.importSessions(from: data, with: .convertFromSnakeCase)

// Imports an array of `Session`s from a JSON `String`
try? eyeTracking.importSessions(from: jsonString)
```

### Logging

All logging is done through Apple's lightweight `os.log` system, and logs can be viewed in either the Xcode console or macOS's Console.app. You do not need to be connected to a debug session to view these logs - you may use Console.app to view the logs of any device on the network that is using `EyeTracking`. By default, only critical issues are logged, but you may optionally enable debug logging for all collected data by setting:

```swift
eyeTracking.loggingEnabled = true
```

### Visualizations

#### Live Gaze Location

For debugging purposed, you may wish to view the live gaze location on screen. By default, this uses a blue, 30px by 30px `UIView` called `pointer`, but you may modify this view's configuration at any time before display. To do so, you may call:

```swift
// Optionally make any changes to the pointer
eyeTracking.pointer.backgroundColor = .red

// Begin displaying the pointer
eyeTracking.showPointer()
```

Similarly, you may remove the display at any time:

```swift
eyeTracking.hidePointer()
```

