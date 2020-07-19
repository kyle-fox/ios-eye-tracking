# Session

Stores the value and all contextual data for a collected `Session`.

``` swift
public struct Session: Codable, FetchableRecord, PersistableRecord
```

## Inheritance

`Codable`, `FetchableRecord`, `PersistableRecord`

## Properties

### `id`

A UUID identifier string for this `Session`, created at initialization.

``` swift
let id: String
```

### `appID`

An identifier for the source application where the data was collected.
This can be configured when `EyeTracking` is initialized, through a
`Configuration` object.

``` swift
let appID: String
```

### `beginTime`

A UNIX timestamp for when this `Session` began.

``` swift
var beginTime
```

### `deviceInfo`

Contains all relevant device data.

``` swift
var deviceInfo
```

### `endTime`

A UNIX timestamp for when this `Session` ended.

``` swift
var endTime: TimeInterval?
```

### `scanPath`

An array of `Gaze` points. This is the main storage for a session.

``` swift
var scanPath
```

### `blendShapes`

A dictionary of arrays of values for configured `BlendShape` data points.
See `BlendShape` for more information and `Configuration` for specifying
which `BlendShape`s a `Session` will collect.

``` swift
var blendShapes
```
