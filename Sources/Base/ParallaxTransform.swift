/// The result of a parallax transformation, which may be further transformed.
///
/// A parallax transform is the result of one or more parallax transformations, which can be performed
/// using any of the following operators:
///   - `scale(to:)`
///   - `reposition(with:)`
///   - `focus(subinterval:)`
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
    /// - Parameter parallaxValue:  A value to which the transform's unit position shall refer.
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

    /// A value on `interval`, as indicated by `position`; this is suitable for the user interface.
    ///
    /// By default, values are not strictly bounded by the transform interval; if that behavior is desired,
    /// first apply a clamp transformation:
    /// ```
    /// reposition(with: .clampToUnitInterval)
    /// ```
    /// - Returns: A value on the receiver's transform interval, suitable for the user interface.
    public func parallaxValue() -> ValueType {
        return interval.value(atPosition: position)
    }

    /// Create a new parallax transform which scales `parallaxValue` such that it is relative to the
    /// receiver's unit position, but on the given `otherInterval`, and is of type, `ResultValueType`.
    ///
    /// # Resulting transform characteristics:
    ///   - The interval is the given `otherInterval`.
    ///   - The receiver's unit position is preserved.
    ///   - `parallaxValue` is relative to the receiver's unit position, but on the given `otherInterval`, and
    ///   is of type, `ResultValueType`.
    ///
    /// # Ex: Scale values from a Double-typed interval [0, 3], to a CGFloat-typed interval, [0, 6]:
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
    ///         .scale(to: ParallaxInterval<CGFloat>(from: 0, to: 6)!)
    ///
    /// - Parameter interval: The interval of the resulting transform.
    /// - Returns: A new parallax transform, with a `parallaxValue` relative to the receiver's unit position,
    ///  but on the given `otherInterval`, and of type, `ResultValueType`.
    public func scale<ResultValueType>(
        to otherInterval: ParallaxInterval<ResultValueType>)
        -> ParallaxTransform<ResultValueType>
    {
        return ParallaxTransform<ResultValueType>(interval: otherInterval, position: position)
    }

    /// Create a new parallax transform which alters the receiver's unit position in accordance with the given
    /// `curve` function; the resulting `parallaxValue` is relative to this new unit position, on the
    /// receiver's interval.
    ///
    /// # Resulting transform characteristics:
    ///   - The receiver's interval is preserved.
    ///   - The unit position has changed in accordance with the curve function.
    ///   - `parallaxValue` is relative to the new unit position, on the receiver's interval.
    ///
    /// # Ex: Reposition such that values are clamped to interval, [0, 3]:
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
    ///         .reposition(with: .clampToUnitInterval)
    ///
    /// - Parameter curve: The curve with which to alter the receiver's unit position.
    /// - Returns: A new parallax transform, with the receiver's unit position transformed by the given
    /// `curve` function; the resulting `parallaxValue` is relative to this new unit position, on the
    /// receiver's interval.
    public func reposition(with curve: PositionCurve) -> ParallaxTransform<ValueType> {
        let transformedPosition = curve.transform(position: position)
        return ParallaxTransform(interval: interval, position: transformedPosition)
    }

    /// Create a new parallax transform which preserves the receiver's `parallaxValue`, but alters its unit
    /// position such that it corresponds to the given `subinterval`.
    ///
    /// - Note: `subinterval` need not be a strict subset of the receiver's interval.
    ///
    /// # Resulting transform characteristics:
    ///   - The interval is `subinterval`.
    ///   - The unit position has changed such that the receiver's `parallaxValue` is preserved.
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
    ///         .focus(subinterval: ParallaxInterval(from: 2, to: 4)!)
    ///
    /// - Parameter subinterval: A subset of the receiver's interval.
    /// - Returns: A new parallax transform which maps the receiver's `parallaxValue` to the same value, but
    /// on the given `subinterval`.
    public func focus(subinterval: ParallaxInterval<ValueType>) -> ParallaxTransform<ValueType> {
        let valueOnPriorInterval = interval.value(atPosition: position)
        let transformedPosition = subinterval.position(forValue: valueOnPriorInterval)
        return ParallaxTransform(interval: subinterval, position: transformedPosition)
    }
}

extension ParallaxTransform: CustomStringConvertible {

    public var description: String {
        return "ParallaxTransform<\(String(describing: ValueType.self))>("
            + "interval: \(interval)"
            + ", position: \(position)"
            + ", parallaxValue: \(parallaxValue())"
            + ")"
    }
}
