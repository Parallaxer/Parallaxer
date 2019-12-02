/// Values of a conforming type may be transformed by `ParallaxTransform`.
public protocol Parallaxable: Equatable {
    
    /// Convert the given `value` to a unit position on the interval [`from`, `to`].
    ///
    /// # 🔢 Position formula:
    /// ```
    /// (value - from) / (to - from)
    /// ```
    ///
    /// Note: There is no need to protect against divide-by-zero, as `ParallaxInterval` shall prevent that.
    ///
    /// - Parameters:
    ///   - value:  A value on the specified interval, [`from`, `to`].
    ///   - from:   The start of the interval.
    ///   - to:     The end of the interval.
    /// - Returns: A position on the unit interval, [0, 1].
    static func position(forValue value: Self, from: Self, to: Self) -> Double
    
    /// Convert the given `position` to a value on the interval [`from`, `to`].
    ///
    /// # 🔢 Value formula:
    /// ```
    /// from * (1 - position) + to * position
    /// ```
    ///
    /// - Parameters:
    ///   - position:   A position on the unit interval, [0, 1].
    ///   - from:       The start of the interval.
    ///   - to:         The end of the interval.
    /// - Returns: A value on the specified interval, [`from`, `to`].
    static func value(atPosition position: Double, from: Self, to: Self) -> Self
}
