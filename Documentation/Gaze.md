# Gaze

Stores the value and all contextual data for a collected `Gaze` point,
or the point in the screen coordinate space at which the user is looking.

``` swift
public struct Gaze: Codable
```

## Inheritance

`Codable`

## Properties

### `orientation`

An `Int` representing the rawValue of `UIInterfaceOrientation`.

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

### `x`

x position of the `Gaze`, in screen coordinate space.

``` swift
let x: CGFloat
```

### `y`

y position of the `Gaze`, in screen coordinate space.

``` swift
let y: CGFloat
```
