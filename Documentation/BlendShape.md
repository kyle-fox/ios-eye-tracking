# BlendShape

Stores the value and all contextual data for a collected `BlendShape`
value from `ARKit`'s `BlendShapeLocation`.

``` swift
public struct BlendShape: Codable
```

## Inheritance

`Codable`

## Initializers

### `init(blendShapeLocation:timestamp:trackingState:value:)`

Simple memberwise initializer for converting
`ARFaceAnchor.BlendShapeLocation` to its `rawValue` string.

``` swift
init(blendShapeLocation: ARFaceAnchor.BlendShapeLocation, timestamp: TimeInterval, trackingState: String?, value: Double)
```

## Properties

### `blendShapeLocation`

A string representation of `ARFaceAnchor.BlendShapeLocation` from
its `rawValue`. See Apple's documentation for more information.

``` swift
let blendShapeLocation: String
```

### `orientation`

An `Int` representing the rawValue of `UIDeviceOrientation`.

``` swift
var orientation
```

### `timestamp`

A UNIX timestamp for when this data point was collected.

``` swift
let timestamp: TimeInterval
```

### `trackingState`

The reported tracking state for this data point, as reported
by its `ARFrame`'s `ARCamera` instance. If `nil`, then data
quality is normal.

``` swift
let trackingState: String?
```

### `value`

The data point's value - a numerical value from 0.0 to 1.0.
See Apple's documentation for each `BlendShapeLocation` for specific
interpretation information for this value.

``` swift
let value: Double
```
