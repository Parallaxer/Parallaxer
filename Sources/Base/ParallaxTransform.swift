/// A parallax transform is the result of one or more parallax operations, which can be performed using any of
/// the following operators:
///   - `relate(to:)`
///   - `morph(with:)`
///   - `focus(on:)`
///
/// A parallax transform can be converted back into a value suitable for the user interface with the
/// following operator:
///   - `parallaxValue()`
public struct ParallaxTransform<ValueType: Parallaxable>: Equatable {

    /// An interval denoting the bounds of the transform.
    public let interval: ParallaxInterval<ValueType>

    /// A point on the unit interval, [0, 1], which refers to a value on `interval`. (0 refers to the
    /// beginning of the interval and 1 refers to the end.)
    ///
    /// A position may be less than 0 or greater than 1 if it refers to a value outside the bounds of
    /// `interval`.
    public let position: Double

    /// Initialize a parallax transform with an interval denoting its bounds, and a value to which its unit
    /// position shall refer.
    ///
    /// - Parameter interval:       The interval on which change is expected to occur.
    /// - Parameter parallaxValue:  A value to which the transform's position shall refer.
    public init(interval: ParallaxInterval<ValueType>, parallaxValue: ValueType) {
        self.interval = interval
        self.position = interval.position(forValue: parallaxValue)
    }

    /// Internal initializer.
    /// - Parameter interval: The interval on which change is expected to occur.
    /// - Parameter position: A number between [0, 1] denoting a value on `interval`.
    init(interval: ParallaxInterval<ValueType>, position: Double) {
        self.interval = interval
        self.position = position
    }
}

extension ParallaxTransform {

    /// A value on the receiver's `interval`, as indicated by its `position`.
    ///
    /// By default, values are not strictly bounded by the transform interval; if that behavior is desired,
    /// first apply a clamp operation:
    /// ```
    /// morph(with: .clampToUnitInterval)
    /// ```
    /// - Returns: A value on the receiver's transform interval, suitable for the user interface.
    public func parallaxValue() -> ValueType {
        return interval.value(atPosition: position)
    }

    /// Transform the receiver such that the resulting value is proportional to the given `newInterval`, and
    /// is of type `ResultValueType`.
    ///
    /// # Resulting transform characteristics:
    ///   - The interval is the given `newInterval`.
    ///   - The receiver's position is preserved.
    ///   - `parallaxValue` is relative to the receiver's position, but on the given `newInterval`, and
    ///   is of type, `ResultValueType`.
    ///
    /// # Ex: Relate values from a Double-typed interval [0, 3], to a CGFloat-typed interval, [0, 6]:
    ///     // receiving transform:
    ///     //   [0                 3]                      receiver's interval: [0, 3]
    ///     //    0       .5       (1)                      receiver's position: 1
    ///     //    0     1     2    (3)    4                 receiver's value: 3
    ///     let receiver = ParallaxTransform(
    ///         interval: ParallaxInterval(from: 0, to: 3)!,
    ///         value: 3)
    ///
    ///     // resulting transform:
    ///     //   [0                                    6]   result interval: [0, 6]
    ///     //    0                .5                 (1)   result position: 1 (unchanged)
    ///     //    0     1     2     3     4      5    (6)   result value: 6
    ///     let result = receiver
    ///         .relate(to: ParallaxInterval<CGFloat>(from: 0, to: 6)!)
    ///
    /// - Parameter newInterval: The interval of the resulting transform.
    /// - Returns: A new parallax transform, with a `parallaxValue` relative to the receiver's position,
    ///  but on the given `newInterval`, and of type, `ResultValueType`.
    public func relate<ResultValueType>(
        to newInterval: ParallaxInterval<ResultValueType>)
        -> ParallaxTransform<ResultValueType>
    {
        return ParallaxTransform<ResultValueType>(interval: newInterval, position: position)
    }

    /// Transform the receiver such that the resulting position respects the given `curve` function.
    ///
    /// # Resulting transform characteristics:
    ///   - The receiver's interval is preserved.
    ///   - The position has changed in accordance with the curve function.
    ///   - `parallaxValue` is relative to the new position, on the receiver's interval.
    ///
    /// # Ex: Morph such that values are clamped to interval, [0, 3]:
    ///     // receiving transform:
    ///     //        [1           3]           receiver's interval: [1, 3]
    ///     //  ...    0    .5     1  (1.5)     receiver's position: 1.5
    ///     //   0     1     2     3    (4)     receiver's value: 4
    ///     let receiver = ParallaxTransform(
    ///         interval: ParallaxInterval(from: 0, to: 3)!,
    ///         value: 4)
    ///
    ///     // resulting transform:
    ///     //        [1           3]           result interval: [1, 3] (unchanged)
    ///     //        >0    .5    (1)<  1.5     result position: 1
    ///     //   0    >1     2    (3)<   4      result value: 3
    ///     let result = receiver
    ///         .morph(with: .clampToUnitInterval)
    ///
    /// - Parameter curve: The curve with which to alter the receiver's position.
    /// - Returns: A new parallax transform, with the receiver's position transformed by the given
    /// `curve` function; the resulting `parallaxValue` is relative to this new position, on the
    /// receiver's interval.
    public func morph(with curve: PositionCurve) -> ParallaxTransform<ValueType> {
        let transformedPosition = curve.transform(position: position)
        return ParallaxTransform(interval: interval, position: transformedPosition)
    }

    /// Transform the receiver such that the resulting position reflects progress over a portion of the
    /// receiver's interval, given by `subinterval`.
    ///
    /// # Resulting transform characteristics:
    ///   - The interval is `subinterval`.
    ///   - The position has changed such that the receiver's `parallaxValue` is preserved.
    ///   - The receiver's `parallaxValue` is preserved.
    ///
    /// # Ex: Focus the subinterval, [2, 4]:
    ///     // receiving transform:
    ///     //   [0                       4]   receiver's interval: [0, 4]
    ///     //   [0    .25   .5    .75    1]   receiver's position: .25
    ///     //    0    (1)    2     3     4    receiver's value: 1
    ///     let receiver = ParallaxTransform(
    ///         interval: ParallaxInterval(from: 0, to: 4)!,
    ///         value: 1)
    ///
    ///     // resulting transform:
    ///     //               [2           4]   `subinterval`: [2, 4]
    ///     //   -1   -.5     0    .5     1    result position: -.5
    ///     //    0    (1)    2     3     4    result value: 1 (unchanged)
    ///     let result = receiver
    ///         .changeIntervalAndPreserveValue(ParallaxInterval(from: 2, to: 4)!)
    ///
    /// - Parameter subinterval: The interval of the resulting transform.
    /// - Returns: A new parallax transform which maps the receiver's `parallaxValue` to the same value, but
    /// on the given `subinterval`.
    public func focus(
        on subinterval: ParallaxInterval<ValueType>)
        -> ParallaxTransform<ValueType>
    {
        let valueOnPriorInterval = interval.value(atPosition: position)
        let transformedPosition = subinterval.position(forValue: valueOnPriorInterval)
        return ParallaxTransform(interval: subinterval, position: transformedPosition)
    }
}

extension ParallaxTransform: CustomStringConvertible {

    public var description: String {
        return "ParallaxTransform<\( String(describing: ValueType.self))>("
            + "interval: \(interval)"
            + ", position: \(position)"
            + ", parallaxValue: \(parallaxValue())"
            + ")"
    }
}
