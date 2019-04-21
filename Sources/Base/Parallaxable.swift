/// Types which conform to `Parallaxable` may represent values in a parallax tree.
public protocol Parallaxable: Hashable {
    
    /// Convert a value over the specified interval to progress over the unit interval.
    ///
    /// - Parameters:
    ///   - value:  A value over the specified interval, [`from`, `to`].
    ///   - from:   The start of the interval.
    ///   - to:     The end of the interval.
    /// - Returns: Progress over the unit interval, [0, 1].
    static func progress(forValue value: Self, from: Self, to: Self) -> Double
    
    /// Convert progress over the unit interval to a value over the specified interval.
    ///
    /// - Parameters:
    ///   - progress:   Progress over the unit interval, [0, 1].
    ///   - from:       The start of the interval.
    ///   - to:         The end of the interval.
    /// - Returns: Value over the specified interval, [`from`, `to`].
    static func value(forProgress progress: Double, from: Self, to: Self) -> Self
}
