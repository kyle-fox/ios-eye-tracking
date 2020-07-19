# EyeTracking

EyeTracking is a class for easily recording a user's gaze location, using
`ARKit`'s eye tracking capabilities, and, optionally, any number of facial
tracking data points. See `Configuration` for more information.

``` swift
public class EyeTracking: NSObject
```

## Inheritance

`ARSessionDelegate`, `NSObject`

## Initializers

### `init(configuration:)`

Create an instance of `EyeTracking` with a given `Configuration`.

``` swift
public required init(configuration: Configuration)
```

> Warning: You must store a strong reference to this class or else risk losing a session's data.

#### Parameters

  - configuration: - configuration: The initial configuration object for EyeTracking. See its documentation for details.

## Properties

### `currentSession`

The currently running `Session`. If this is `nil`, then no `Session` is in progress.

``` swift
var currentSession: Session?
```

### `loggingEnabled`

Set this value to true to enable logging through `os.log`. This is very lightweight,
so it can be used in user builds, which can be inspected at any time with `Console.app`.
Defaults to `false` to prevent too much noise in Xcode's console.

``` swift
var loggingEnabled
```

### `arSession`

Initialize `ARKit`'s `ARSession` when the class is created. This is the most lightweight
method for accessing all facial tracking features.

``` swift
let arSession
```

### `configuration`

Internal storage for the `Configuration` object. This is created at initialization.

``` swift
var configuration: Configuration
```

### `timeOffset`

`ARFrame`'s timestamp value is relative to `systemUptime`. Use this offset to convert to Unix time.

``` swift
let timeOffset: TimeInterval
```

### `window`

``` swift
var window: UIWindow
```

### `smoothX`

These values are used by the live pointer for smooth display onscreen.

``` swift
var smoothX
```

### `smoothY`

``` swift
var smoothY
```

### `pointer`

A small, round dot for viewing live gaze point onscreen.

``` swift
var pointer: UIView
```

To display, call `showPointer` any time after the session starts.
Default size is 30x30 and color is blue, but this can be customized
like any other `UIView`.

## Methods

### `startSession()`

Start an eye tracking `Session`.

``` swift
public func startSession()
```

> Warning: Check that \`currentSession\` is not \`nil\` before calling. This function will fail if there is a current \`Session\` in progress.

### `endSession()`

End an eye tracking `Session`.

``` swift
public func endSession()
```

When this function is called, the `Session` is saved to disk and can be exported at any time.

### `session(_:didUpdate:)`

``` swift
public func session(_ session: ARSession, didUpdate frame: ARFrame)
```

### `trackingStateString(for:)`

Returns a string representation as reported by the given ARFrame's camera, if it reports anything
other than `.normal`. Note: If the state is `.normal`, this will return `nil`.

``` swift
static func trackingStateString(for frame: ARFrame) -> String?
```

Mappings to `ARCamera.TrackingState`:

`.notAvailable` -\> `"notAvailable"`

`.excessiveMotion` -\> `"limited.excessiveMotion"`

`.initializing` -\> `"limited.initializing"`

`.insufficientFeatures` -\> `"limited.insufficientFeatures"`

`.relocalizing` -\> `"limited.relocalizing"`

#### Parameters

  - frame: - frame: The `ARFrame` you wish to inspect.

### `export(sessionID:with:)`

Exports a `Session` for the given `sessionID` on this device to a `Data` object.
This includes both what is stored in memory and what is stored on disk.

``` swift
public static func export(sessionID: String, with encoding: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) throws -> Data?
```

#### Parameters

  - encoding: - encoding: Provide a key encoding strategy for the object's json keys.

#### Throws

Passes along any failure from `JSONEncoder`.

### `exportString(sessionID:with:)`

Exports a `Session` for the given `sessionID` on this device to a `String` in json format.
This includes both what is stored in memory and what is stored on disk.

``` swift
public static func exportString(sessionID: String, with encoding: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) throws -> String?
```

#### Parameters

  - encoding: - encoding: Provide a key encoding strategy for the object's json keys.

#### Throws

Passes along any failure from `JSONEncoder`.

### `exportAll(with:)`

Exports all sessions on this device to a `Data` object.
This includes both what is stored in memory and what is stored on disk.

``` swift
public static func exportAll(with encoding: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) throws -> Data?
```

#### Parameters

  - encoding: - encoding: Provide a key encoding strategy for the object's json keys.

#### Throws

Passes along any failure from `JSONEncoder`.

### `exportAllString(with:)`

Exports all sessions on this device to a `String` in json format.
This includes both what is stored in memory and what is stored on disk.

``` swift
public static func exportAllString(with encoding: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) throws -> String?
```

#### Parameters

  - encoding: - encoding: Provide a key encoding strategy for the object's json keys.

#### Throws

Passes along any failure from `JSONEncoder`.

### `importSession(from:with:)`

Import a `Session` from a `Data` object. This can be useful if using an API to pull
a `Session` with `URLSession`.

``` swift
public static func importSession(from data: Data, with decoding: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws
```

#### Parameters

  - data: - data: The object of type `Data` that contains a single `Session`.

#### Throws

Passes along any failure from `JSONDecoder`.

### `importSessions(from:with:)`

Import an array of `Session`s from a `Data` object. This can be useful if using an API
to pull `Session`s with `URLSession`.

``` swift
public static func importSessions(from data: Data, with decoding: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws
```

#### Parameters

  - data: - data: The object of type `Data` that contains an array of `Session`s.

#### Throws

Passes along any failure from `JSONDecoder`.

### `importSession(from:with:)`

Import a `Session` from a `String`, which is expected to be in JSON format.
Use this to re-import any single session exported with `exportSession`.

``` swift
public static func importSession(from jsonString: String, with decoding: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws
```

#### Parameters

  - jsonString: - jsonString: The object of type `String` that contains a single `Session`.

#### Throws

Passes along any failure from `JSONDecoder`.

### `importSessions(from:with:)`

Import an array of `Session`s from a `String`, which is expected to be in JSON format.
Use this to re-import any exported list of sessions exported with `exportSessions`.

``` swift
public static func importSessions(from jsonString: String, with decoding: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws
```

#### Parameters

  - jsonString: - jsonString: The object of type `String` that contains an array of `Session` objects.

#### Throws

Passes along any failure from `JSONDecoder`.

### `showPointer()`

Call this function to display a live view of the user's gaze point.

``` swift
public func showPointer()
```

### `hidePointer()`

Call this function to hide the live view of the user's gaze point.

``` swift
public func hidePointer()
```

### `updatePointer(with:)`

Update the live pointer's position to a given point. This location will be smoothed using `LowPassFilter`.

``` swift
func updatePointer(with point: CGPoint)
```

### `displayScanpath(for:color:animated:duration:)`

Draws a line on screen that follows the gaze location for a given sessionID

``` swift
public static func displayScanpath(for sessionID: String, color: UIColor = .blue, animated: Bool, duration: Double? = nil)
```

#### Parameters

  - sessionID: - sessionID: Identifier for the `Session` you wish to display on screen
  - color: - color: A `UIColor` value that determines the color of the display path. Defaults to `.blue`
  - animated: - animated: Boolean value determining whether or not to animate the scanpath. Optionally set a duration below.
  - duration: - duration: Animation duration. Defaults to the duration at which the data was collected.
