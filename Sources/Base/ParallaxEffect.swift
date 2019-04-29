private let kUnitInterval = ParallaxInterval<Double>(from: 0, to: 1)
        
/// A private protocol which allows nested parallax effects of varying types.
private protocol ParallaxInheritable {
    
    func inheritProgress(_ position: Double)
}

/// A `ParallaxEffect` specifies an interval over which a change in value is expected; parallax effects are
/// achieved by composing a tree of `ParallaxEffect` objects, or parallax tree.
///
/// A root effect is responsible for seeding the parallax tree. See `seed(withValue:)`.
///
/// As a root behavior's value changes, position over its interval is calculated and inherited by its nested
/// effects. The nested effects use the inherited position to express values relative to their own interval;
/// one may subscribe to these values and use them to update other properties. See `change`.
public struct ParallaxEffect<ValueType: Parallaxable> {
    
    /// A type which represents a subinterval, specified over the unit interval [0, 1].
    public typealias Subinterval = ParallaxInterval<Double>
    
    /// Closure that is called whenever `self` expresses a value.
    public var change: ((ValueType) -> Void)?

    private let interval: ParallaxInterval<ValueType>
    private let isInheritedProgressClamped: Bool
    private let progressCurve: ParallaxCurve
    private var inheritorsBySubinterval = [Subinterval: [ParallaxInheritable]]()
    
    /// Initialize a `ParallaxEffect`, a node in a parallax tree.
    ///
    /// - Parameters:
    ///   - interval:   The interval over which change is expected.
    ///   - curve:      How inherited position is transformed. Default is `.linear`.
    ///   - isClamped:  Whether inherited position is clamped to the unit interval before it is transformed
    ///                 by `curve`. Default is `false`.
    ///   - change:     Closure that is called whenever the effect expresses a new value.
    public init(interval: ParallaxInterval<ValueType>,
                curve: ParallaxCurve = .linear,
                isClamped: Bool = false,
                change: ((ValueType) -> Void)? = nil)
    {
        self.interval = interval
        self.change = change
        self.progressCurve = curve
        self.isInheritedProgressClamped = isClamped
    }
    
    /// Add a nested effect that shall inherit position from `self`.
    ///
    /// - Parameters:
    ///   - effect:         The effect to add, which shall inherit position from `self`.
    ///   - subinterval:    The subinterval over which `effect` shall inherit position. Subintervals are
    ///                     specified over the unit interval [0, 1]. Default is the unit interval.
    public mutating func addEffect<NestedValueType>(_ effect: ParallaxEffect<NestedValueType>,
                                                    toSubinterval subinterval: Subinterval? = nil)
    {
        let interval = subinterval ?? kUnitInterval
        var inheritors = inheritorsBySubinterval[interval] ?? [ParallaxInheritable]()
        inheritors.append(effect)
        inheritorsBySubinterval[interval] = inheritors
    }
    
    /// Seed the parallax tree. Call this method on the root effect whenever its value should change.
    ///
    /// - note: Triggers `change` in the root and nested effects.
    ///
    /// - Parameter value: The seed from which all other values in the parallax tree shall be determined.
    public func seed(withValue value: ValueType) {
        let position = interval.position(forValue: value)
        setProgress(position)
    }
    
    // MARK: Private functions
    
    private func setProgress(_ position: Double) {
        expressValueIfNeeded(forProgress: position)
        for (subinterval, inheritors) in inheritorsBySubinterval {
            let position = translateProgress(position, overSubinterval: subinterval)
            inheritors.forEach { $0.inheritProgress(position) }
        }
    }
    
    private func expressValueIfNeeded(forProgress position: Double) {
        guard let change = change else {
            return
        }

        let value = interval.value(atPosition: position)
        change(value)
    }
    
    private func translateProgress(_ position: Double, overSubinterval subinterval: Subinterval) -> Double {
        if subinterval == kUnitInterval {
            return position
        }
        
        return subinterval.position(forValue: position)
    }
}

extension ParallaxEffect: ParallaxInheritable {
    
    fileprivate func inheritProgress(_ position: Double) {
        let position = isInheritedProgressClamped ? min(1, max(0, position)) : position
        let transformed = progressCurve.transform(position: position)
        setProgress(transformed)
    }
}
