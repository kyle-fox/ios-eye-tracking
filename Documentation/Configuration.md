# Configuration

An object for configuring an `EyeTracking` session.

``` swift
public struct Configuration
```

## Initializers

### `init(appID:blendShapes:)`

Initialize a `Configuration`.

``` swift
public init(appID: String? = nil, blendShapes: [ARFaceAnchor.BlendShapeLocation]? = nil)
```

#### Parameters

  - appID: - appID: Optionally provide a `String` for an app id for `Session`s. Default value is the app's `bundleID`.
  - blendShapes: - blendShapes: Optionally provide an array of `BlendShapeLocation`s to track any number of `ARKit`'s provided facial recognition values.

## Properties

### `appID`

This `appID` will be tied to all `Session`s. Default value is the app's bundleID (recommended).

``` swift
let appID: String
```

### `blendShapes`

Stores any number of `BlendShapeLocation`s for tracking and storing during sessions.
See README or Apple's documentation for possible values.

``` swift
let blendShapes: [ARFaceAnchor.BlendShapeLocation]
```

### `framesPerSecond`

Stores the desired fidelity for a `Session`'s storage in FPS.
Max is 60 fps from `ARKit` as of iOS 14.

``` swift
let framesPerSecond: Int
```
