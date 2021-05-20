import RxSwift

extension ObservableType {

    /// A value on the receiver's `interval`, as indicated by its `position`.
    ///
    /// By default, values are not strictly bounded by the transform interval; if that behavior is desired,
    /// first apply a clamp operation:
    /// ```
    /// parallaxMorph(.just(.clampToUnitInterval))
    /// ```
    /// - Returns: A value on the receiver's transform interval, suitable for the user interface.
    public func parallaxValue<ValueType>() -> Observable<ValueType>
        where Element == ParallaxTransform<ValueType>
    {
        return map { transform in
            return transform.parallaxValue()
        }
    }

    /// Transform the receiver such that the resulting value is proportional to the given `newInterval`, and
    /// is of type `ResultValueType`.
    ///
    /// # Resulting transform characteristics:
    ///   - The interval is the given `newInterval`.
    ///   - The receiver's position is preserved.
    ///   - `parallaxValue` is relative to the receiver's position, but on the given `newInterval`, and
    ///     is of type, `ResultValueType`.
    ///
    /// # Ex: Relate values from a Double-typed interval [0, 3], to a CGFloat-typed interval, [0, 6]:
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
    ///         .parallaxRelate(to: ParallaxInterval<CGFloat>.rx.interval(from: 0, to: 6))
    ///
    /// - Parameter newInterval: The interval of the resulting transform.
    /// - Returns: A new parallax transform, with a `parallaxValue` relative to the receiver's position,
    ///  but on the given `newInterval`, and of type, `ResultValueType`.
    public func parallaxRelate<ValueType, ResultValueType>(
        to newInterval: Observable<ParallaxInterval<ResultValueType>>)
        -> Observable<ParallaxTransform<ResultValueType>>
        where Element == ParallaxTransform<ValueType>
    {
        return Observable
            .combineLatest(self, newInterval)
            .map { transform, newInterval in
                return transform.relate(to: newInterval)
            }
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
    ///     let receiver = Observable<Double>.just(4)
    ///         .parallax(over: .interval(from: 0, to: 3))
    ///
    ///     // resulting transform:
    ///     //        [1           3]           result interval: [1, 3] (unchanged)
    ///     //        >0    .5    (1)<  1.5     result position: 1
    ///     //   0    >1     2    (3)<   4      result value: 3
    ///     let result = receiver
    ///         .parallaxMorph(with: .just(.clampToUnitInterval))
    ///
    /// - Parameter curve: The curve with which to alter the receiver's position.
    /// - Returns: A new parallax transform, with the receiver's position transformed by the given
    /// `curve` function; the resulting `parallaxValue` is relative to this new position, on the
    /// receiver's interval.
    public func parallaxMorph<ValueType>(
        with curve: Observable<PositionCurve>)
        -> Observable<ParallaxTransform<ValueType>>
        where Element == ParallaxTransform<ValueType>
    {
        return Observable
            .combineLatest(self, curve)
            .map { transform, curve in
                return transform.morph(with: curve)
            }
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
    ///     let receiver = Observable<Double>.just(1)
    ///         .parallax(over: .interval(from: 0, to: 4))
    ///
    ///     // resulting transform:
    ///     //               [2           4]   `subinterval`: [2, 4]
    ///     //   -1   -.5     0    .5     1    result position: -.5
    ///     //    0    (1)    2     3     4    result value: 1 (unchanged)
    ///     let result = receiver
    ///         .parallaxFocus(on: .interval(from: 2, to: 4))
    ///
    /// - Parameter subinterval: The interval of the resulting transform.
    /// - Returns: A new parallax transform which maps the receiver's `parallaxValue` to the same value, but
    /// on the given `subinterval`.
    public func parallaxFocus<ValueType>(
        on subinterval: Observable<ParallaxInterval<ValueType>>)
        -> Observable<ParallaxTransform<ValueType>>
        where Element == ParallaxTransform<ValueType>
    {
        return Observable
            .combineLatest(self, subinterval)
            .map { transform, subinterval in
                return transform.focus(on: subinterval)
            }
    }
}
