import RxSwift
import RxCocoa

extension ParallaxInterval: ReactiveCompatible {}

extension Reactive {

    /// Create an observable which signals a `ParallaxInterval` constructed from the given `from` and `to`
    /// observables.
    ///
    /// - Parameters:
    ///   - from:   The start of the interval.
    ///   - to:     The end of the interval.
    public static func interval<ValueType>(
        from: Observable<ValueType>,
        to: Observable<ValueType>)
        -> Observable<ParallaxInterval<ValueType>>
        where Base == ParallaxInterval<ValueType>
    {
        return Observable
            .combineLatest(from, to)
            .map(ParallaxInterval.init(from:to:))
            .skipNil()
    }

    /// Create an observable which signals a `ParallaxInterval` constructed from the given `from` and `to`
    /// values.
    ///
    /// - Parameters:
    ///   - from:   The start of the interval.
    ///   - to:     The end of the interval.
    public static func interval<ValueType>(
        from: ValueType,
        to: ValueType)
        -> Observable<ParallaxInterval<ValueType>>
        where Base == ParallaxInterval<ValueType>
    {
        return interval(from: .just(from), to: .just(to))
    }
}

extension ObservableType {

    /// Create a observable which signals a `ParallaxInterval` constructed from the given `from` and `to`
    /// observables.
    ///
    /// This is a convenience method for creating an interval which satisfies an `ObservableType` parameter
    /// signature:
    ///
    ///     // Compare convenience method:
    ///     observable.parallax(over: .interval(from: 0, to: 3))
    ///     // vs less convenient method:
    ///     observable.parallax(over: ParallaxInterval.rx.interval(from: 0, to: 3))
    ///
    /// - Parameters:
    ///   - from:   The start of the interval.
    ///   - to:     The end of the interval.
    public static func interval<ValueType>(
        from: Observable<ValueType>,
        to: Observable<ValueType>)
        -> Observable<ParallaxInterval<ValueType>>
        where Element == ParallaxInterval<ValueType>
    {
        return ParallaxInterval.rx.interval(from: from, to: to)
    }

    /// Create a observable which signals a `ParallaxInterval` constructed from the given `from` and `to`
    /// values.
    ///
    /// This is a convenience method for creating an interval which satisfies an `ObservableType` parameter
    /// signature:
    ///
    ///     // Compare convenience method:
    ///     observable.parallax(over: .interval(from: 0, to: 3))
    ///     // vs less convenient method:
    ///     observable.parallax(over: ParallaxInterval.rx.interval(from: 0, to: 3))
    ///
    /// - Parameters:
    ///   - from:   The start of the interval.
    ///   - to:     The end of the interval.
    public static func interval<ValueType>(
        from: ValueType,
        to: ValueType)
        -> Observable<ParallaxInterval<ValueType>>
        where Element == ParallaxInterval<ValueType>
    {
        return ParallaxInterval.rx.interval(from: from, to: to)
    }
}
