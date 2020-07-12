import UIKit

///
/// Simple implementation of a low pass filter for `CGFloat` values.
/// Used for smoothing display of facial data on screen.
///
struct LowPassFilter {
    /// Current value
    private(set) var value: CGFloat

    /// Range of 0.0 - 1.0. Determines amount of smoothing.
    let filterValue: CGFloat

    /// Updates the value with smoothing.
    mutating func update(with value: CGFloat) {
        self.value = filterValue * self.value + (1.0 - filterValue) * value
    }
}
