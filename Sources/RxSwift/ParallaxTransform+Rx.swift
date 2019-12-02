import RxSwift
import RxCocoa

extension ObservableType {

    /// A value on the receiver's `interval`, as indicated by its `position`.
    ///
    /// By default, values are not strictly bounded by the transform interval; if that behavior is desired,
    /// first apply a clamp transformation:
    /// ```
    /// parallaxReposition(.just(.clampToUnitInterval))
    /// ```
    /// - Returns: A value on the receiver's transform interval, suitable for the user interface.
    public func parallaxValue<ValueType>() -> Observable<ValueType>
        where Element == ParallaxTransform<ValueType>
    {
        return map { transform in
            return transform.parallaxValue()
        }
    }

    /// Create a new parallax transform which scales `parallaxValue` such that it is relative to the
    /// receiver's unit position, but on the given `otherInterval`, and is of type, `ResultValueType`.
    ///
    /// # Resulting transform characteristics:
    ///   - The interval is the given `otherInterval`.
    ///   - The receiver's unit position is preserved.
    ///   - `parallaxValue` is relative to the receiver's unit position, but on the given `otherInterval`, and
    ///     is of type, `ResultValueType`.
    ///
    /// # Ex: Scale values from a Double-typed interval [0, 3], to a CGFloat-typed interval, [0, 6]:
    ///     // receiving transform:
    ///     //   [0                 3]                      receiver's interval: [0, 3]
    ///     //    0       .5       (1)                      receiver's position: 1
    ///     //    0     1     2    (3)    4                 receiver's value: 3
    ///     let receiver = Observable<Double>.just(3)
    ///         .parallax(over: .interval(from: 0, to: 3))
    ///
    ///     // resulting transform:
    ///     //   [0                                    6]   result interval: [0, 6]
    ///     //    0                .5                 (1)   result position: 1 (unchanged)
    ///     //    0     1     2     3     4      5    (6)   result value: 6
    ///     let result = receiver
    ///         .parallaxScale(to: ParallaxInterval<CGFloat>.rx.interval(from: 0, to: 6))
    ///
    /// - Parameter otherInterval: The interval of the resulting transform.
    /// - Returns: A new parallax transform, with a `parallaxValue` relative to the receiver's unit position,
    ///  but on the given `otherInterval`, and of type, `ResultValueType`.
    public func parallaxScale<ValueType, ResultValueType>(
        to otherInterval: Observable<ParallaxInterval<ResultValueType>>)
        -> Observable<ParallaxTransform<ResultValueType>>
        where Element == ParallaxTransform<ValueType>
    {
        return Observable
            .combineLatest(self, otherInterval)
            .map { transform, interval in
                return transform.scale(to: interval)
            }
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
    ///     let receiver = Observable<Double>.just(4)
    ///         .parallax(over: .interval(from: 0, to: 3))
    ///
    ///     // resulting transform:
    ///     //        [1           3]           result interval: [1, 3] (unchanged)
    ///     //        >0    .5    (1)<  1.5     result position: 1
    ///     //   0    >1     2    (3)<   4      result value: 3
    ///     let result = receiver
    ///         .parallaxReposition(with: .just(.clampToUnitInterval))
    ///
    /// - Parameter curve: The curve with which to alter the receiver's unit position.
    /// - Returns: A new parallax transform, with the receiver's unit position transformed by the given
    /// `curve` function; the resulting `parallaxValue` is relative to this new unit position, on the
    /// receiver's interval.
    public func parallaxReposition<ValueType>(
        with curve: Observable<PositionCurve>)
        -> Observable<ParallaxTransform<ValueType>>
        where Element == ParallaxTransform<ValueType>
    {
        return Observable
            .combineLatest(self, curve)
            .map { transform, curve in
                return transform.reposition(with: curve)
            }
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
    ///     let receiver = Observable<Double>.just(1)
    ///         .parallax(over: .interval(from: 0, to: 4))
    ///
    ///     // resulting transform:
    ///     //               [2           4]   `subinterval`: [2, 4]
    ///     //   -1   -.5     0    .5     1    result position: -.5
    ///     //    0    (1)    2     3     4    result value: 1 (unchanged)
    ///     let result = receiver
    ///         .parallaxFocus(subinterval: .interval(from: 2, to: 4))
    ///
    /// - Parameter subinterval: A subset of the receiver's interval.
    /// - Returns: A new parallax transform such that `parallaxValue` is unchanged, but now relative to the
    /// resulting unit position, on the specified `subinterval`.
    public func parallaxFocus<ValueType>(
        subinterval: Observable<ParallaxInterval<ValueType>>)
        -> Observable<ParallaxTransform<ValueType>>
        where Element == ParallaxTransform<ValueType>
    {
        return Observable
            .combineLatest(self, subinterval)
            .map { transform, subinterval in
                return transform.focus(subinterval: subinterval)
            }
    }
}
