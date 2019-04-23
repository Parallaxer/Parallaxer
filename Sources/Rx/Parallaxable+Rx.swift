import RxSwift

/// A type which represents a subinterval, specified over the unit interval [0, 1].
public typealias Subinterval = ParallaxInterval<Double>

public let kSubinterval: Subinterval = ParallaxInterval<Double>(from: 0, to: 1)

public protocol ParallaxTransformable {

    /// The type of value that is changing.
    associatedtype ValueType: Parallaxable

    /// Current progress over `interval`, represented as a value along, but not necessarily bounded by, the
    /// unit interval [0, 1].
    var progress: Double { get }

    /// The interval over which change is expected to occur. Values are relative to this interval.
    var interval: ParallaxInterval<ValueType> { get }
}

extension ParallaxTransformable {

    /// A value relative to the progress over the interval.
    var valueOverInterval: ValueType {
        return interval.value(forProgress: progress)
    }
}

// [0                       4]   interval
// [0     1     2     3     4]   values
// [0%   25%   50%   75%   100%] progression
//        ^
//      0.25                     progress
//            [0.5         1.0]  subinterval
//      -0.5    0    0.5   1.0   subinterval values
public struct ParallaxProgress<ValueType: Parallaxable>: ParallaxTransformable {

    public let progress: Double
    public let interval: ParallaxInterval<ValueType>
}

extension ObservableType where E: Parallaxable {

    public func asParallaxObservable(over interval: ParallaxInterval<E>) -> Observable<ParallaxProgress<E>> {
        return map { value in
            let progress = interval.progress(forValue: value)
            return ParallaxProgress(progress: progress, interval: interval)
        }
    }
}

extension ObservableType where E: ParallaxTransformable {

    public func normalize(over Subinterval: Subinterval) -> Observable<ParallaxProgress<Double>> {
        return map { value in
            if Subinterval == kSubinterval {
                return ParallaxProgress<Double>(progress: value.progress, interval: kSubinterval)
            }

            let transformedProgress = Subinterval.progress(forValue: value.progress)
            return ParallaxProgress<Double>(progress: transformedProgress, interval: Subinterval)
        }
    }

    public func transform(with curve: ParallaxCurve) -> Observable<ParallaxProgress<E.ValueType>> {
        return map { value in
            let transformedProgress = curve.transform(progress: value.progress)
            return ParallaxProgress(progress: transformedProgress, interval: value.interval)
        }
    }

    public func clampToUnitInterval() -> Observable<ParallaxProgress<E.ValueType>> {
        return map { value in
            let clampedProgress = min(1, max(0, value.progress))
            return ParallaxProgress(progress: clampedProgress, interval: value.interval)
        }
    }

    public func transform<OtherValueType>(over interval: ParallaxInterval<OtherValueType>)
        -> Observable<ParallaxProgress<OtherValueType>>
    {
        return map { value in
            return ParallaxProgress<OtherValueType>(progress: value.progress, interval: interval)
        }
    }

    public func parallaxValue() -> Observable<E.ValueType> {
        return map { value in
            return value.valueOverInterval
        }
    }
}
